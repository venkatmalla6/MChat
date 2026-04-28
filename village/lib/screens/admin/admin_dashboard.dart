import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/event.dart';
import '../../models/job.dart';
import '../../models/service.dart';
import '../../models/gallery_item.dart';
import '../../models/farming_post.dart';
import '../../models/quiz_question.dart';
import '../../utils/url_helper.dart';
import 'package:image_picker/image_picker.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    // Simple route protection (Redirect if not logged in)
    if (!auth.isLoggedIn) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/admin/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2D5A27),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => auth.logout(),
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: _selectedTab,
            onDestinationSelected: (idx) => setState(() => _selectedTab = idx),
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.grey[100],
            selectedIconTheme: const IconThemeData(color: Color(0xFF2D5A27)),
            selectedLabelTextStyle: GoogleFonts.inter(color: const Color(0xFF2D5A27), fontWeight: FontWeight.bold),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text("Stats")),
              NavigationRailDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: Text("Events")),
              NavigationRailDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: Text("Jobs")),
              NavigationRailDestination(icon: Icon(Icons.business_outlined), selectedIcon: Icon(Icons.business), label: Text("Services")),
              NavigationRailDestination(icon: Icon(Icons.photo_library_outlined), selectedIcon: Icon(Icons.photo_library), label: Text("Gallery")),
              NavigationRailDestination(icon: Icon(Icons.agriculture_outlined), selectedIcon: Icon(Icons.agriculture), label: Text("Farming")),
              NavigationRailDestination(icon: Icon(Icons.quiz_outlined), selectedIcon: Icon(Icons.quiz), label: Text("Quiz")),
            ],
          ),
          // Main Content
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(30),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0: return _buildSummary();
      case 1: return const ManageItems<VillageEvent>(collection: 'events', title: "Events");
      case 2: return const ManageItems<Job>(collection: 'jobs', title: "Jobs");
      case 3: return const ManageItems<VillageService>(collection: 'services', title: "Services");
      case 4: return const ManageItems<GalleryImage>(collection: 'gallery', title: "Photos");
      case 5: return const ManageItems<FarmingPost>(collection: 'farming', title: "Farming Content");
      case 6: return const ManageItems<QuizQuestion>(collection: 'questions', title: "Quiz Questions");
      default: return const SizedBox();
    }
  }

  Widget _buildSummary() {
    final data = context.watch<DataProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("System Overview", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _statCard("Total Events", data.events.length, Icons.event, Colors.blue),
            _statCard("Open Jobs", data.jobs.length, Icons.work, Colors.orange),
            _statCard("Local Services", data.services.length, Icons.business, Colors.green),
            _statCard("Gallery Photos", data.galleryItems.length, Icons.photo_library, Colors.purple),
            _statCard("Farming Tips", data.farmingPosts.length, Icons.agriculture, Colors.brown),
            _statCard("Quiz Questions", data.questions.length, Icons.quiz, Colors.teal),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, int count, IconData icon, Color color) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 15),
          Text(count.toString(), style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold)),
          Text(label, style: GoogleFonts.inter(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// Reusable CRUD Module
class ManageItems<T> extends StatelessWidget {
  final String collection;
  final String title;
  const ManageItems({super.key, required this.collection, required this.title});

  Widget? _buildLeading(dynamic item) {
    String? url;
    int count = 0;
    if (item is VillageEvent) {
      url = VillageEvent.getAutoImage(item.imageUrl, item.type);
      count = item.additionalImages.length;
    } else if (item is GalleryImage) {
      url = item.imageUrl;
      count = item.images.length;
    } else if (item is VillageService) {
      url = VillageService.getAutoImage(item.imageUrl, item.type);
    } else if (item is FarmingPost) {
      url = item.imageUrl;
    }

    if (url == null || url.isEmpty) return null;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: url.startsWith('http') 
            ? Image.network(
                url, 
                width: 45, 
                height: 45, 
                fit: BoxFit.cover, 
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey, size: 20),
              ) 
            : Image.asset(url, width: 45, height: 45, fit: BoxFit.cover),
        ),
        if (count > 0)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
              child: Text("+$count", style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  Widget? _buildSubtitle(dynamic item) {
    if (item is VillageEvent) return Text(item.date, style: GoogleFonts.inter(fontSize: 11));
    if (item is Job) return Text(item.contact, style: GoogleFonts.inter(fontSize: 11));
    if (item is VillageService) return Text(item.type.name.toUpperCase(), style: GoogleFonts.inter(fontSize: 11));
    if (item is GalleryImage) return Text("${item.category} • ${item.images.length} photos", style: GoogleFonts.inter(fontSize: 11));
    if (item is FarmingPost) return Text(item.category.name.toUpperCase(), style: GoogleFonts.inter(fontSize: 11));
    if (item is QuizQuestion) return Text("${item.options.length} options • Answer: Option ${item.correctAnswerIndex + 1}", style: GoogleFonts.inter(fontSize: 11));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    List items = [];
    if (T == VillageEvent) items = data.events;
    else if (T == Job) items = data.jobs;
    else if (T == VillageService) items = data.services;
    else if (T == GalleryImage) items = data.galleryItems;
    else if (T == FarmingPost) items = data.farmingPosts;
    else if (T == QuizQuestion) items = data.questions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Manage $title", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showAddDialog(context),
              icon: const Icon(Icons.add),
              label: Text("Add New $title"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5A27),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, idx) {
              final item = items[idx];
              String displayTitle = "";
              if (item is VillageEvent) displayTitle = item.title;
              else if (item is Job) displayTitle = item.title;
              else if (item is VillageService) displayTitle = item.name;
              else if (item is GalleryImage) displayTitle = item.title;
              else if (item is FarmingPost) displayTitle = item.title;
              else if (item is QuizQuestion) displayTitle = item.question;

              return ListTile(
                leading: _buildLeading(item),
                title: Text(displayTitle, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                subtitle: _buildSubtitle(item),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue), 
                      onPressed: () => _showAddDialog(context, item: item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red), 
                      onPressed: () => _showDeleteConfirmation(context, data, collection, item.id, displayTitle),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, DataProvider data, String collection, String id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Deletion", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete '$title'? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              data.deleteItem(collection, id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("'$title' has been deleted")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, {dynamic item}) {
    if (T == VillageEvent) {
      _showEventDialog(context, item as VillageEvent?);
    } else if (T == Job) {
      _showJobDialog(context, item as Job?);
    } else if (T == VillageService) {
      _showServiceDialog(context, item as VillageService?);
    } else if (T == GalleryImage) {
      _showGalleryDialog(context, item as GalleryImage?);
    } else if (T == FarmingPost) {
      _showFarmingDialog(context, item as FarmingPost?);
    } else if (T == QuizQuestion) {
      _showQuizDialog(context, item as QuizQuestion?);
    }
  }

  // --- MODEL SPECIFIC DIALOGS ---

  void _showEventDialog(BuildContext context, VillageEvent? event) {
    final titleController = TextEditingController(text: event?.title);
    final dateController = TextEditingController(text: event?.date);
    final descController = TextEditingController(text: event?.description);
    EventType selectedType = event?.type ?? EventType.other;
    List<String> _additionalUrls = List<String>.from(event?.additionalImages ?? []);
    bool _isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(event == null ? "Add Event" : "Edit Event", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: "Event Title")),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: dateController,
                          decoration: const InputDecoration(
                            labelText: "Event Date",
                            hintText: "Select date",
                            suffixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2030),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF2D5A27),
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setDialogState(() {
                                dateController.text = DateFormat('MMMM d, y').format(picked);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<EventType>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: "Type of Program"),
                    items: EventType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
                    onChanged: (val) => setDialogState(() => selectedType = val!),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: descController, decoration: const InputDecoration(labelText: "Description"), maxLines: 3),
                  const SizedBox(height: 20),
                  Text("Additional Photos (${_additionalUrls.length})", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: _additionalUrls.isEmpty 
                      ? const Center(child: Text("No extra photos uploaded"))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _additionalUrls.length,
                          itemBuilder: (context, idx) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(_additionalUrls[idx], width: 100, height: 100, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () => setDialogState(() => _additionalUrls.removeAt(idx)),
                                    child: Container(
                                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ),
                  const SizedBox(height: 15),
                  _isUploading 
                    ? const CircularProgressIndicator(color: Color(0xFF2D5A27))
                    : ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final List<XFile> photos = await picker.pickMultiImage();
                          if (photos.isNotEmpty) {
                            setDialogState(() => _isUploading = true);
                            try {
                              for (var photo in photos) {
                                final bytes = await photo.readAsBytes();
                                final name = "event_${DateTime.now().millisecondsSinceEpoch}_${photo.name}";
                                final url = await context.read<DataProvider>().uploadImage('events', name, bytes);
                                setDialogState(() => _additionalUrls.add(url));
                              }
                              setDialogState(() => _isUploading = false);
                            } catch (e) {
                              setDialogState(() => _isUploading = false);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          }
                        },
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text("Upload Program Photos"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D5A27), 
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 40),
                        ),
                      ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: _isUploading ? null : () {
                final newEvent = VillageEvent(
                  id: event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  date: dateController.text,
                  description: descController.text,
                  imageUrl: "", // Handled by getAutoImage in widgets
                  type: selectedType,
                  additionalImages: _additionalUrls,
                );
                context.read<DataProvider>().saveItem('events', newEvent.id, newEvent.toMap());
                Navigator.pop(context);
              },
              child: const Text("Save Event"),
            ),
          ],
        ),
      ),
    );
  }

  void _showJobDialog(BuildContext context, Job? job) {
    final titleController = TextEditingController(text: job?.title);
    final descController = TextEditingController(text: job?.description);
    final contactController = TextEditingController(text: job?.contact);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(job == null ? "Add Job" : "Edit Job", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Job Title")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Description"), maxLines: 3),
              TextField(controller: contactController, decoration: const InputDecoration(labelText: "Contact Info")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final newJob = Job(
                id: job?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                description: descController.text,
                contact: contactController.text,
              );
              context.read<DataProvider>().saveItem('jobs', newJob.id, newJob.toMap());
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showServiceDialog(BuildContext context, VillageService? service) {
    final nameController = TextEditingController(text: service?.name);
    final locController = TextEditingController(text: service?.location);
    final contactController = TextEditingController(text: service?.contact);
    ServiceType selectedType = service?.type ?? ServiceType.other;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(service == null ? "Add Service" : "Edit Service", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Service Name")),
                const SizedBox(height: 10),
                DropdownButtonFormField<ServiceType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: "Service Type"),
                  items: ServiceType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
                  onChanged: (val) => setDialogState(() => selectedType = val!),
                ),
                TextField(controller: locController, decoration: const InputDecoration(labelText: "Location")),
                TextField(controller: contactController, decoration: const InputDecoration(labelText: "Contact Info")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                final newSvc = VillageService(
                  id: service?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  location: locController.text,
                  contact: contactController.text,
                  type: selectedType,
                  icon: selectedType == ServiceType.health ? Icons.local_hospital : Icons.business,
                  imageUrl: "", // We use default based on type in the card widgets
                );
                context.read<DataProvider>().saveItem('services', newSvc.id, newSvc.toMap());
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _showGalleryDialog(BuildContext context, GalleryImage? image) {
    final titleController = TextEditingController(text: image?.title);
    final descController = TextEditingController(text: image?.description);
    final catController = TextEditingController(text: image?.category ?? "Places");
    List<String> _uploadedUrls = List<String>.from(image?.images ?? []);
    if (image?.imageUrl != null && image!.imageUrl.isNotEmpty && !_uploadedUrls.contains(image.imageUrl)) {
       _uploadedUrls.insert(0, image.imageUrl);
    }
    bool _isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(image == null ? "Add Gallery Folder" : "Edit Gallery Folder", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: "Folder Title")),
                  const SizedBox(height: 10),
                  TextField(controller: descController, decoration: const InputDecoration(labelText: "Description"), maxLines: 2),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: catController.text,
                    decoration: const InputDecoration(labelText: "Category"),
                    items: ["Places", "Events"].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setDialogState(() => catController.text = val!),
                  ),
                  const SizedBox(height: 20),
                  Text("Images (${_uploadedUrls.length})", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: _uploadedUrls.isEmpty 
                      ? const Center(child: Text("No images uploaded"))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _uploadedUrls.length,
                          itemBuilder: (context, idx) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _uploadedUrls[idx], 
                                    width: 120, 
                                    height: 120, 
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const SizedBox(width: 120, child: Icon(Icons.broken_image)),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () => setDialogState(() => _uploadedUrls.removeAt(idx)),
                                    child: Container(
                                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                                if (idx == 0)
                                  Positioned(
                                    left: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2D5A27),
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), topRight: Radius.circular(8)),
                                      ),
                                      child: Text("COVER", style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                  ),
                  const SizedBox(height: 15),
                  _isUploading 
                    ? Column(
                        children: [
                          const CircularProgressIndicator(color: Color(0xFF2D5A27)),
                          const SizedBox(height: 10),
                          Text("Uploading multiple photos...", style: GoogleFonts.inter(fontSize: 12)),
                        ],
                      )
                    : ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final List<XFile> photos = await picker.pickMultiImage();
                          if (photos.isNotEmpty) {
                            setDialogState(() => _isUploading = true);
                            try {
                              for (var photo in photos) {
                                final bytes = await photo.readAsBytes();
                                final name = "gallery_${DateTime.now().millisecondsSinceEpoch}_${photo.name}";
                                final url = await context.read<DataProvider>().uploadImage('gallery', name, bytes);
                                setDialogState(() => _uploadedUrls.add(url));
                              }
                              setDialogState(() => _isUploading = false);
                            } catch (e) {
                              setDialogState(() => _isUploading = false);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          }
                        },
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text("Select & Upload Photos"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D5A27), 
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 45),
                        ),
                      ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: _isUploading || _uploadedUrls.isEmpty ? null : () {
                final newImg = GalleryImage(
                  id: image?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  description: descController.text,
                  category: catController.text,
                  imageUrl: _uploadedUrls.isNotEmpty ? _uploadedUrls.first : "",
                  images: _uploadedUrls,
                );
                context.read<DataProvider>().saveItem('gallery', newImg.id, newImg.toMap());
                Navigator.pop(context);
              },
              child: const Text("Save Folder"),
            ),
          ],
        ),
      ),
    );
  }

  void _showFarmingDialog(BuildContext context, FarmingPost? post) {
    final titleController = TextEditingController(text: post?.title);
    final descController = TextEditingController(text: post?.description);
    final urlController = TextEditingController(text: post?.imageUrl);
    FarmingCategory selectedCategory = post?.category ?? FarmingCategory.crops;
    bool _isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(post == null ? "Add Farming Tip" : "Edit Farming Tip", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
                const SizedBox(height: 10),
                DropdownButtonFormField<FarmingCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: "Category"),
                  items: FarmingCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))).toList(),
                  onChanged: (val) => setDialogState(() => selectedCategory = val!),
                ),
                const SizedBox(height: 10),
                TextField(controller: descController, decoration: const InputDecoration(labelText: "Description"), maxLines: 4),
                const SizedBox(height: 10),
                TextField(controller: urlController, decoration: const InputDecoration(labelText: "Image URL (Optional)")),
                const SizedBox(height: 15),
                _isUploading 
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setDialogState(() => _isUploading = true);
                          try {
                            final bytes = await image.readAsBytes();
                            final name = "farming_${DateTime.now().millisecondsSinceEpoch}_${image.name}";
                            final url = await context.read<DataProvider>().uploadImage('farming', name, bytes);
                            setDialogState(() {
                              urlController.text = url;
                              _isUploading = false;
                            });
                          } catch (e) {
                            setDialogState(() => _isUploading = false);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        }
                      },
                      icon: const Icon(Icons.upload),
                      label: const Text("Upload Image"),
                    ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: _isUploading ? null : () {
                final newPost = FarmingPost(
                  id: post?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  description: descController.text,
                  category: selectedCategory,
                  imageUrl: urlController.text,
                );
                context.read<DataProvider>().saveItem('farming', newPost.id, newPost.toMap());
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuizDialog(BuildContext context, QuizQuestion? question) {
    final qController = TextEditingController(text: question?.question);
    final optionsControllers = List.generate(
      4, 
      (i) => TextEditingController(text: (question?.options.length ?? 0) > i ? question!.options[i] : ""),
    );
    int correctIdx = question?.correctAnswerIndex ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(question == null ? "Add Question" : "Edit Question", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: qController, decoration: const InputDecoration(labelText: "Question"), maxLines: 2),
                const SizedBox(height: 20),
                ...List.generate(4, (i) => Row(
                  children: [
                    Radio<int>(
                      value: i,
                      groupValue: correctIdx,
                      onChanged: (val) => setDialogState(() => correctIdx = val!),
                    ),
                    Expanded(child: TextField(controller: optionsControllers[i], decoration: InputDecoration(labelText: "Option ${i + 1}"))),
                  ],
                )),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                final newQ = QuizQuestion(
                  id: question?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  question: qController.text,
                  options: optionsControllers.map((c) => c.text).toList(),
                  correctAnswerIndex: correctIdx,
                );
                context.read<DataProvider>().saveItem('questions', newQ.id, newQ.toMap());
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
