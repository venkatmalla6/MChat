import '../models/event.dart';
import '../models/announcement.dart';
import '../models/job.dart';
import '../models/service.dart';
import '../models/gallery_item.dart';
import 'package:flutter/material.dart';

class MockData {
  static const String villageName = "Somarayanampeta";
  static const String villageIntro = 
      "Welcome to Somarayanampeta, a gem of the East Godavari district. "
      "Nestled amidst lush green paddy fields and the fertile Godavari delta, "
      "our village is a testament to the rich agricultural heritage and "
      "vibrant culture of Andhra Pradesh. Experience serenity, tradition, and community.";

  static const List<VillageEvent> events = [];

  static const List<Announcement> announcements = [];

  static const List<Job> jobs = [];

  static const List<VillageService> services = [];

  static const List<GalleryImage> galleryItems = [];
}
