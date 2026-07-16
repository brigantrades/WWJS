import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionService extends ChangeNotifier {
  SubscriptionService(this._supabase, {InAppPurchase? store})
    : _providedStore = store;

  static const androidProductId = 'wwjs_full_access';
  static const appleMonthlyProductId = 'wwjs_full_access_monthly';
  static const appleYearlyProductId = 'wwjs_full_access_yearly';
  static const monthlyBasePlanId = 'monthly';
  static const yearlyBasePlanId = 'yearly';

  final SupabaseClient _supabase;
  InAppPurchase? _providedStore;
  InAppPurchase get _store => _providedStore ??= InAppPurchase.instance;
  final Map<String, ProductDetails> _products = {};
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool _storeAvailable = false;
  bool _loading = true;
  bool _purchasePending = false;
  bool _isEntitled = false;
  DateTime? _expiresAt;
  String? _errorMessage;

  bool get storeAvailable => _storeAvailable;
  bool get loading => _loading;
  bool get purchasePending => _purchasePending;
  bool get isEntitled => _isEntitled;
  DateTime? get expiresAt => _expiresAt;
  String? get errorMessage => _errorMessage;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  bool get _isApple => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  bool get _isSupportedPlatform => _isAndroid || _isApple;
  String get _billingFunctionName =>
      _isApple ? 'apple-storekit-billing' : 'google-play-billing';
  String get _storeName => _isApple ? 'The App Store' : 'Google Play';

  bool canPurchase(String basePlanId) =>
      _storeAvailable && _products.containsKey(basePlanId);

  String priceFor(String basePlanId, {required String fallback}) {
    final product = _products[basePlanId];
    if (product == null) return fallback;
    final period = switch (basePlanId) {
      monthlyBasePlanId => 'month',
      yearlyBasePlanId => 'year',
      _ => '',
    };
    return period.isEmpty ? product.price : '${product.price} / $period';
  }

  String billingLabelFor(String basePlanId, {required String fallback}) {
    final product = _products[basePlanId];
    if (product == null) return fallback;
    final period = basePlanId == yearlyBasePlanId ? 'yearly' : 'monthly';
    return '${product.price} billed $period';
  }

  Future<void> initialize() async {
    _purchaseSubscription = _store.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error, StackTrace stackTrace) {
        _setError('$_storeName billing could not be reached.');
        debugPrint('Purchase stream failed: $error\n$stackTrace');
      },
    );

    await refreshEntitlement();

    if (_isSupportedPlatform) {
      try {
        _storeAvailable = await _store.isAvailable();
        if (_storeAvailable) {
          await _loadProducts();
          await _store.restorePurchases();
        }
      } catch (error, stackTrace) {
        debugPrint('$_storeName initialization failed: $error\n$stackTrace');
        _setError('Subscriptions are temporarily unavailable.');
      }
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> _loadProducts() async {
    final productIds = _isApple
        ? {appleMonthlyProductId, appleYearlyProductId}
        : {androidProductId};
    final response = await _store.queryProductDetails(productIds);
    if (response.error != null) {
      throw StateError(response.error!.message);
    }

    for (final product in response.productDetails) {
      if (_isApple) {
        if (product.id == appleMonthlyProductId) {
          _products[monthlyBasePlanId] = product;
        } else if (product.id == appleYearlyProductId) {
          _products[yearlyBasePlanId] = product;
        }
      } else if (product is GooglePlayProductDetails) {
        final index = product.subscriptionIndex;
        final offers = product.productDetails.subscriptionOfferDetails;
        if (index == null || offers == null || index >= offers.length) continue;
        final offer = offers[index];
        final existing = _products[offer.basePlanId];
        if (existing == null || offer.offerId == null) {
          _products[offer.basePlanId] = product;
        }
      }
    }

    if (response.notFoundIDs.isNotEmpty || _products.isEmpty) {
      _setError('The WWJS subscription is not available for this account.');
    }
  }

  Future<bool> purchase(String basePlanId) async {
    _clearError();
    final product = _products[basePlanId];
    final user = _supabase.auth.currentUser;
    if (!_storeAvailable || product == null || user == null) {
      _setError('This subscription option is unavailable right now.');
      return false;
    }

    try {
      _purchasePending = true;
      notifyListeners();
      final started = await _store.buyNonConsumable(
        purchaseParam: PurchaseParam(
          productDetails: product,
          applicationUserName: user.id,
        ),
      );
      if (!started) {
        _purchasePending = false;
        _setError('$_storeName could not start the purchase.');
      }
      return started;
    } catch (error, stackTrace) {
      _purchasePending = false;
      debugPrint('Starting purchase failed: $error\n$stackTrace');
      _setError('$_storeName could not start the purchase.');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    _clearError();
    if (!_storeAvailable) {
      _setError('$_storeName is unavailable right now.');
      return;
    }
    try {
      _purchasePending = true;
      notifyListeners();
      await _store.restorePurchases();
    } catch (error, stackTrace) {
      debugPrint('Restoring purchases failed: $error\n$stackTrace');
      _setError('Your purchases could not be restored.');
    } finally {
      _purchasePending = false;
      notifyListeners();
    }
  }

  Future<void> refreshEntitlement() async {
    try {
      final response = await _supabase.functions.invoke(
        _billingFunctionName,
        body: const {'action': 'status'},
      );
      _applyEntitlement(response.data);
    } catch (error, stackTrace) {
      // A temporary status-check failure must not prevent the app from opening.
      debugPrint('Subscription status check failed: $error\n$stackTrace');
    }
  }

  Future<void> syncPurchases() async {
    await refreshEntitlement();
    if (!_isSupportedPlatform || !_storeAvailable) {
      return;
    }
    try {
      await _store.restorePurchases();
    } catch (error, stackTrace) {
      debugPrint('Background purchase sync failed: $error\n$stackTrace');
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (!_isKnownProduct(purchase.productID)) continue;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _purchasePending = true;
          notifyListeners();
          continue;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndDeliver(
            purchase,
            restored: purchase.status == PurchaseStatus.restored,
          );
          continue;
        case PurchaseStatus.error:
          _purchasePending = false;
          _setError(
            purchase.error?.message ?? 'The purchase was unsuccessful.',
          );
          continue;
        case PurchaseStatus.canceled:
          _purchasePending = false;
          notifyListeners();
          continue;
      }
    }
  }

  Future<void> _verifyAndDeliver(
    PurchaseDetails purchase, {
    required bool restored,
  }) async {
    try {
      final token = purchase.verificationData.serverVerificationData;
      if (token.isEmpty) {
        throw StateError('$_storeName returned no purchase verification data.');
      }
      final response = await _supabase.functions.invoke(
        _billingFunctionName,
        body: _isApple
            ? {
                'action': 'verify',
                'productId': purchase.productID,
                'signedTransaction': token,
                'restored': restored,
              }
            : {
                'action': 'verify',
                'productId': purchase.productID,
                'purchaseToken': token,
              },
      );
      _applyEntitlement(response.data);
      if (!_isEntitled) {
        throw StateError('$_storeName did not confirm an active subscription.');
      }
      if (purchase.pendingCompletePurchase) {
        await _store.completePurchase(purchase);
      }
      _purchasePending = false;
      _clearError();
      notifyListeners();
    } catch (error, stackTrace) {
      _purchasePending = false;
      debugPrint('Purchase verification failed: $error\n$stackTrace');
      _setError(
        'The purchase could not be verified. Please try Restore purchases.',
      );
    }
  }

  bool _isKnownProduct(String productId) => _isApple
      ? productId == appleMonthlyProductId || productId == appleYearlyProductId
      : productId == androidProductId;

  void _applyEntitlement(dynamic value) {
    if (value is! Map) return;
    final error = value['error'];
    if (error is String && error.isNotEmpty) {
      throw StateError(error);
    }
    _isEntitled = value['isEntitled'] == true;
    final expiry = value['expiresAt'];
    _expiresAt = expiry is String ? DateTime.tryParse(expiry) : null;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_purchaseSubscription?.cancel());
    super.dispose();
  }
}
