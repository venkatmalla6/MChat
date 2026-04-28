import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VillageNavBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const VillageNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      title: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF2D5A27)),
          const SizedBox(width: 8),
          Text(
            "Somarayanampeta",
            style: GoogleFonts.outfit(
              color: const Color(0xFF2D5A27),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
      actions: isDesktop
          ? [
              _navButton("Home", 0),
              _navButton("About", 1),
              _navButton("Events", 2),
              _navButton("Jobs", 3),
              _navButton("Services", 4),
              _navButton("Gallery", 5),
              _navButton("Map", 6),
              _navButton("Farming", 7),
              _navButton("Quiz", 8),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/admin/login'),
                icon: const Icon(Icons.admin_panel_settings, color: Color(0xFF2D5A27)),
                tooltip: "Admin Portal",
              ),
              const SizedBox(width: 20),
            ]
          : null,
    );
  }

  Widget _navButton(String label, int index) {
    bool isSelected = selectedIndex == index;
    return TextButton(
      onPressed: () => onDestinationSelected(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? const Color(0xFF2D5A27) : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class VillageDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const VillageDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2D5A27)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 40),
                const SizedBox(height: 10),
                Text(
                  "Somarayanampeta",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(Icons.home, "Home", 0),
          _drawerItem(Icons.info, "About", 1),
          _drawerItem(Icons.event, "Events", 2),
          _drawerItem(Icons.work, "Jobs", 3),
          _drawerItem(Icons.home_repair_service, "Services", 4),
          _drawerItem(Icons.photo_library, "Gallery", 5),
          _drawerItem(Icons.map_outlined, "Village Map", 6),
          _drawerItem(Icons.agriculture_outlined, "Farming", 7),
          _drawerItem(Icons.quiz_outlined, "Quiz", 8),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF2D5A27)),
            title: Text("Admin Portal", style: GoogleFonts.inter()),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int index) {
    bool isSelected = selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF2D5A27) : null),
      title: Text(label, style: GoogleFonts.inter(fontWeight: isSelected ? FontWeight.bold : null)),
      selected: isSelected,
      onTap: () {
        onDestinationSelected(index);
      },
    );
  }
}
