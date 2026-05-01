import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/db_service.dart';
import '../../services/auth_service.dart';
import '../../shared/property_card.dart';
import '../property/property_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.user == null) {
      return const Center(child: Text("Not logged in"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: dbService.getUserProfile(authService.user!.uid),
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnap.hasData || !userSnap.data!.exists) {
            return const Center(child: Text("Could not load favorites."));
          }

          var userData = userSnap.data!.data() as Map<String, dynamic>;
          List<dynamic> favorites = userData['favorites'] ?? [];

          if (favorites.isEmpty) {
            return const Center(
              child: Text("You have no favorite properties."),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: dbService.getFavoriteProperties(favorites),
            builder: (context, propsSnap) {
              if (propsSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!propsSnap.hasData || propsSnap.data!.docs.isEmpty) {
                return const Center(
                  child: Text("Favorite properties no longer available."),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: propsSnap.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = propsSnap.data!.docs[index];
                  var data = doc.data() as Map<String, dynamic>;
                  String imageUrl =
                      (data['images'] != null && data['images'].isNotEmpty)
                      ? data['images'][0]
                      : '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: PropertyCard(
                        title: data['title'] ?? 'No Title',
                        location: data['location'] ?? 'Unknown',
                        price: '\$${data['price']}',
                        imageUrl: imageUrl,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PropertyDetailsScreen(property: doc),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
