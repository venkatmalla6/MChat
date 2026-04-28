import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../widgets/service_card.dart';
import '../widgets/footer.dart';
import 'home_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    final services = Provider.of<DataProvider>(context).services;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPageHeader("Village Services"),
          const SizedBox(height: 60),
          MaxWidthContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Essential Directory",
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D5A27),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1),
                  const SizedBox(height: 10),
                  Text(
                    "Contact details for schools, hospitals, and local businesses in our area",
                    style: GoogleFonts.inter(color: Colors.grey[600]),
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                  const SizedBox(height: 40),
                  services.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 80.0),
                            child: Text(
                              "No service listings available yet.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ).animate().fadeIn(),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isDesktop ? 2 : 1,
                            crossAxisSpacing: 30,
                            mainAxisSpacing: 30,
                            mainAxisExtent: 180,
                          ),
                          itemCount: services.length,
                          itemBuilder: (context, index) {
                            return ServiceCard(service: services[index])
                                .animate()
                                .fadeIn(delay: (index * 150).ms, duration: 600.ms)
                                .scale(begin: const Offset(0.9, 0.9));
                          },
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
          const VillageFooter(),
        ],
      ),
    );
  }

  Widget _buildPageHeader(String title) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF2D5A27),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),
      ),
    );
  }
}
