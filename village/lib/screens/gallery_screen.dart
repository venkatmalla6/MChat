import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../widgets/gallery_card.dart';
import '../widgets/footer.dart';
import 'home_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    final allGalleryItems = Provider.of<DataProvider>(context).galleryItems;
    final filteredItems = _selectedCategory == "All"
        ? allGalleryItems
        : allGalleryItems.where((item) => item.category == _selectedCategory).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPageHeader("Village Gallery"),
          const SizedBox(height: 40),
          MaxWidthContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildCategoryFilter(),
                  const SizedBox(height: 40),
                  filteredItems.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 80.0),
                            child: Text(
                              "No images in the gallery yet.",
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
                            crossAxisCount: isDesktop ? 4 : 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1,
                          ),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            return GalleryCard(item: filteredItems[index])
                                .animate(key: ValueKey("${_selectedCategory}_$index"))
                                .fadeIn(delay: (index * 100).ms, duration: 500.ms)
                                .scale(begin: const Offset(0.8, 0.8));
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

  Widget _buildCategoryFilter() {
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      alignment: WrapAlignment.center,
      children: ["All", "Events", "Places"].map((category) {
        bool isSelected = _selectedCategory == category;
        return ChoiceChip(
          label: Text(
            category,
            style: GoogleFonts.inter(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : const Color(0xFF2D5A27),
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedCategory = category);
            }
          },
          selectedColor: const Color(0xFF2D5A27),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF2D5A27)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        );
      }).toList(),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2);
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
