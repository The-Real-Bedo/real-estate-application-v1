import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of Approved Properties for Home Screen
  Stream<QuerySnapshot> getApprovedProperties() {
    return _db
        .collection('properties')
        .where('status', isEqualTo: 'approved')
        .snapshots();
  }

  // Stream of Pending Properties for Admin Dashboard
  Stream<QuerySnapshot> getPendingProperties() {
    return _db
        .collection('properties')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // Stream of Properties by a specific Owner
  Stream<QuerySnapshot> getPropertiesByOwner(String ownerId) {
    return _db
        .collection('properties')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots();
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
      await _db.collection('properties').add({
        'ownerId': ownerId,
        'title': title,
        'description': description,
        'category': category,
        'type': type,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'price': price,
        'beds': beds,
        'baths': baths,
        'area': area,
        'status': 'pending',
        'images': images,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error adding property: $e');
      return false;
    }
  }

  // Admin action: Accept/Reject
  Future<void> updatePropertyStatus(String propertyId, String status) async {
    try {
      await _db.collection('properties').doc(propertyId).update({
        'status': status,
      });
    } catch (e) {
      debugPrint('Error updating property: $e');
    }
  }

  // Admin or Owner action: Delete property completely
  Future<void> deleteProperty(String propertyId) async {
    try {
      // Deleting from Cloudinary via frontend isn't allowed to prevent abuse.
      // So we only delete the document from Firestore.
      await _db.collection('properties').doc(propertyId).delete();
    } catch (e) {
      debugPrint('Error deleting property: $e');
    }
  }

  // Upload an image to Cloudinary
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
      final docRef = _db.collection('users').doc(uid);
      if (isFavorite) {
        await docRef.update({
          'favorites': FieldValue.arrayUnion([propertyId]),
        });
      } else {
        await docRef.update({
          'favorites': FieldValue.arrayRemove([propertyId]),
        });
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  // Get User Profile
  Future<DocumentSnapshot> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  // Get favorite properties
  Stream<QuerySnapshot> getFavoriteProperties(List<dynamic> favoriteIds) {
    if (favoriteIds.isEmpty) {
      // Return empty stream if no favorites
      return const Stream.empty();
    }
    // Note: 'in' query supports up to 10 items. For more, chunking is required.
    return _db
        .collection('properties')
        .where(FieldPath.documentId, whereIn: favoriteIds.take(10).toList())
        .snapshots();
  }
}
