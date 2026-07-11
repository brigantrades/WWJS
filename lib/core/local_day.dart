DateTime localDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

int calendarDayDifference(DateTime from, DateTime to) {
  return localDay(to).difference(localDay(from)).inDays;
}

int calculateUnlockedDay({
  required DateTime startDate,
  required DateTime today,
  required int previousHighest,
  required int contentCount,
}) {
  if (contentCount <= 0) return 0;
  final elapsed = calendarDayDifference(startDate, today);
  final candidate = (elapsed + 1).clamp(1, contentCount);
  return candidate > previousHighest
      ? candidate
      : previousHighest.clamp(1, contentCount);
}

String encodeLocalDay(DateTime value) {
  final day = localDay(value);
  return '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';
}

DateTime? decodeLocalDay(String? value) {
  if (value == null) return null;
  final parsed = DateTime.tryParse(value);
  return parsed == null ? null : localDay(parsed);
}
