import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class VillageMapScreen extends StatefulWidget {
  const VillageMapScreen({super.key});

  @override
  State<VillageMapScreen> createState() => _VillageMapScreenState();
}

class _VillageMapScreenState extends State<VillageMapScreen> {
  final String _viewType = 'leaflet-map-view';
  bool _isBottomSheetOpen = false;
  bool _isRegistered = false;

  final List<Map<String, dynamic>> _places = [
    {'name': 'Somarayanampeta Center', 'lat': 17.0287, 'lng': 81.7749, 'type': 'Village', 'info': 'The heart of our peaceful village.', 'icon': Icons.location_city},
    {'name': 'Village Primary School', 'lat': 17.0275, 'lng': 81.7740, 'type': 'School', 'info': 'Education for our bright future.', 'icon': Icons.school},
    {'name': 'Community Health Center', 'lat': 17.0298, 'lng': 81.7760, 'type': 'Hospital', 'info': '24/7 care for all residents.', 'icon': Icons.medical_services},
    {'name': 'Ravi Kirana Store', 'lat': 17.0305, 'lng': 81.7735, 'type': 'Shop', 'info': 'Fresh groceries and daily essentials.', 'icon': Icons.shopping_cart},
    {'name': 'Farmer Coop Society', 'lat': 17.0260, 'lng': 81.7780, 'type': 'Business', 'info': 'Supporting local agricultural growth.', 'icon': Icons.agriculture},
  ];

  @override
  void initState() {
    super.initState();
    _registerMapView();
  }

  void _registerMapView() {
    if (_isRegistered) return;
    _isRegistered = true;

    final markersJs = _places.map((p) => '''
      L.marker([${p['lat']}, ${p['lng']}])
        .addTo(map)
        .bindPopup("<b>${p['name']}</b><br>${p['type']}");
    ''').join('\n');

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin=""/>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { width: 100vw; height: 100vh; overflow: hidden; }
    #map { width: 100%; height: 100%; }
    .leaflet-popup-content b { color: #2D5A27; }
  </style>
</head>
<body>
  <div id="map"></div>
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
  <script>
    var map = L.map('map', { zoomControl: true }).setView([17.0287, 81.7749], 16);

    L.tileLayer('https://api.maptiler.com/maps/hybrid-v4/256/{z}/{x}/{y}.jpg?key=T78RzVQPMRleZnEmXgxC', {
      attribution: '&copy; <a href="https://www.maptiler.com/">MapTiler</a> &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      tileSize: 256,
      crossOrigin: true
    }).addTo(map);

    var greenIcon = new L.Icon({
      iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
      shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41]
    });

    $markersJs
  </script>
</body>
</html>
''';

    final blob = html.Blob([htmlContent], 'text/html');
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);

    ui.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = blobUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true;
        return iframe;
      },
    );
  }

  void _showPlaceDetails(Map<String, dynamic> place) {
    setState(() => _isBottomSheetOpen = true);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      useRootNavigator: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D5A27).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    place['type'].toString().toUpperCase(),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF2D5A27),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              place['name'],
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              place['info'],
              style: GoogleFonts.inter(fontSize: 15, color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final lat = place['lat'] as double;
                      final lng = place['lng'] as double;
                      final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
                      html.window.open(url, '_blank');
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text("Get Directions"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5A27),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _isBottomSheetOpen = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Explore Village Map",
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D5A27),
                  ),
                ),
                Text(
                  "Locate important places in Somarayanampeta",
                  style: GoogleFonts.inter(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Place chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _places.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final place = _places[index];
                return ActionChip(
                  avatar: Icon(place['icon'] as IconData, size: 16, color: const Color(0xFF2D5A27)),
                  label: Text(
                    place['name'],
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF2D5A27)),
                  ),
                  backgroundColor: const Color(0xFF2D5A27).withOpacity(0.08),
                  onPressed: () => _showPlaceDetails(place),
                  side: BorderSide(color: const Color(0xFF2D5A27).withOpacity(0.2)),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Leaflet Map
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: Stack(
                children: [
                  HtmlElementView(viewType: _viewType),
                  // Transparent overlay blocks iframe pointer events when bottom sheet is open
                  if (_isBottomSheetOpen)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {},
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
