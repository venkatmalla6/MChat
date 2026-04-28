import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/footer.dart';
import 'home_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPageHeader("About Our Village", context),
          _buildContentSection(
            context,
            isDesktop,
            "History of Somarayanampeta",
            "Somarayanampeta has a rich history that traces back several centuries. "
            "Part of the historically significant East Godavari region, our village has thrived "
            "under various local administrations. The name itself reflects its heritage, "
            "often associated with local legends and the deity Somanarayana. Through the "
            "years, it has remained a central point for agricultural trade in the Kirlampudi mandal.",
            Icons.history_edu,
            true,
          ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(begin: 0.1),
          _buildContentSection(
            context,
            isDesktop,
            "Culture & Traditions",
            "Our culture is deeply rooted in the traditions of the Godavari Delta. "
            "From the vibrant Sankranti celebrations with Gobbemmalu and Haridasu, "
            "to the localized Jatara festivals, every month brings a celebration of life. "
            "The community is bound together by Telugu heritage, folk music, "
            "and a strong sense of hospitality towards every visitor.",
            Icons.festival,
            false,
          ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideY(begin: 0.1),
          _buildContentSection(
            context,
            isDesktop,
            "Agriculture & Economy",
            "Somarayanampeta is primarily an agricultural village. The fertile soil and "
            "well-maintained irrigation canals from the Godavari river enable our farmers "
            "to cultivate high-quality paddy and other crops. Our village serves as a "
            "heartbeat for the local economy, providing livelihoods and sustenance "
            "to thousands of families.",
            Icons.agriculture,
            true,
          ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideY(begin: 0.1),
          const VillageFooter(),
        ],
      ),
    );
  }

  Widget _buildPageHeader(String title, BuildContext context) {
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

  Widget _buildContentSection(
    BuildContext context,
    bool isDesktop,
    String title,
    String content,
    IconData icon,
    bool reversed,
  ) {
    Widget imagePlaceholder = Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2D5A27).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, size: 100, color: const Color(0xFF2D5A27).withOpacity(0.3)),
    );

    Widget textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D5A27),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 18,
            height: 1.8,
            color: Colors.black87,
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: MaxWidthContainer(
        child: isDesktop
            ? Row(
                children: [
                  if (!reversed) Expanded(child: imagePlaceholder),
                  if (!reversed) const SizedBox(width: 60),
                  Expanded(child: textContent),
                  if (reversed) const SizedBox(width: 60),
                  if (reversed) Expanded(child: imagePlaceholder),
                ],
              )
            : Column(
                children: [
                  imagePlaceholder,
                  const SizedBox(height: 40),
                  textContent,
                ],
              ),
      ),
    );
  }
}
