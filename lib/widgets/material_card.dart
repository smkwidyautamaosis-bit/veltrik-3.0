import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/material_model.dart';

class MaterialCard extends StatelessWidget {
  final MaterialModel material;
  final VoidCallback onTap;

  const MaterialCard({super.key, required this.material, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
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
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
              ),
              const SizedBox(height: 5),
              Text(
                "Rp ${material.price}",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 35,
                decoration: BoxDecoration(
                  color: VeltrikColors.cyanAccent,
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
    );
  }
}
