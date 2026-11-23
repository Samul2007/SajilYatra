import 'package:flutter/material.dart';
import 'package:sajilyatra/constants/app_colors.dart';

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
    final Color activeBorder = kAccent;
    final Color inactiveBorder = kBorder;
    final Color activeBg = kCardActive;
    final Color inactiveBg = kCard;

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
                  color: kText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: kViolet,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}