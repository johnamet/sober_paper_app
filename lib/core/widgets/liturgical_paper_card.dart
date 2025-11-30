import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';

/// Determines current liturgical season
LiturgicalSeason getCurrentLiturgicalSeason() {
  final now = DateTime.now();
  final year = now.year;
  final christmas = DateTime(year, 12, 25);
  final epiphany = DateTime(year, 1, 6);
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

/// Liturgically-aware sacred paper card with animated seasonal elements
class LiturgicalPaperCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool showSacredMonogram;
  final bool showWatermarkCross;
  final double elevation;

  const LiturgicalPaperCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.showSacredMonogram = true,
    this.showWatermarkCross = true,
    this.elevation = 3,
  });

  @override
  State<LiturgicalPaperCard> createState() => _LiturgicalPaperCardState();
}

class _LiturgicalPaperCardState extends State<LiturgicalPaperCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.35).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  bool _shouldAnimate(LiturgicalSeason season) {
    return season == LiturgicalSeason.christmas ||
        season == LiturgicalSeason.christmasTide ||
        season == LiturgicalSeason.easter ||
        season == LiturgicalSeason.pentecost ||
        season == LiturgicalSeason.maryMotherOfGod;
  }

  @override
  Widget build(BuildContext context) {
    final season = getCurrentLiturgicalSeason();
    final theme = _getThemeForSeason(season);
    final shouldAnimate = _shouldAnimate(season);

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final animatedGlowOpacity = shouldAnimate ? _glowAnimation.value : 0.25;

        final card = Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.paperColor,
                theme.paperColor.withOpacity(0.97),
                theme.paperColor.withOpacity(0.99),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.borderColor, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 10),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: theme.glowColor.withOpacity(animatedGlowOpacity),
                blurRadius: 40,
                spreadRadius: shouldAnimate ? 4 : 2,
              ),
              BoxShadow(
                color: theme.accentColor.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Parchment texture with illumination
                Positioned.fill(
                  child: CustomPaint(
                    painter: ParchmentTexturePainter(
                      theme: theme,
                      season: season,
                    ),
                  ),
                ),

                // Subtle sacred watermark
                if (widget.showWatermarkCross)
                  Center(
                    child: Opacity(
                      opacity: 0.05,
                      child: Transform.rotate(
                        angle: 0.15,
                        child: Icon(
                          _getWatermarkIcon(season),
                          size: 200,
                          color: theme.accentColor,
                        ),
                      ),
                    ),
                  ),

                // Golden vine border on high feasts
                if (season == LiturgicalSeason.christmas ||
                    season == LiturgicalSeason.christmasTide ||
                    season == LiturgicalSeason.easter ||
                    season == LiturgicalSeason.pentecost ||
                    season == LiturgicalSeason.maryMotherOfGod)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: GoldenVineBorderPainter(
                        theme: theme,
                        animationValue: shouldAnimate ? _glowAnimation.value : 0.4,
                      ),
                    ),
                  ),

                // Main content
                Padding(
                  padding: widget.padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
                  child: widget.child,
                ),

                // Sacred corner fold with monogram
                if (widget.showSacredMonogram)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: CustomPaint(
                      size: const Size(48, 48),
                      painter: SacredFoldPainter(
                        theme: theme,
                        glowIntensity: shouldAnimate ? _glowAnimation.value : 0.3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );

        if (widget.onTap != null) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: widget.onTap,
              splashColor: theme.accentColor.withOpacity(0.15),
              highlightColor: theme.accentColor.withOpacity(0.08),
              child: card,
            ),
          );
        }

        return card;
      },
    );
  }

  IconData _getWatermarkIcon(LiturgicalSeason season) {
    switch (season) {
      case LiturgicalSeason.christmas:
      case LiturgicalSeason.christmasTide:
        return Icons.star;
      case LiturgicalSeason.easter:
        return Icons.wb_sunny;
      case LiturgicalSeason.pentecost:
        return Icons.local_fire_department;
      case LiturgicalSeason.marian:
      case LiturgicalSeason.maryMotherOfGod:
        return Icons.favorite;
      default:
        return Icons.add;
    }
  }
}

class _LiturgicalTheme {
  final Color paperColor;
  final Color borderColor;
  final Color glowColor;
  final Color accentColor;
  final String monogram;

