import 'package:flutter/material.dart';
import 'package:sajilyatra/constants/app_colors.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String caption;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kViolet, size: 20),
          const SizedBox(height: 10),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: kText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(caption,
              maxLines: 2,
              style: const TextStyle(color: kMuted, fontSize: 11.5)),
        ],
      ),
    );
  }
}
