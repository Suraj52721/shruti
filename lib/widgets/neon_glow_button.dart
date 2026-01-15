import 'package:flutter/material.dart';
import '../theme.dart';

class NeonGlowButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Color glowColor;
  final double width;
  final double height;

  const NeonGlowButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.glowColor = AppTheme.neonCyan,
    this.width = 200,
    this.height = 50,
  });

  @override
  State<NeonGlowButton> createState() => _NeonGlowButtonState();
}

class _NeonGlowButtonState extends State<NeonGlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _NeonGlowPainter(
              animationValue: _controller.value,
              glowColor: widget.glowColor,
            ),
            child: Container(
              width: widget.width,
              height: widget.height,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.text.toUpperCase(),
                style: TextStyle(
                  color: widget.glowColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      color: widget.glowColor.withValues(alpha: 0.8),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NeonGlowPainter extends CustomPainter {
  final double animationValue;
  final Color glowColor;

  _NeonGlowPainter({required this.animationValue, required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // final center = rect.center; // Unused

    // Rotating gradient for strict border
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          glowColor.withValues(alpha: 0.2),
          glowColor,
          glowColor.withValues(alpha: 0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
        startAngle: 0.0,
        endAngle: 3.14 * 2,
        transform: GradientRotation(animationValue * 3.14 * 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(rrect, paint);

    // Ambient glow
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawRRect(rrect.deflate(2), glowPaint);
  }

  @override
  bool shouldRepaint(covariant _NeonGlowPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.glowColor != glowColor;
  }
}
