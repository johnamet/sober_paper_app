import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_shadows.dart';
import '../constants/app_spacing.dart';

/// PaperCard - A card widget with paper/journal aesthetic
class PaperCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;
  final bool hasCornerFold;

  const PaperCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.shadows,
    this.hasCornerFold = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.paperWhite,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: shadows ?? AppShadows.card,
        border: Border.all(
          color: AppColors.paperEdge,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
            child: child,
          ),
          if (hasCornerFold) _buildCornerFold(),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildCornerFold() {
    return Positioned(
      top: 0,
      right: 0,
      child: CustomPaint(
        size: Size(20, 20),
        painter: CornerFoldPainter(),
      ),
    );
  }
}

class CornerFoldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.paperEdge
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - size.width / 2, size.height / 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
