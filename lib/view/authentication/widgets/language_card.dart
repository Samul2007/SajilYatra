import 'package:flutter/material.dart';

class LanguageCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeBorder = const Color(0xFF238C78);
    final Color inactiveBorder = const Color(0xFF262D30);
    final Color activeBg = const Color(0xFF0E2623);
    final Color inactiveBg = const Color(0xFF15191B);

    return SizedBox(
      height: 58,
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? activeBorder : inactiveBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: activeBorder,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}