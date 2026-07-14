import 'package:flutter/material.dart';

class DawnArtwork extends StatelessWidget {
  const DawnArtwork({
    super.key,
    this.height = 420,
    this.compact = false,
    this.useDarkArtwork = false,
    this.child,
  });

  final double height;
  final bool compact;
  final bool useDarkArtwork;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              dark && useDarkArtwork
                  ? 'assets/images/dawn-path-dark.png'
                  : 'assets/images/dawn-path.png',
              fit: BoxFit.cover,
              alignment: compact ? Alignment.center : const Alignment(0, -0.35),
              filterQuality: FilterQuality.high,
            ),
            if (dark && !useDarkArtwork)
              ColoredBox(color: Colors.black.withValues(alpha: .28)),
            ?child,
          ],
        ),
      ),
    );
  }
}
