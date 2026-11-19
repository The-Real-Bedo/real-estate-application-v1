import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/property_model.dart';
import '../models/user_profile_model.dart';

class DatabaseService {
  // In-memory data storage replacing Cloud Firestore
  final List<PropertyModel> _properties = [
    PropertyModel(
      id: 'prop-1',
      ownerId: 'owner-default',
      title: 'Luxury 3-BHK Modern Apartment',
      description:
          'Spacious luxury apartment with panoramic city views, high-end finishing, and master suite.',
      category: 'Apartments',
      type: 'rent',
      location: 'New Cairo, 5th Settlement',
      latitude: 30.0254,
      longitude: 31.4913,
      price: 25000,
      beds: 3,
      baths: 2,
      area: 185,
      status: 'approved',
      images: [
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=1200&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=1200&auto=format&fit=crop&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PropertyModel(
      id: 'prop-2',
      ownerId: 'owner-default',
      title: 'Stand-alone Villa with Private Pool',
      description:
          'Exclusive villa with private landscape garden, swimming pool, and smart home automation.',
      category: 'Villas',
      type: 'sale',
      location: 'Sheikh Zayed City',
      latitude: 30.0520,
      longitude: 30.9700,
      price: 14500000,
      beds: 5,
      baths: 4,
      area: 420,
      status: 'approved',
      images: [
        'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=1200&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=1200&auto=format&fit=crop&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    PropertyModel(
      id: 'prop-3',
      ownerId: 'owner-default',
      title: 'Sea-View Beachfront Chalet',
      description:
          'Prime sea view chalet with direct beach access, fully furnished, and ready to move.',
      category: 'Chalets',
      type: 'rent',
      location: 'North Coast (Sahel)',
      latitude: 30.9300,
      longitude: 28.9100,
      price: 45000,
      beds: 2,
      baths: 2,
      area: 120,
      status: 'approved',
      images: [
        'https://images.unsplash.com/photo-1512915922686-57c11dde9b6b?w=1200&auto=format&fit=crop&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    PropertyModel(
      id: 'prop-4',
      ownerId: 'owner-default',
      title: 'Commercial Executive Office',
      description:
          'Modern administrative office space in prime business district with meeting rooms.',
      category: 'Offices',
      type: 'rent',
      location: 'New Capital City',
      latitude: 30.0100,
      longitude: 31.7500,
      price: 60000,
      beds: 0,
      baths: 2,
      area: 210,
      status: 'approved',
      images: [
        'https://images.unsplash.com/photo-1497366216548-37526070297c?w=1200&auto=format&fit=crop&q=80',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  // In-memory User Profiles
  final Map<String, UserProfileModel> _userProfiles = {};

  // Broadcast stream controller to notify listeners of changes in properties
  final StreamController<List<PropertyModel>> _propertiesController =
      StreamController<List<PropertyModel>>.broadcast();

  DatabaseService() {
    // Initial emission
    Future.microtask(() => _notifyListeners());
  }

  void _notifyListeners() {
    if (!_propertiesController.isClosed) {
      _propertiesController.add(List.unmodifiable(_properties));
    }
  }

  // Stream of Approved Properties for Home Screen
  Stream<List<PropertyModel>> getApprovedProperties() {
    return _propertiesController.stream
        .map((list) => list.where((p) => p.status == 'approved').toList())
        .asBroadcastStream(
          onListen: (subscription) {
            subscription.onData((_) {});
            Future.microtask(() => _notifyListeners());
          },
        );
  }

  // Stream of Pending Properties for Admin Dashboard
  Stream<List<PropertyModel>> getPendingProperties() {
    return _propertiesController.stream
        .map((list) => list.where((p) => p.status == 'pending').toList())
        .asBroadcastStream(
          onListen: (subscription) {
            subscription.onData((_) {});
            Future.microtask(() => _notifyListeners());
          },
        );
  }

  // Stream of Properties by a specific Owner
  Stream<List<PropertyModel>> getPropertiesByOwner(String ownerId) {
    return _propertiesController.stream
        .map((list) => list.where((p) => p.ownerId == ownerId).toList())
        .asBroadcastStream(
          onListen: (subscription) {
            subscription.onData((_) {});
            Future.microtask(() => _notifyListeners());
          },
        );
  }

  Future<bool> addProperty({
    required String ownerId,
    required String title,
    required String description,
    required String category,
    required String type,
    required String location,
    double? latitude,
    double? longitude,
    required double price,
    required int beds,
    required int baths,
    required double area,
    required List<String> images,
  }) async {
    try {
      final newProperty = PropertyModel(
        id: 'prop_${DateTime.now().millisecondsSinceEpoch}',
        ownerId: ownerId,
        title: title,
        description: description,
        category: category,
        type: type,
        location: location,
        latitude: latitude,
        longitude: longitude,
        price: price,
        beds: beds,
        baths: baths,
        area: area,
        status: 'pending',
        images: images,
        createdAt: DateTime.now(),
      );

      _properties.insert(0, newProperty);
      _notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding property: $e');
      return false;
    }
  }

  // Admin action: Accept/Reject
  Future<void> updatePropertyStatus(String propertyId, String status) async {
    try {
      final index = _properties.indexWhere((p) => p.id == propertyId);
      if (index != -1) {
        _properties[index] = _properties[index].copyWith(status: status);
        _notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating property: $e');
    }
  }

  // Admin or Owner action: Delete property completely
  Future<void> deleteProperty(String propertyId) async {
    try {
      _properties.removeWhere((p) => p.id == propertyId);
      _notifyListeners();
    } catch (e) {
      debugPrint('Error deleting property: $e');
    }
  }

  // Upload an image to Cloudinary (Kept as cloud storage helper)
  Future<String?> uploadImage(File image) async {
    try {
      const String cloudName = 'dnay0mygm';
      const String uploadPreset = 'properties';

      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(responseData);
        return jsonResponse['secure_url'];
      } else {
        debugPrint("Cloudinary Upload Error: $responseData");
        return null;
      }
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return null;
    }
  }

  // Toggle favorite property for user
  Future<void> toggleFavorite(
    String uid,
    String propertyId,
    bool isFavorite,
  ) async {
    try {
      final profile = await getUserProfile(uid);
      final currentFavorites = List<String>.from(profile?.favorites ?? []);
      if (isFavorite) {
        if (!currentFavorites.contains(propertyId)) {
          currentFavorites.add(propertyId);
        }
      } else {
        currentFavorites.remove(propertyId);
      }

      await saveUserProfile(
        profile?.copyWith(favorites: currentFavorites) ??
            UserProfileModel(
              uid: uid,
              email: '',
              fullName: '',
              favorites: currentFavorites,
            ),
      );
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  // Get User Profile
  Future<UserProfileModel?> getUserProfile(String uid) async {
    if (_userProfiles.containsKey(uid)) {
      return _userProfiles[uid];
    }
    // Default fallback profile
    return UserProfileModel(
      uid: uid,
      email: '',
      fullName: 'User',
      role: 'buyer',
      favorites: const [],
    );
  }

  // Save User Profile
  Future<void> saveUserProfile(UserProfileModel profile) async {
    _userProfiles[profile.uid] = profile;
  }

  // Get favorite properties stream
  Stream<List<PropertyModel>> getFavoriteProperties(List<dynamic> favoriteIds) {
    if (favoriteIds.isEmpty) {
      return Stream.value(<PropertyModel>[]);
    }
    final targetIds = favoriteIds.map((e) => e.toString()).toSet();
    return _propertiesController.stream
        .map((list) => list.where((p) => targetIds.contains(p.id)).toList())
        .asBroadcastStream(
          onListen: (subscription) {
            subscription.onData((_) {});
            Future.microtask(() => _notifyListeners());
          },
        );
  }

  void dispose() {
    _propertiesController.close();
  }
}
