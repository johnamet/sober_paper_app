import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_shadows.dart';
import '../constants/app_spacing.dart';

/// Determines current liturgical season
LiturgicalSeason getCurrentLiturgicalSeason() {
  final now = DateTime.now();
  final year = now.year;
  final christmas = DateTime(year, 12, 25);
  final ashWednesday = _easterDate(year).subtract(const Duration(days: 46));
  final easter = _easterDate(year);
  final pentecost = easter.add(const Duration(days: 49));

  // Special Marian months
  bool isMay = now.month == 5;
  bool isOctober = now.month == 10;

  // Major solemnities override
  if (now.month == 12 && now.day >= 17 && now.day <= 24) return LiturgicalSeason.adventLate;
  if ((now.month == 12 && now.day >= 25) || (now.month == 1 && now.day <= 5)) return LiturgicalSeason.christmas;
  if (now.month == 1 && now.day == 1) return LiturgicalSeason.maryMotherOfGod;
  if (_isCloseTo(easter, now, days: 3)) return LiturgicalSeason.holyTriduum;
  if (_isCloseTo(easter, now)) return LiturgicalSeason.easter;
  if (_isCloseTo(pentecost, now)) return LiturgicalSeason.pentecost;

  if (now.isAfter(ashWednesday.subtract(const Duration(days: 4))) && now.isBefore(ashWednesday))
    return LiturgicalSeason.ordinaryPreLent;
  if (now.isAfter(ashWednesday.subtract(const Duration(days: 1))) && now.isBefore(easter))
    return LiturgicalSeason.lent;
  if (now.isAfter(christmas.subtract(const Duration(days: 30))) && now.isBefore(ashWednesday))
    return LiturgicalSeason.christmasTide;
  if (now.isAfter(pentecost) || (now.month <= 2 && now.isBefore(ashWednesday)))
    return isMay || isOctober ? LiturgicalSeason.marian : LiturgicalSeason.ordinary;

  return LiturgicalSeason.advent;
}

bool _isCloseTo(DateTime date, DateTime now, {int days = 7}) {
  return (now.difference(date).inDays).abs() <= days;
}

DateTime _easterDate(int year) {
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = (19 * a + b - b ~/ 4 - ((b - (b + 8) ~/ 25 + 1) ~/ 3) + 15) % 30;
  final e = (32 + 2 * (b % 4) + 2 * (c ~/ 4) - d - (c % 4)) % 7;
  final f = d + e - 7 * ((a + 11 * d + 22 * e) ~/ 451) + 114;
  final month = f ~/ 31;
  final day = f % 31 + 1;
  return DateTime(year, month, day);
}

enum LiturgicalSeason {
  advent,
  adventLate,
  christmas,
  christmasTide,
  ordinary,
  ordinaryPreLent,
  lent,
  holyTriduum,
  easter,
  pentecost,
  marian,
  maryMotherOfGod,
}

/// Enhanced PaperCard with liturgical awareness and elegant paper aesthetic
class PaperCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;
  final bool hasCornerFold;
  final double elevation;
  final bool useLiturgicalColors;

  const PaperCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.shadows,
    this.hasCornerFold = false,
    this.elevation = 2,
    this.useLiturgicalColors = true,
  });

  @override
  Widget build(BuildContext context) {
    final season = getCurrentLiturgicalSeason();
    final theme = _getThemeForSeason(season);
    final useSeasonalColors = useLiturgicalColors && backgroundColor == null;

    final cardContent = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? (useSeasonalColors ? theme.paperColor : AppColors.paperWhite),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: shadows ?? _buildElevationShadow(theme, useSeasonalColors),
        border: Border.all(
          color: useSeasonalColors 
              ? theme.borderColor.withOpacity(0.4)
              : AppColors.paperEdge.withOpacity(0.3),
          width: useSeasonalColors ? 1.0 : 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: [
            // Subtle paper texture overlay
            Positioned.fill(
              child: CustomPaint(
                painter: PaperTexturePainter(
                  accentColor: useSeasonalColors ? theme.accentColor : AppColors.paperEdge,
                  season: season,
                  useLiturgical: useSeasonalColors,
                ),
              ),
            ),
            // Content
            Padding(
              padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
              child: child,
            ),
            // Corner fold (if enabled)
            if (hasCornerFold)
              Positioned(
                top: 0,
                right: 0,
                child: CustomPaint(
                  size: const Size(28, 28),
                  painter: CornerFoldPainter(
                    theme: useSeasonalColors ? theme : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          splashColor: (useSeasonalColors ? theme.accentColor : AppColors.holyBlue)
              .withOpacity(0.1),
          highlightColor: (useSeasonalColors ? theme.accentColor : AppColors.holyBlue)
              .withOpacity(0.05),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }

  List<BoxShadow> _buildElevationShadow(_LiturgicalTheme theme, bool useSeasonal) {
    final glowColor = useSeasonal ? theme.glowColor : Colors.black;
    
    switch (elevation.toInt()) {
      case 1:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
          if (useSeasonal)
            BoxShadow(
              color: glowColor.withOpacity(0.08),
              blurRadius: 6,
              spreadRadius: 0,
            ),
        ];
      case 2:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          if (useSeasonal)
            BoxShadow(
              color: glowColor.withOpacity(0.12),
              blurRadius: 12,
              spreadRadius: 1,
            ),
        ];
      case 3:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          if (useSeasonal)
            BoxShadow(
              color: glowColor.withOpacity(0.15),
              blurRadius: 16,
              spreadRadius: 2,
            ),
        ];
      case 4:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          if (useSeasonal)
            BoxShadow(
              color: glowColor.withOpacity(0.18),
              blurRadius: 20,
              spreadRadius: 3,
            ),
        ];
      default:
        return AppShadows.card;
    }
  }
}

