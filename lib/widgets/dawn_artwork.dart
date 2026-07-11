import 'package:flutter/material.dart';

class DawnArtwork extends StatelessWidget {
  const DawnArtwork({
    super.key,
    this.height = 420,
    this.compact = false,
    this.child,
  });

  final double height;
  final bool compact;
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
              'assets/images/dawn-path.png',
              fit: BoxFit.cover,
              alignment: compact ? Alignment.center : const Alignment(0, -0.35),
              filterQuality: FilterQuality.high,
            ),
            if (dark) ColoredBox(color: Colors.black.withValues(alpha: .28)),
            ?child,
          ],
        ),
      ),
    );
  }
}
