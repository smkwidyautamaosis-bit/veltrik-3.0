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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.picture_as_pdf,
                color: VeltrikColors.cyanAccent,
                size: 35,
              ),
              const Spacer(),
              Text(
                material.title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: VeltrikColors.navyBase),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 35,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [VeltrikColors.cyanAccent, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    "UNLOCK",
                    style: TextStyle(
                      color: VeltrikColors.navyBase,
                      fontWeight: FontWeight.bold,
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