class _LiturgicalTheme {
  final Color paperColor;
  final Color borderColor;
  final Color glowColor;
  final Color accentColor;

  _LiturgicalTheme({
    required this.paperColor,
    required this.borderColor,
    required this.glowColor,
    required this.accentColor,
  });
}

_LiturgicalTheme _getThemeForSeason(LiturgicalSeason season) {
  switch (season) {
    case LiturgicalSeason.advent:
      return _LiturgicalTheme(
        paperColor: const Color(0xFFF8F5F2),
        borderColor: const Color(0xFF5B2A86),
        glowColor: const Color(0xFF9C5FB8),
        accentColor: const Color(0xFF7D3C98),
      );
    case LiturgicalSeason.adventLate:
    case LiturgicalSeason.christmas:
    case LiturgicalSeason.christmasTide:
      return _LiturgicalTheme(
        paperColor: const Color(0xFFFFFBF0),
        borderColor: const Color(0xFFD4AF37),
        glowColor: const Color(0xFFFFE66D),
        accentColor: const Color(0xFFFFC107),
      );
    case LiturgicalSeason.lent:
      return _LiturgicalTheme(
        paperColor: const Color(0xFFF2E8EB),
        borderColor: const Color(0xFF6D1A36),
        glowColor: const Color(0xFF9B3A5F),
        accentColor: const Color(0xFF8E44AD),
      );
    case LiturgicalSeason.holyTriduum:
      return _LiturgicalTheme(
        paperColor: const Color(0xFF2C1B1F),
        borderColor: const Color(0xFFB71C1C),
        glowColor: const Color(0xFFE53935),
        accentColor: const Color(0xFFD32F2F),
      );
    case LiturgicalSeason.easter:
      return _LiturgicalTheme(
        paperColor: const Color(0xFFFFFDF6),
        borderColor: const Color(0xFFFFD54F),
        glowColor: const Color(0xFFFFEB3B),
        accentColor: const Color(0xFFFFF176),
      );
    case LiturgicalSeason.pentecost:
      return _LiturgicalTheme(
        paperColor: const Color(0xFFFFF5F0),
        borderColor: const Color(0xFFD32F2F),
        glowColor: const Color(0xFFFF6F60),
        accentColor: const Color(0xFFFF5252),
      );
    case LiturgicalSeason.marian:
    case LiturgicalSeason.maryMotherOfGod:
      return _LiturgicalTheme(
        paperColor: const Color(0xFFF5F8FC),
        borderColor: const Color(0xFF1565C0),
        glowColor: const Color(0xFF42A5F5),
        accentColor: const Color(0xFF2196F3),
      );
    case LiturgicalSeason.ordinary:
    case LiturgicalSeason.ordinaryPreLent:
    default:
      return _LiturgicalTheme(
        paperColor: const Color(0xFFF9F9F1),
        borderColor: const Color(0xFF2E7D32),
        glowColor: const Color(0xFF66BB6A),
        accentColor: const Color(0xFF4CAF50),
      );
  }
}