  _LiturgicalTheme({
    required this.paperColor,
    required this.borderColor,
    required this.glowColor,
    required this.accentColor,
    required this.monogram,
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
        monogram: "IHS",
      );
    case LiturgicalSeason.adventLate:
    case LiturgicalSeason.christmas:
    case LiturgicalSeason.christmasTide:
      return _LiturgicalTheme(
        paperColor: const Color(0xFFFFFBF0),
        borderColor: const Color(0xFFD4AF37),
        glowColor: const Color(0xFFFFE66D),
        accentColor: const Color(0xFFFFC107),
        monogram: "ΧΡ",
      );
    case LiturgicalSeason.lent:
      return _LiturgicalTheme(
        paperColor: const Color(0xFFF2E8EB),
        borderColor: const Color(0xFF6D1A36),
        glowColor: const Color(0xFF9B3A5F),
        accentColor: const Color(0xFF8E44AD),
        monogram: "✝",
      );
    case LiturgicalSeason.holyTriduum:
      return _LiturgicalTheme(
        paperColor: const Color(0xFF2C1B1F),
        borderColor: const Color(0xFFB71C1C),
        glowColor: const Color(0xFFE53935),
        accentColor: const Color(0xFFD32F2F),
        monogram: "✝",
      );
    case LiturgicalSeason.easter:
      return _LiturgicalTheme(
        paperColor: const Color(0xFFFFFDF6),
        borderColor: const Color(0xFFFFD54F),
        glowColor: const Color(0xFFFFEB3B),
        accentColor: const Color(0xFFFFF176),
        monogram: "☧",
      );
    case LiturgicalSeason.pentecost:
      return _LiturgicalTheme(
        paperColor: const Color(0xFFFFF5F0),
        borderColor: const Color(0xFFD32F2F),
        glowColor: const Color(0xFFFF6F60),
        accentColor: const Color(0xFFFF5252),
        monogram: "🕊",
      );
    case LiturgicalSeason.marian:
    case LiturgicalSeason.maryMotherOfGod:
      return _LiturgicalTheme(
        paperColor: const Color(0xFFF5F8FC),
        borderColor: const Color(0xFF1565C0),
        glowColor: const Color(0xFF42A5F5),
        accentColor: const Color(0xFF2196F3),
        monogram: "M",
      );
    case LiturgicalSeason.ordinary:
    case LiturgicalSeason.ordinaryPreLent:
    default:
      return _LiturgicalTheme(
        paperColor: const Color(0xFFF9F9F1),
        borderColor: const Color(0xFF2E7D32),
        glowColor: const Color(0xFF66BB6A),
        accentColor: const Color(0xFF4CAF50),
        monogram: "IHS",
      );
  }
}

/// Creates elegant parchment texture with liturgical flourishes
class ParchmentTexturePainter extends CustomPainter {
  final _LiturgicalTheme theme;
  final LiturgicalSeason season;

