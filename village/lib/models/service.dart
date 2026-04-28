import 'package:flutter/material.dart';

enum ServiceType { health, education, shop, cleaning, farming, other }

class VillageService {
  final String id;
  final String name;
  final ServiceType type;
  final String contact;
  final String location;
  final IconData icon;
  final String imageUrl;

  const VillageService({
    required this.id,
    required this.name,
    required this.type,
    required this.contact,
    required this.location,
    required this.icon,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'contact': contact,
      'location': location,
      'iconCode': icon.codePoint,
      'imageUrl': imageUrl,
    };
  }

  factory VillageService.fromMap(Map<String, dynamic> map) {
    return VillageService(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: ServiceType.values.byName(map['type'] ?? 'other'),
      contact: map['contact'] ?? '',
      location: map['location'] ?? '',
      icon: IconData(map['iconCode'] ?? Icons.home.codePoint, fontFamily: 'MaterialIcons'),
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  static String getAutoImage(String imageUrl, ServiceType type) {
    if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) return imageUrl;
    
    switch (type) {
      case ServiceType.health:
        return 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d';
      case ServiceType.education:
        return 'assets/images/master_education.png';
      case ServiceType.shop:
        return 'https://images.unsplash.com/photo-1604719312563-8912e9223c6a';
      case ServiceType.cleaning:
        return 'assets/images/master_cleaning.png';
      case ServiceType.farming:
        return 'assets/images/master_farming.png';
      case ServiceType.other:
      default:
        return 'https://images.unsplash.com/photo-1449156001437-3a16d1daae39';
    }
  }
}
