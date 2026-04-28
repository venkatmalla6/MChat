import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event.dart';
import '../widgets/footer.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EventDetailsScreen extends StatelessWidget {
  final VillageEvent event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2D5A27),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Header
            Hero(
              tag: 'event-${event.id}',
              child: Container(
                height: isDesktop ? 500 : 300,
                width: double.infinity,
                child: _buildHeaderImage(VillageEvent.getAutoImage(event.imageUrl, event.type)),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? MediaQuery.of(context).size.width * 0.15 : 20,
                vertical: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and Title
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF2D5A27), size: 20),
                      const SizedBox(width: 10),
                      Text(
                        event.date,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ).animate().fadeIn().slideX(begin: -0.2),
                  const SizedBox(height: 15),
                  Text(
                    event.title,
                    style: GoogleFonts.outfit(
                      fontSize: isDesktop ? 48 : 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D5A27),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 30),

                  // Description
                  Text(
                    "About this event",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    event.description,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      height: 1.8,
                      color: Colors.black87,
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  // Additional Images Gallery
                  if (event.additionalImages.isNotEmpty) ...[
                    const SizedBox(height: 50),
                    Text(
                      "Event Gallery",
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 3 : 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: event.additionalImages.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => _showFullScreenImage(context, event.additionalImages[index]),
                            child: Image.network(
                              event.additionalImages[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                          ),
                        ).animate().scale(delay: (600 + (index * 100)).ms);
                      },
                    ),
                  ],
                ],
              ),
            ),
            const VillageFooter(),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: Image.network(url, fit: BoxFit.contain),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorPlaceholder(),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[100],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (_, __, ___) => _errorPlaceholder(),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
    );
  }
}