  ParchmentTexturePainter({
    required this.theme,
    required this.season,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Aged paper texture with consistent positioning
    final texturePaint = Paint()..color = theme.accentColor.withOpacity(0.02);
    
    const seed = 12345;
    for (var i = 0; i < 150; i++) {
      final x = ((i * 47.3 + seed) % size.width.toInt()).toDouble();
      final y = ((i * 31.7 + seed) % size.height.toInt()).toDouble();
      final radius = ((i * 7) % 3 + 1).toDouble() * 0.3;
      canvas.drawCircle(Offset(x, y), radius, texturePaint);
    }

    // Illuminated corner flourishes on high feasts
    if (_isHighFeast(season)) {
      final vinePaint = Paint()
        ..color = theme.glowColor.withOpacity(0.12)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Scale flourishes relative to size
      final flourishSize = size.width * 0.08;
      final margin = size.width * 0.03;

      // Top-left flourish
      final topLeftPath = Path()
        ..moveTo(margin, margin)
        ..quadraticBezierTo(margin + flourishSize * 0.4, margin - flourishSize * 0.1, margin + flourishSize * 0.8, margin + flourishSize * 0.2)
        ..quadraticBezierTo(margin + flourishSize * 0.6, margin + flourishSize * 0.6, margin + flourishSize * 0.8, margin + flourishSize)
        ..moveTo(margin + flourishSize * 0.2, margin + flourishSize * 0.2)
        ..quadraticBezierTo(margin + flourishSize * 0.4, margin + flourishSize * 0.3, margin + flourishSize * 0.6, margin + flourishSize * 0.2);
      
      canvas.drawPath(topLeftPath, vinePaint);

      // Bottom-right flourish (mirrored)
      canvas.save();
      canvas.translate(size.width, size.height);
      canvas.rotate(3.14159);
      canvas.drawPath(topLeftPath, vinePaint);
      canvas.restore();

      // Small decorative dots
      final dotPaint = Paint()..color = theme.glowColor.withOpacity(0.15);
      final dotRadius = size.width * 0.005;
      canvas.drawCircle(Offset(margin + flourishSize * 0.4, margin + flourishSize * 0.4), dotRadius, dotPaint);
      canvas.drawCircle(Offset(size.width - margin - flourishSize * 0.4, size.height - margin - flourishSize * 0.4), dotRadius, dotPaint);
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
  bool shouldRepaint(covariant ParchmentTexturePainter oldDelegate) => false;
}

/// Sacred corner fold with illuminated monogram
class SacredFoldPainter extends CustomPainter {
  final _LiturgicalTheme theme;
  final double glowIntensity;

  SacredFoldPainter({
    required this.theme,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate fold dimensions relative to size
    final foldWidth = size.width / 1.5;
    final foldHeight = size.height / 1.5;
    
    // Main fold triangle path
    final foldPath = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - foldWidth, size.height - foldHeight)
      ..close();

    // Gradient fold with shader based on actual size
    final foldShader = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        theme.borderColor.withOpacity(0.75),
        theme.borderColor.withOpacity(0.45),
        theme.borderColor.withOpacity(0.25),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(foldPath, Paint()..shader = foldShader);

    // Fold edge highlight
    final highlightPaint = Paint()
      ..color = theme.glowColor.withOpacity(0.3 + (glowIntensity * 0.2))
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final edgePath = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width - foldWidth, size.height - foldHeight);
    
    canvas.drawPath(edgePath, highlightPaint);

    // Shadow beneath fold
    final shadowPath = Path()
      ..moveTo(size.width - 2, 2)
      ..lineTo(size.width - 2, size.height - 2)
      ..lineTo(size.width - foldWidth + 2, size.height - foldHeight + 2)
      ..close();

    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Sacred monogram with animated glow
    final textShader = LinearGradient(
      colors: [
        theme.glowColor.withOpacity(glowIntensity + 0.5),
        theme.borderColor,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final textStyle = TextStyle(
      fontSize: size.width * 0.35, // Scale with size
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      foreground: Paint()..shader = textShader,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(text: theme.monogram, style: textStyle),
    );
    
    textPainter.layout();
    
    // Position monogram in visible area of fold
    final textOffset = Offset(
      size.width - foldWidth / 2 - textPainter.width / 2,
      size.height - foldHeight / 2 - textPainter.height / 2,
    );
    
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant SacredFoldPainter oldDelegate) =>
      oldDelegate.glowIntensity != glowIntensity;
}

/// Ornate golden vine border for high feast days
class GoldenVineBorderPainter extends CustomPainter {
  final _LiturgicalTheme theme;
  final double animationValue;

  GoldenVineBorderPainter({
    required this.theme,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = theme.borderColor.withOpacity(0.35 + (animationValue * 0.15))
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = theme.glowColor.withOpacity(animationValue * 0.3)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Calculate relative spacing
    const segments = 12;
    final segmentWidth = size.width / segments;
    final vineAmplitude = size.height * 0.015;
    final margin = size.height * 0.02;
    
    // Top decorative vine
    final topPath = Path();
    for (var i = 0; i < segments; i++) {
      final x = i * segmentWidth;
      topPath.moveTo(x, margin);
      topPath.quadraticBezierTo(
        x + segmentWidth / 2, margin - vineAmplitude,
        x + segmentWidth, margin,
      );
      
      // Small leaves (scaled)
      if (i % 2 == 0) {
        final leafSize = vineAmplitude * 1.5;
        topPath.moveTo(x + segmentWidth / 2, margin - vineAmplitude);
        topPath.lineTo(x + segmentWidth / 2 - leafSize, margin - vineAmplitude * 2);
        topPath.moveTo(x + segmentWidth / 2, margin - vineAmplitude);
        topPath.lineTo(x + segmentWidth / 2 + leafSize, margin - vineAmplitude * 2);
      }
    }

    // Bottom decorative vine
    final bottomPath = Path();
    for (var i = 0; i < segments; i++) {
      final x = i * segmentWidth;
      final y = size.height - margin;
      bottomPath.moveTo(x, y);
      bottomPath.quadraticBezierTo(
        x + segmentWidth / 2, y + vineAmplitude,
        x + segmentWidth, y,
      );
      
      // Leaves on alternate segments
      if (i % 2 == 1) {
        final leafSize = vineAmplitude * 1.5;
        bottomPath.moveTo(x + segmentWidth / 2, y + vineAmplitude);
        bottomPath.lineTo(x + segmentWidth / 2 - leafSize, y + vineAmplitude * 2);
        bottomPath.moveTo(x + segmentWidth / 2, y + vineAmplitude);
        bottomPath.lineTo(x + segmentWidth / 2 + leafSize, y + vineAmplitude * 2);
      }
    }

    // Draw with glow then main line
    canvas.drawPath(topPath, glowPaint);
    canvas.drawPath(topPath, basePaint);
    canvas.drawPath(bottomPath, glowPaint);
    canvas.drawPath(bottomPath, basePaint);

    // Corner ornaments (scaled)
    final cornerRadius = size.width * 0.008;
    final cornerMargin = size.width * 0.03;
    final cornerPaint = Paint()
      ..color = theme.borderColor.withOpacity(0.4 + (animationValue * 0.2))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cornerMargin, cornerMargin), cornerRadius, cornerPaint);
    canvas.drawCircle(Offset(size.width - cornerMargin, cornerMargin), cornerRadius, cornerPaint);
    canvas.drawCircle(Offset(cornerMargin, size.height - cornerMargin), cornerRadius, cornerPaint);
    canvas.drawCircle(Offset(size.width - cornerMargin, size.height - cornerMargin), cornerRadius, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant GoldenVineBorderPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}