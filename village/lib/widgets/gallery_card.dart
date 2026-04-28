import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/gallery_item.dart';
import '../utils/url_helper.dart';

class GalleryCard extends StatefulWidget {
  final GalleryImage item;

  const GalleryCard({super.key, required this.item});

  @override
  State<GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<GalleryCard> {
  bool _isHovered = false;
  int _currentViewIndex = 0;

  void _showImageDialog(BuildContext context) {
    _currentViewIndex = 0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main Viewer
              Flexible(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: widget.item.images.isEmpty 
                          ? Image.asset('assets/images/placeholder.jpg', fit: BoxFit.contain)
                          : Image.network(
                              widget.item.images[_currentViewIndex],
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator(color: Colors.white));
                              },
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50, color: Colors.white),
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      style: IconButton.styleFrom(backgroundColor: Colors.black45),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 15),

              // Info & Thumbnails Bar
              Container(
                constraints: const BoxConstraints(maxWidth: 900),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF2D5A27)),
                    ),
                    if (widget.item.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          widget.item.description,
                          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ),
                    
                    if (widget.item.images.length > 1) ...[
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.item.images.length,
                          itemBuilder: (context, idx) => GestureDetector(
                            onTap: () => setDialogState(() => _currentViewIndex = idx),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 10),
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _currentViewIndex == idx ? const Color(0xFF2D5A27) : Colors.transparent,
                                  width: 3,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(widget.item.images[idx]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageDialog(context),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Folder/Stack Effect Layers back
              Positioned(
                top: -5,
                left: 5,
                right: 5,
                bottom: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                  ),
                ),
              ),
              Positioned(
                top: -10,
                left: 10,
                right: 10,
                bottom: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[100]!),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                  ),
                ),
              ),

              // Main Master Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Image Area
                    Expanded(
                      flex: 3,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: widget.item.imageUrl.startsWith('http')
                                ? Image.network(
                                    widget.item.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[100]),
                                  )
                                : Image.asset(
                                    widget.item.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                          ),
                          // Photo Count Badge
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.photo_library, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${widget.item.images.length} Photos",
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Info Area (Always Visible)
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D5A27),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.item.description.isNotEmpty 
                                ? widget.item.description 
                                : "Explore this village collection",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey[600],
                                height: 1.3,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Icon(Icons.label_outline, size: 12, color: Colors.grey[400]),
                                const SizedBox(width: 4),
                                Text(
                                  widget.item.category,
                                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
