DateTime localDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

int calendarDayDifference(DateTime from, DateTime to) {
  final fromUtc = DateTime.utc(from.year, from.month, from.day);
  final toUtc = DateTime.utc(to.year, to.month, to.day);
  return toUtc.difference(fromUtc).inDays;
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
