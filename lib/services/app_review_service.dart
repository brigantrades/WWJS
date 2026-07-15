import 'package:in_app_review/in_app_review.dart';

bool shouldRequestStoreReview({
  required int completedDay,
  required bool wasAlreadyCompleted,
}) => completedDay == 5 && !wasAlreadyCompleted;

abstract interface class ReviewPrompter {
  Future<void> requestReview();
}

class AppReviewService implements ReviewPrompter {
  AppReviewService({InAppReview? inAppReview})
    : _inAppReview = inAppReview ?? InAppReview.instance;

  final InAppReview _inAppReview;

  @override
  Future<void> requestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      }
    } catch (_) {
      // A review request should never interrupt the completion experience.
    }
  }
}
