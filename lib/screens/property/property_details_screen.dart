import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../services/db_service.dart';
import '../../services/auth_service.dart';
import '../../shared/custom_buttons.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final DocumentSnapshot property;
  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final dbService = Provider.of<DatabaseService>(context, listen: false);

    if (authService.user != null) {
      var userDoc = await dbService.getUserProfile(authService.user!.uid);
      if (userDoc.exists) {
        List<dynamic> favorites =
            (userDoc.data() as Map<String, dynamic>)['favorites'] ?? [];
        if (favorites.contains(widget.property.id)) {
          setState(() {
            _isFavorite = true;
          });
        }
      }
    }
  }

  void _toggleFavorite() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final dbService = Provider.of<DatabaseService>(context, listen: false);

    if (authService.user == null) {
      return;
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });

    await dbService.toggleFavorite(
      authService.user!.uid,
      widget.property.id,
      _isFavorite,
    );
  }

  void _contactOwner() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact Owner feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.property.data() as Map<String, dynamic>;
    List<dynamic> images = data['images'] ?? [];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            if (images.isNotEmpty)
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 350.0,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                    ),
                    items: images.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.error),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  Positioned(
                    bottom: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: images.asMap().entries.map((entry) {
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 4.0,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(
                              alpha: _currentImageIndex == entry.key
                                  ? 0.9
                                  : 0.4,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              )
            else
              Container(
                height: 350,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image, size: 100, color: Colors.grey),
              ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data['title'] ?? 'No Title',
                          style: Theme.of(
                            context,
                          ).textTheme.displayLarge?.copyWith(fontSize: 24),
                        ),
                      ),
                      Text(
                        '\$${data['price']}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppTheme.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        data['location'] ?? 'Unknown location',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Specifications
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SpecItem(
                        icon: Icons.bed_outlined,
                        label: '${data['beds'] ?? 0} Beds',
                      ),
                      _SpecItem(
                        icon: Icons.bathtub_outlined,
                        label: '${data['baths'] ?? 0} Baths',
                      ),
                      _SpecItem(
                        icon: Icons.square_foot_outlined,
                        label: '${data['area'] ?? 0} m²',
                      ),
                      _SpecItem(
                        icon: Icons.home_work_outlined,
                        label: (data['type'] ?? 'Rent').toUpperCase(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data['description'] ?? 'No description provided.',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: PrimaryButton(text: 'Contact Owner', onPressed: _contactOwner),
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SpecItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primary),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}
