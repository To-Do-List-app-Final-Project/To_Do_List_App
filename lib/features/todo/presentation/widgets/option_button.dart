import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double iconSize;
  final VoidCallback? onTap;

  const OptionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    this.iconSize = 16,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasLabel = label.isNotEmpty;
    final buttonColor = color != Colors.transparent ? color.withOpacity(0.2) : Colors.transparent;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: iconSize,
              color: color != Colors.transparent ? color : Colors.grey,
            ),
            if (hasLabel) SizedBox(width: 4),
            if (hasLabel)
              Text(
                label,
                style: TextStyle(
                  color: color != Colors.transparent ? color.withOpacity(0.8) : Colors.grey,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}