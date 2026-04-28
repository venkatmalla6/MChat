import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/data_provider.dart';
import '../models/farming_post.dart';

class FarmingScreen extends StatefulWidget {
  const FarmingScreen({super.key});

  @override
  State<FarmingScreen> createState() => _FarmingScreenState();
}

class _FarmingScreenState extends State<FarmingScreen> {
  FarmingCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final posts = _selectedCategory == null 
        ? data.farmingPosts 
        : data.farmingPosts.where((p) => p.category == _selectedCategory).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Farming Knowledge Hub", 
                      style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF2D5A27))),
                    Text("Techniques, tips, and seasonal guides for local farmers.", 
                      style: GoogleFonts.inter(color: Colors.grey[600])),
                  ],
                ),
                _buildCategoryFilter(),
              ],
            ),
            const SizedBox(height: 40),
            posts.isEmpty 
              ? _buildEmptyState()
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 30,
                    mainAxisSpacing: 30,
                    mainAxisExtent: 450,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, idx) => _FarmingCard(post: posts[idx]),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Row(
      children: [
        _filterChip(null, "All"),
        ...FarmingCategory.values.map((c) => _filterChip(c, c.name.toUpperCase())),
      ],
    );
  }

  Widget _filterChip(FarmingCategory? category, String label) {
    bool isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) => setState(() => _selectedCategory = val ? category : null),
        selectedColor: const Color(0xFF2D5A27).withOpacity(0.2),
        checkmarkColor: const Color(0xFF2D5A27),
        labelStyle: GoogleFonts.inter(
          color: isSelected ? const Color(0xFF2D5A27) : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Icon(Icons.agriculture, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text("No farming tips found yet.", style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey[500])),
          Text("Check back later for updates from the Agriculture Department.", style: GoogleFonts.inter(color: Colors.grey[400])),
        ],
      ),
    );
  }
}

class _FarmingCard extends StatelessWidget {
  final FarmingPost post;
  const _FarmingCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 10))],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: post.imageUrl != null && post.imageUrl!.isNotEmpty 
              ? Image.network(post.imageUrl!, height: 200, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_,__,___) => _placeholder())
              : _placeholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D5A27).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(post.category.name.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF2D5A27), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 15),
                Text(
                  post.title,
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  post.description,
                  style: GoogleFonts.inter(color: Colors.grey[600], height: 1.5),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () => _showDetails(context),
                  icon: const Icon(Icons.read_more, size: 20),
                  label: const Text("READ FULL GUIDE"),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF2D5A27)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey[200],
      child: Icon(Icons.grass, size: 50, color: Colors.grey[400]),
    );
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(post.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(post.imageUrl!, width: double.infinity, fit: BoxFit.cover),
                ),
              const SizedBox(height: 20),
              Text(post.description, style: GoogleFonts.inter(fontSize: 16, height: 1.6)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }
}
