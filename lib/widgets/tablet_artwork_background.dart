import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_theme.dart';

class TabletArtworkFrame extends StatelessWidget {
  const TabletArtworkFrame({
    super.key,
    required this.background,
    required this.child,
  });

  final Widget background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!AppLayout.isTablet(context)) return child;
    return Stack(fit: StackFit.expand, children: [background, child]);
  }
}

/// Full-viewport artwork used only by tablet screen branches.
///
/// Portrait artwork gets a softly blended, full-composition layer over a
/// cover crop so the cross and path remain visible without side gutters.
class TabletArtworkBackground extends StatelessWidget {
  static const _dawnArtworkAspectRatio = 941 / 1672;

  const TabletArtworkBackground({
    super.key,
    required this.assetName,
    this.preservePortraitComposition = false,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.topCenter,
    this.portraitOffsetY = 0,
    this.bottomScrimOpacity = .56,
    this.textureOpacity = 0,
    this.fadeArtworkBottom = false,
  });

  final String assetName;
  final bool preservePortraitComposition;
  final BoxFit fit;
  final Alignment alignment;
  final double portraitOffsetY;
  final double bottomScrimOpacity;
  final double textureOpacity;
  final bool fadeArtworkBottom;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark
        ? AppSemanticColors.of(context).appBackground
        : AppColors.playerIvory;

    Widget artwork({required BoxFit fit}) => Image.asset(
      assetName,
      fit: fit,
      alignment: alignment,
      filterQuality: FilterQuality.high,
      excludeFromSemantics: true,
    );

    return IgnorePointer(
      child: ExcludeSemantics(
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: surface),
            if (textureOpacity > 0)
              Opacity(
                opacity: textureOpacity,
                child: Image.asset(
                  'assets/images/player-paper-texture.png',
                  fit: BoxFit.cover,
                  color: dark ? AppColors.darkText : null,
                  colorBlendMode: dark ? BlendMode.softLight : null,
                  filterQuality: FilterQuality.medium,
                  excludeFromSemantics: true,
                ),
              ),
            if (preservePortraitComposition) ...[
              Opacity(
                opacity: .34,
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 38, sigmaY: 38),
                  child: Transform.scale(
                    scale: 1.08,
                    child: artwork(fit: BoxFit.cover),
                  ),
                ),
              ),
              Positioned(
                top: portraitOffsetY,
                left: 0,
                right: 0,
                bottom: 0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compositionWidth = math.min(
                      constraints.maxWidth,
                      constraints.maxHeight * _dawnArtworkAspectRatio,
                    );
                    return Center(
                      child: SizedBox(
                        width: compositionWidth,
                        height: constraints.maxHeight,
                        child: ShaderMask(
                          blendMode: BlendMode.dstIn,
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white,
                              Colors.white,
                              Colors.transparent,
                            ],
                            stops: [0, .16, .84, 1],
                          ).createShader(bounds),
                          child: artwork(fit: BoxFit.contain),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else if (fadeArtworkBottom)
              ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white, Colors.transparent],
                  stops: [0, .30, .50],
                ).createShader(bounds),
                child: artwork(fit: fit),
              )
            else
              artwork(fit: fit),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    surface.withValues(alpha: .04),
                    surface.withValues(alpha: bottomScrimOpacity * .28),
                    surface.withValues(alpha: bottomScrimOpacity * .66),
                    surface.withValues(alpha: bottomScrimOpacity),
                  ],
                  stops: const [0, .38, .72, 1],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