/// Enhanced painter for corner fold effect with liturgical colors
class CornerFoldPainter extends CustomPainter {
  final _LiturgicalTheme? theme;

  CornerFoldPainter({this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final foldWidth = size.width / 1.8;
    final foldHeight = size.height / 1.8;

    final baseColor = theme?.borderColor ?? AppColors.paperEdge;

    // Main fold with gradient
    final foldPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          baseColor.withOpacity(0.5),
          baseColor.withOpacity(0.25),
          baseColor.withOpacity(0.1),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final foldPath = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - foldWidth, size.height - foldHeight)
      ..close();

    canvas.drawPath(foldPath, foldPaint);

    // Fold shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final shadowPath = Path()
      ..moveTo(size.width - 2, 2)
      ..lineTo(size.width - 2, size.height - 2)
      ..lineTo(size.width - foldWidth + 2, size.height - foldHeight + 2)
      ..close();

    canvas.drawPath(shadowPath, shadowPaint);

    // Fold highlight with liturgical accent
    final highlightPaint = Paint()
      ..color = (theme?.glowColor ?? Colors.white).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final highlightPath = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width - foldWidth, size.height - foldHeight);

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CornerFoldPainter oldDelegate) =>
      oldDelegate.theme != theme;
}

/// Enhanced painter for subtle paper texture with liturgical flourishes
class PaperTexturePainter extends CustomPainter {
  final Color accentColor;
  final LiturgicalSeason season;
  final bool useLiturgical;

  PaperTexturePainter({
    required this.accentColor,
    required this.season,
    required this.useLiturgical,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle aged paper texture
    final texturePaint = Paint()
      ..color = accentColor.withOpacity(0.015)
      ..style = PaintingStyle.fill;

    const seed = 12345;
    for (var i = 0; i < 80; i++) {
      final x = ((i * 37.5 + seed) % size.width.toInt()).toDouble();
      final y = ((i * 23.7 + seed) % size.height.toInt()).toDouble();
      final radius = ((i * 7) % 3 + 1).toDouble() * 0.4;
      canvas.drawCircle(Offset(x, y), radius, texturePaint);
    }

    // Very subtle horizontal lines (like ruled paper)
    final linePaint = Paint()
      ..color = accentColor.withOpacity(0.02)
      ..strokeWidth = 0.5;

    for (var y = 0.0; y < size.height; y += 24) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }

    // Add subtle liturgical flourishes on high feasts
    if (useLiturgical && _isHighFeast(season)) {
      final flourishPaint = Paint()
        ..color = accentColor.withOpacity(0.08)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final margin = size.width * 0.04;
      final flourishSize = size.width * 0.06;

      // Delicate corner flourishes
      final flourishPath = Path()
        ..moveTo(margin, margin + flourishSize * 0.5)
        ..quadraticBezierTo(
          margin + flourishSize * 0.3,
          margin,
          margin + flourishSize * 0.7,
          margin + flourishSize * 0.3,
        );

      canvas.drawPath(flourishPath, flourishPaint);

      // Mirror in bottom-right
      canvas.save();
      canvas.translate(size.width, size.height);
      canvas.rotate(3.14159);
      canvas.drawPath(flourishPath, flourishPaint);
      canvas.restore();

      // Small decorative dots
      final dotPaint = Paint()
        ..color = accentColor.withOpacity(0.12)
        ..style = PaintingStyle.fill;
      
      final dotRadius = size.width * 0.003;
      canvas.drawCircle(
        Offset(margin + flourishSize * 0.5, margin + flourishSize * 0.3),
        dotRadius,
        dotPaint,
      );
      canvas.drawCircle(
        Offset(size.width - margin - flourishSize * 0.5, size.height - margin - flourishSize * 0.3),
        dotRadius,
        dotPaint,
      );
    }
  }

  bool _isHighFeast(LiturgicalSeason season) {
    return season == LiturgicalSeason.christmas ||
        season == LiturgicalSeason.christmasTide ||
        season == LiturgicalSeason.easter ||
        season == LiturgicalSeason.pentecost ||
        season == LiturgicalSeason.maryMotherOfGod;
  }

  @override
  bool shouldRepaint(covariant PaperTexturePainter oldDelegate) =>
      oldDelegate.accentColor != accentColor ||
      oldDelegate.season != season ||
      oldDelegate.useLiturgical != useLiturgical;
}