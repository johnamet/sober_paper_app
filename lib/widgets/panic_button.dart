import 'package:flutter/material.dart';

class PanicButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PanicButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFDB6A3A),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(blurRadius: 18, color: Color(0x22000000), offset: Offset(0,8))
          ],
        ),
        child: Center(
          child: Text(
            'PANIC',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
