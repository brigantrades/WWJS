import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'brand_logo.dart';

enum UpdateModalAction { update, later }

Future<UpdateModalAction?> showUpdateModal(BuildContext context) {
  return showModalBottomSheet<UpdateModalAction>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: Colors.black.withValues(alpha: .54),
    backgroundColor: Colors.transparent,
    builder: (_) => const _UpdateSheet(),
  );
}

class _UpdateSheet extends StatelessWidget {
  const _UpdateSheet();

  @override
  Widget build(BuildContext context) {
    final lightTheme = Theme.of(context).copyWith(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.forest,
        brightness: Brightness.light,
        surface: AppColors.warmWhite,
      ),
    );

    return Theme(
      data: lightTheme,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        decoration: const BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            const Positioned(
              right: -30,
              bottom: -42,
              child: IgnorePointer(child: _BotanicalSprig()),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 22),
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 96,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.sage.withValues(alpha: .48),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Row(
                      children: [
                        _UpdateIcon(),
                        SizedBox(width: 14),
                        BrandLogo(size: 42, semanticLabel: 'WWJS logo'),
                        SizedBox(width: 10),
                        Text(
                          'WWJS',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontFamilyFallback: ['Georgia', 'Times New Roman'],
                            color: AppColors.forest,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Your Journey Continues',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(color: AppColors.charcoal, fontSize: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'The latest WWJS update is ready. Take a moment to update and keep your experience running beautifully.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: () =>
                          Navigator.pop(context, UpdateModalAction.update),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.forest,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(58),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('Update now'),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pop(context, UpdateModalAction.later),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.forest,
                          minimumSize: const Size(160, 48),
                        ),
                        child: const Text('Maybe later'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateIcon extends StatelessWidget {
  const _UpdateIcon();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'App update available',
      child: Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(
          color: AppColors.dawnPeach,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_upward_rounded,
          color: Colors.white,
          size: 34,
        ),
      ),
    );
  }
}

class _BotanicalSprig extends StatelessWidget {
  const _BotanicalSprig();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(190, 190),
      painter: _BotanicalPainter(),
    );
  }
}

class _BotanicalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stem = Paint()
      ..color = AppColors.sage.withValues(alpha: .18)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final leaves = Paint()
      ..color = AppColors.sage.withValues(alpha: .12)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width * .92, size.height)
      ..quadraticBezierTo(
        size.width * .72,
        size.height * .48,
        size.width * .28,
        size.height * .12,
      );
    canvas.drawPath(path, stem);

    const leavesData = <(double, double, double)>[
      (.73, .64, -.7),
      (.78, .52, .55),
      (.59, .46, -.75),
      (.61, .34, .5),
      (.43, .29, -.8),
      (.36, .17, .45),
    ];
    for (final (x, y, rotation) in leavesData) {
      canvas.save();
      canvas.translate(size.width * x, size.height * y);
      canvas.rotate(rotation);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 42, height: 19),
        leaves,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
