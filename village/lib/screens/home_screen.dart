import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_data.dart';
import '../models/event.dart';
import '../widgets/announcement_item.dart';
import '../widgets/footer.dart';
import '../providers/data_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section
          _buildHero(context, isDesktop),
          
          // Announcements Section
          _buildAnnouncements(context, isDesktop),

          // Village Quick Facts
          _buildQuickFacts(context, isDesktop),

          const VillageFooter(),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool isDesktop) {
    return Container(
      height: isDesktop ? 600 : 400,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/hero_village.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Experience the Heart of Andhra Pradesh",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: isDesktop ? 24 : 18,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(duration: 600.ms).slide(begin: const Offset(0, 0.2)).scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(height: 10),
            Text(
              MockData.villageName,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: isDesktop ? 72 : 48,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2),
            const SizedBox(height: 20),
            SizedBox(
              width: isDesktop ? 600 : double.infinity,
              child: Text(
                MockData.villageIntro,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isDesktop ? 20 : 16,
                  height: 1.6,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncements(BuildContext context, bool isDesktop) {
    final events = Provider.of<DataProvider>(context).events;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      color: Colors.grey[50],
      child: MaxWidthContainer(
        child: Column(
          children: [
            Text(
              "Latest Announcements",
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D5A27),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Stay updated with what's happening in Somarayanampeta",
              style: GoogleFonts.inter(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 3 : 1,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                mainAxisExtent: 320,
              ),
              itemCount: events.length > 3 ? 3 : events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return AnnouncementItem(
                  title: event.title,
                  date: event.date,
                  content: event.description,
                  imageUrl: VillageEvent.getAutoImage(event.imageUrl, event.type),
                )
                    .animate()
                    .fadeIn(delay: (index * 100).ms, duration: 500.ms)
                    .slideY(begin: 0.1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFacts(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: MaxWidthContainer(
        child: Wrap(
          spacing: 40,
          runSpacing: 40,
          alignment: WrapAlignment.center,
          children: [
            _factItem(Icons.people, "2,500+", "Population", 0),
            _factItem(Icons.water_drop, "Irrigated", "Agriculture", 1),
            _factItem(Icons.school, "Lush", "Nature", 2),
            _factItem(Icons.health_and_safety, "Peaceful", "Environment", 3),
          ],
        ),
      ),
    );
  }

  Widget _factItem(IconData icon, String value, String label, int index) {
    return SizedBox(
      width: 150,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2D5A27).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF2D5A27), size: 30),
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D5A27),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    ).animate().scale(delay: (index * 100).ms, duration: 400.ms, curve: Curves.easeOutBack).fadeIn();
  }
}

class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  const MaxWidthContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: child,
      ),
    );
  }
}
