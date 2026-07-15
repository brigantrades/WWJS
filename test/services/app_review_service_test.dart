import 'package:flutter_test/flutter_test.dart';
import 'package:wwjs/services/app_review_service.dart';

void main() {
  group('shouldRequestStoreReview', () {
    test('requests a review after the first completion of Day 5', () {
      expect(
        shouldRequestStoreReview(completedDay: 5, wasAlreadyCompleted: false),
        isTrue,
      );
    });

    test('does not request again when Day 5 is replayed', () {
      expect(
        shouldRequestStoreReview(completedDay: 5, wasAlreadyCompleted: true),
        isFalse,
      );
    });

    test('does not request after another day', () {
      expect(
        shouldRequestStoreReview(completedDay: 4, wasAlreadyCompleted: false),
        isFalse,
      );
    });
  });
}
