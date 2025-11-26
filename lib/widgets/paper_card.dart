import 'package:flutter/material.dart';

class PaperCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const PaperCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x16000000),
              offset: Offset(0, 6),
              blurRadius: 12,
            )
          ],
          image: const DecorationImage(
            image: AssetImage('assets/paper_bg.png'),
            fit: BoxFit.cover,
            opacity: 0.06,
          ),
          border: Border(left: BorderSide(color: Color(0xFFDAA77A), width: 4)),
        ),
        child: child,
      ),
    );
  }
}
