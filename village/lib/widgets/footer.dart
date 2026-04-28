import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VillageFooter extends StatelessWidget {
  const VillageFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1B3D16),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Text(
            "Somarayanampeta Gram Panchayat",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Kirlampudi Mandal, East Godavari, Andhra Pradesh - 533431",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),
          Text(
            "© 2026 Somarayanampeta Village. Built with pride for our community.",
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
