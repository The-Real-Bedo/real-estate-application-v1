import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../shared/property_card.dart';
import '../../services/db_service.dart';
import '../../services/auth_service.dart';
import '../owner/add_property_screen.dart';
import '../property/property_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Apartments',
    'Villas',
    'Chalets',
    'Offices',
  ];

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome,', style: Theme.of(context).textTheme.bodyMedium),
            Text(
              authService.firstName,
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.toLowerCase();
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search properties...',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Categories
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((category) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: _CategoryPill(
                        title: category,
                        isSelected: _selectedCategory == category,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Available Properties',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: dbService.getApprovedProperties(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No properties found."));
                  }

                  // Client-side filtering logic
                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    var property = doc.data() as Map<String, dynamic>;
                    String title = (property['title'] ?? '')
                        .toString()
                        .toLowerCase();
                    String location = (property['location'] ?? '')
                        .toString()
                        .toLowerCase();
                    String categoryField = (property['category'] ?? '')
                        .toString()
                        .toLowerCase();

                    // Search Query Matching
                    bool matchesSearch =
                        _searchQuery.isEmpty ||
                        title.contains(_searchQuery) ||
                        location.contains(_searchQuery);

                    // Category Matching
                    bool matchesCategory = true;
                    if (_selectedCategory != 'All') {
                      // We check if the explicit category matches (if saved), OR if title mentions it to support legacy posts where 'category' was not specifically saved
                      String target = _selectedCategory.toLowerCase();
                      // remove trailing 's' if any to match "apartment" -> "apartments"
                      if (target.endsWith('s')) {
                        target = target.substring(0, target.length - 1);
                      }

                      bool exactCategoryMatch = categoryField.contains(target);
                      bool titleMatch = title.contains(target);
                      matchesCategory = exactCategoryMatch || titleMatch;
                    }

                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return const Center(
                      child: Text("No properties match your search."),
                    );
                  }

                  return Column(
                    children: filteredDocs.map((propertyDoc) {
                      var property = propertyDoc.data() as Map<String, dynamic>;
                      String imageUrl =
                          (property['images'] != null &&
                              property['images'].isNotEmpty)
                          ? property['images'][0]
                          : '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PropertyCard(
                          title: property['title'] ?? 'No Title',
                          location: property['location'] ?? 'Unknown location',
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
                                builder: (_) => PropertyDetailsScreen(
                                  property: propertyDoc,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          authService.userRole == 'owner' || authService.userRole == 'admin'
          ? FloatingActionButton(
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPropertyScreen()),
                );
              },
            )
          : null,
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

class _CategoryPill extends StatelessWidget {
  final String title;
  final bool isSelected;
  const _CategoryPill({required this.title, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary : AppTheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppTheme.primary : AppTheme.border,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
