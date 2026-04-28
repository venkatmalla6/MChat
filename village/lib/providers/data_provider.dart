import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import '../models/event.dart';
import '../models/job.dart';
import '../models/service.dart';
import '../models/gallery_item.dart';
import '../models/farming_post.dart';
import '../models/quiz_question.dart';
import '../data/mock_data.dart';

class DataProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;

  List<VillageEvent> _events = [];
  List<Job> _jobs = [];
  List<VillageService> _services = [];
  List<GalleryImage> _galleryItems = [];
  List<FarmingPost> _farmingPosts = [];
  List<QuizQuestion> _questions = [];

  DataProvider() {
    _initStreams();
  }

  // Getters
  List<VillageEvent> get events => _events;
  List<Job> get jobs => _jobs;
  List<VillageService> get services => _services;
  List<GalleryImage> get galleryItems => _galleryItems;
  List<FarmingPost> get farmingPosts => _farmingPosts;
  List<QuizQuestion> get questions => _questions;

  void _initStreams() {
    // Events Stream
    _db.collection('events').snapshots().listen((snapshot) {
      _events = snapshot.docs.map((doc) => VillageEvent.fromMap(doc.data())).toList();
      notifyListeners();
    });

    // Jobs Stream
    _db.collection('jobs').snapshots().listen((snapshot) {
      _jobs = snapshot.docs.map((doc) => Job.fromMap(doc.data())).toList();
      notifyListeners();
    });

    // Services Stream
    _db.collection('services').snapshots().listen((snapshot) {
      _services = snapshot.docs.map((doc) => VillageService.fromMap(doc.data())).toList();
      notifyListeners();
    });

    // Gallery Stream
    _db.collection('gallery').snapshots().listen((snapshot) {
      _galleryItems = snapshot.docs.map((doc) => GalleryImage.fromMap(doc.data())).toList();
      notifyListeners();
    });

    // Farming Stream
    _db.collection('farming').snapshots().listen((snapshot) {
      _farmingPosts = snapshot.docs.map((doc) => FarmingPost.fromMap(doc.data())).toList();
      notifyListeners();
    });

    // Quiz Stream
    _db.collection('questions').snapshots().listen((snapshot) {
      _questions = snapshot.docs.map((doc) => QuizQuestion.fromMap(doc.data())).toList();
      notifyListeners();
    });
  }

  // Supabase Storage Upload
  Future<String> uploadImage(String folder, String fileName, dynamic fileSource) async {
    try {
      final String path = '$folder/$fileName';
      
      if (kIsWeb) {
        await _supabase.storage.from('gallery').uploadBinary(
          path, 
          fileSource as Uint8List,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );
      } else {
        await _supabase.storage.from('gallery').upload(
          path, 
          fileSource as File,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );
      }
      
      final String url = _supabase.storage.from('gallery').getPublicUrl(path);
      debugPrint("Upload successful: $url");
      return url;
    } catch (e) {
      debugPrint("UPLOAD ERROR DETAILS: $e");
      throw "Upload failed: ${e.toString()}";
    }
  }

  // Generic Create/Update
  Future<void> saveItem(String collection, String id, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(id).set(data);
  }

  // Generic Delete
  Future<void> deleteItem(String collection, String id) async {
    await _db.collection(collection).doc(id).delete();
  }
}
