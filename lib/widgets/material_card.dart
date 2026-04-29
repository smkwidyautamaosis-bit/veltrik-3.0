import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/material_model.dart';

class MaterialCard extends StatelessWidget {
  final MaterialModel material;
  final VoidCallback onTap;

  const MaterialCard({super.key, required this.material, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: VeltrikColors.navyBase.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Identitas Visual Premium (Menggantikan Icon PDF)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: VeltrikColors.cyanAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/images/icon.png',
                    height: 22,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.security,
                      size: 22,
                      color: VeltrikColors.cyanAccent,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  material.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: VeltrikColors.navyBase,
                    fontSize: 13,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Tombol Access Premium Style
                Container(
                  width: double.infinity,
                  height: 32,
                  decoration: BoxDecoration(
                    color: VeltrikColors.navyBase,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      "ACCESS",
                      style: TextStyle(
                        color: VeltrikColors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
