List<Uri> audioSourceCandidates(String audioUrl) {
  final primary = Uri.parse(audioUrl);
  final lowerPath = primary.path.toLowerCase();
  final alternateExtension = switch (lowerPath) {
    final path when path.endsWith('.mp3') => '.m4a',
    final path when path.endsWith('.m4a') => '.mp3',
    _ => null,
  };

  if (alternateExtension == null) return [primary];

  final alternatePath =
      primary.path.substring(0, primary.path.length - 4) + alternateExtension;
  return [primary, primary.replace(path: alternatePath)];
}
