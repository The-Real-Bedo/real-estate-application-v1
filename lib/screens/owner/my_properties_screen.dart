import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/db_service.dart';
import '../../services/auth_service.dart';
import '../../shared/property_card.dart';
import '../property/property_details_screen.dart';

class MyPropertiesScreen extends StatelessWidget {
  const MyPropertiesScreen({super.key});

  void _confirmDelete(BuildContext context, String propertyId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Property?'),
        content: const Text(
          'Are you sure you want to delete this property? This action cannot be undone and will delete all associated images.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Deleting...')));
              await Provider.of<DatabaseService>(
                context,
                listen: false,
              ).deleteProperty(propertyId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Deleted successfully'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

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
          'My Properties',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: dbService.getPropertiesByOwner(authService.user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("You haven't added any properties yet."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var propertyDoc = snapshot.data!.docs[index];
              var property = propertyDoc.data() as Map<String, dynamic>;
              String imageUrl =
                  (property['images'] != null && property['images'].isNotEmpty)
                  ? property['images'][0]
                  : '';
              String status = property['status'] ?? 'pending';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Stack(
                  children: [
                    PropertyCard(
                      title: property['title'] ?? 'No Title',
                      location: property['location'] ?? 'Unknown',
                      price: '\$${property['price']}',
                      imageUrl: imageUrl,
                      category: property['category'] ?? 'apartment',
                      listingType: property['type'] ?? 'rent',
                      beds: _asInt(property['beds']),
                      baths: _asInt(property['baths']),
                      area: _asDouble(property['area']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PropertyDetailsScreen(property: propertyDoc),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: AppTheme.error,
                          ),
                        ),
                        onPressed: () =>
                            _confirmDelete(context, propertyDoc.id),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: status == 'approved'
                              ? AppTheme.success
                              : AppTheme.warning,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
