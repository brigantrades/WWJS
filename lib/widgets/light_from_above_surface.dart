import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// A quiet parchment surface with a vertically fading, path-aligned light.
///
/// This widget is decorative by design: it contributes no semantics and never
/// participates in hit testing.
class LightFromAboveSurface extends StatelessWidget {
  const LightFromAboveSurface({
    super.key,
    required this.glowOriginY,
    required this.glowEndY,
  });

  final double glowOriginY;
  final double glowEndY;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = dark ? AppColors.darkBackground : AppColors.playerIvory;

    return Positioned.fill(
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: ColoredBox(
            color: background,
            child: dark
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Opacity(
                        opacity: 0.2,
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF30443A),
                            BlendMode.modulate,
                          ),
                          child: Image.asset(
                            'assets/images/player-paper-texture.png',
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ),
                      RepaintBoundary(
                        child: CustomPaint(
                          painter: _LightFromAbovePainter(
                            glowOriginY: glowOriginY,
                            glowEndY: glowEndY,
                            dark: true,
                          ),
                        ),
                      ),
                    ],
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Opacity(
                        // The paper grain needs to remain visible below the
                        // verse at normal phone scale, while still yielding
                        // enough contrast for the forest text.
                        opacity: 0.9,
                        child: Image.asset(
                          'assets/images/player-paper-texture.png',
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.medium,
                          excludeFromSemantics: true,
                        ),
                      ),
                      RepaintBoundary(
                        child: CustomPaint(
                          painter: _LightFromAbovePainter(
                            glowOriginY: glowOriginY,
                            glowEndY: glowEndY,
                            dark: false,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Softens the artwork edge and carries its path-aligned rays into the paper.
class LightFromAboveHeroTransition extends StatelessWidget {
  const LightFromAboveHeroTransition({super.key, required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final surface = dark ? AppColors.darkBackground : AppColors.playerIvory;

    return IgnorePointer(
      child: ExcludeSemantics(
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    surface.withValues(alpha: dark ? 0.12 : 0.08),
                    surface.withValues(alpha: dark ? 0.18 : 0.14),
                    surface.withValues(alpha: dark ? 0.22 : 0.18),
                  ],
                  stops: const [0.64, 0.78, 0.93, 1],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LightFromAbovePainter extends CustomPainter {
  const _LightFromAbovePainter({
    required this.glowOriginY,
    required this.glowEndY,
    required this.dark,
  });

  final double glowOriginY;
  final double glowEndY;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    _paintGlow(canvas, size);
  }

  void _paintGlow(Canvas canvas, Size size) {
    if (glowEndY <= glowOriginY) return;

    final centerX = size.width / 2;
    final glowHeight = glowEndY - glowOriginY;
    final glowRect = Rect.fromCenter(
      center: Offset(centerX, glowOriginY + glowHeight * 0.34),
      width: size.width * 0.78,
      height: glowHeight * 1.16,
    );
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: dark
            ? const [Color(0x52F4B94E), Color(0x2AF4B94E), Color(0x00F4B94E)]
            : const [Color(0x4AFFF4D6), Color(0x28FFF4D6), Color(0x00FFF4D6)],
        stops: [0, 0.42, 1],
      ).createShader(glowRect);
    canvas.drawOval(glowRect, glowPaint);

    _paintTaperedRays(
      canvas,
      size,
      startY: glowOriginY,
      endY: glowEndY,
      startAlpha: dark ? 0.2 : 0.36,
      fadeOut: true,
      dark: dark,
    );
  }

  @override
  bool shouldRepaint(covariant _LightFromAbovePainter oldDelegate) =>
      glowOriginY != oldDelegate.glowOriginY ||
      glowEndY != oldDelegate.glowEndY ||
      dark != oldDelegate.dark;
}

void _paintTaperedRays(
  Canvas canvas,
  Size size, {
  required double startY,
  required double endY,
  required double startAlpha,
  required bool fadeOut,
  required bool dark,
}) {
  final centerX = size.width / 2;
  const rays = [
    (-0.22, 0.028),
    (-0.14, 0.042),
    (-0.07, 0.05),
    (0, 0.058),
    (0.07, 0.05),
    (0.14, 0.042),
    (0.22, 0.028),
  ];
  const layers = [(2.6, 0.15), (1.7, 0.25), (1.0, 0.6)];

  for (final ray in rays) {
    for (final layer in layers) {
      final endX = centerX + size.width * ray.$1;
      final startHalfWidth = 1.5 * layer.$1;
      final endHalfWidth = size.width * ray.$2 * layer.$1;
      final path = Path()
        ..moveTo(centerX - startHalfWidth, startY)
        ..lineTo(centerX + startHalfWidth, startY)
        ..lineTo(endX + endHalfWidth, endY)
        ..lineTo(endX - endHalfWidth, endY)
        ..close();
      final alpha = startAlpha * layer.$2;
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (dark ? const Color(0xFFF4B94E) : const Color(0xFFF4D99B))
                .withValues(alpha: alpha),
            (dark ? const Color(0xFFFFD47A) : const Color(0xFFF8E6B9))
                .withValues(alpha: alpha * 0.65),
            (dark ? const Color(0xFFFFE6A8) : const Color(0xFFFFF4D6))
                .withValues(alpha: fadeOut ? 0 : alpha * 0.45),
          ],
          stops: const [0, 0.48, 1],
        ).createShader(Rect.fromLTRB(0, startY, size.width, endY));
      canvas.drawPath(path, paint);
    }
  }
}
