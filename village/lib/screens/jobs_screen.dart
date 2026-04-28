import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/job_card.dart';
import '../widgets/footer.dart';
import '../providers/data_provider.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    final jobs = context.watch<DataProvider>().jobs;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPageHeader("Local Opportunities"),
          const SizedBox(height: 60),
          MaxWidthContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Job Openings in Somarayanampeta",
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D5A27),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1),
                  const SizedBox(height: 10),
                  Text(
                    "Find local work and contribute to our village development",
                    style: GoogleFonts.inter(color: Colors.grey[600]),
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                  const SizedBox(height: 40),
                  jobs.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 80.0),
                            child: Text(
                              "No job openings available right now. Please check back later!",
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
                            mainAxisExtent: 300,
                          ),
                          itemCount: jobs.length,
                          itemBuilder: (context, index) {
                            return JobCard(job: jobs[index])
                                .animate()
                                .fadeIn(delay: (index * 150).ms, duration: 600.ms)
                                .slideY(begin: 0.2);
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
