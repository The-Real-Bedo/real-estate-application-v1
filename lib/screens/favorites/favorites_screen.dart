import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/property_model.dart';
import '../../models/user_profile_model.dart';
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
      body: FutureBuilder<UserProfileModel?>(
        future: dbService.getUserProfile(authService.user!.uid),
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnap.hasData || userSnap.data == null) {
            return const Center(child: Text("Could not load favorites."));
          }

          final favorites = userSnap.data!.favorites;

          if (favorites.isEmpty) {
            return const Center(
              child: Text("You have no favorite properties."),
            );
          }

          return StreamBuilder<List<PropertyModel>>(
            stream: dbService.getFavoriteProperties(favorites),
            builder: (context, propsSnap) {
              if (propsSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!propsSnap.hasData || propsSnap.data!.isEmpty) {
                return const Center(
                  child: Text("Favorite properties no longer available."),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: propsSnap.data!.length,
                itemBuilder: (context, index) {
                  final property = propsSnap.data![index];
                  String imageUrl = property.images.isNotEmpty
                      ? property.images.first
                      : '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: PropertyCard(
                      title: property.title,
                      location: property.location,
                      price: '\$${property.price}',
                      imageUrl: imageUrl,
                      category: property.category,
                      listingType: property.type,
                      beds: property.beds,
                      baths: property.baths,
                      area: property.area,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PropertyDetailsScreen(property: property),
                          ),
                        );
                      },
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

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
