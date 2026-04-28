import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/event_card.dart';
import '../widgets/footer.dart';
import '../providers/data_provider.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    final events = Provider.of<DataProvider>(context).events;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPageHeader("Village Events"),
          const SizedBox(height: 60),
          MaxWidthContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: events.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 80.0),
                        child: Text(
                          "No events scheduled at the moment. Check back later!",
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
                        crossAxisCount: isDesktop ? 3 : 1,
                        crossAxisSpacing: 30,
                        mainAxisSpacing: 30,
                        mainAxisExtent: 450,
                      ),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return EventCard(event: events[index])
                            .animate()
                            .fadeIn(delay: (index * 150).ms, duration: 600.ms)
                            .slideY(begin: 0.2);
                      },
                    ),
            ),
          ),
          const SizedBox(height: 80),
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
