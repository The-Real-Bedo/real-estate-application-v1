import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';
import '../../shared/custom_buttons.dart';
import '../../theme/app_theme.dart';

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

    if (authService.user == null) {
      return;
    }

    final userDoc = await dbService.getUserProfile(authService.user!.uid);
    if (!mounted || !userDoc.exists) {
      return;
    }

    final data = userDoc.data() as Map<String, dynamic>;
    final favorites = data['favorites'] ?? [];
    setState(() {
      _isFavorite = favorites.contains(widget.property.id);
    });
  }

  Future<void> _toggleFavorite() async {
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
    final data = widget.property.data() as Map<String, dynamic>;
    final images = (data['images'] ?? []) as List<dynamic>;
    final category = _formatLabel(data['category'] ?? 'apartment');
    final listingType = _formatLabel(data['type'] ?? 'rent');

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ImageHeader(
              images: images,
              currentIndex: _currentImageIndex,
              isFavorite: _isFavorite,
              onBack: () => Navigator.pop(context),
              onFavorite: _toggleFavorite,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
            ),
            Transform.translate(
              offset: const Offset(0, -26),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 34),
                decoration: const BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _InfoChip(
                                    icon: _categoryIcon(category),
                                    text: category,
                                  ),
                                  _InfoChip(
                                    icon: data['type'] == 'sale'
                                        ? Icons.sell_outlined
                                        : Icons.key_outlined,
                                    text: listingType,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                data['title'] ?? 'No Title',
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(fontSize: 25),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '\$${data['price']}',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _LocationBox(
                      location: data['location'] ?? 'Unknown location',
                      latitude: data['latitude'],
                      longitude: data['longitude'],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Property details',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.55,
                      children: [
                        _SpecTile(
                          icon: Icons.bed_outlined,
                          label: 'Beds / Rooms',
                          value: '${data['beds'] ?? 0}',
                        ),
                        _SpecTile(
                          icon: Icons.bathtub_outlined,
                          label: 'Baths',
                          value: '${data['baths'] ?? 0}',
                        ),
                        _SpecTile(
                          icon: Icons.square_foot_outlined,
                          label: 'Area',
                          value: '${data['area'] ?? 0} m²',
                        ),
                        _SpecTile(
                          icon: Icons.home_work_outlined,
                          label: 'Type',
                          value: category,
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Text(
                        data['description'] ?? 'No description provided.',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          height: 1.55,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          child: PrimaryButton(
            text: 'Contact Owner',
            icon: Icons.phone_outlined,
            onPressed: _contactOwner,
          ),
        ),
      ),
    );
  }
}

class _ImageHeader extends StatelessWidget {
  final List<dynamic> images;
  final int currentIndex;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final ValueChanged<int> onPageChanged;

  const _ImageHeader({
    required this.images,
    required this.currentIndex,
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final carouselController = CarouselSliderController();

    return Stack(
      children: [
        if (images.isNotEmpty)
          CarouselSlider(
            carouselController: carouselController,
            options: CarouselOptions(
              height: 370,
              viewportFraction: 1,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) => onPageChanged(index),
            ),
            items: images.map((url) {
              return CachedNetworkImage(
                imageUrl: url,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              );
            }).toList(),
          )
        else
          Container(
            height: 370,
            width: double.infinity,
            color: Colors.grey.shade300,
            child: const Icon(
              Icons.apartment_rounded,
              size: 96,
              color: Colors.grey,
            ),
          ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.34),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.24),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          child: _CircleIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: onBack,
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          right: 16,
          child: _CircleIconButton(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? AppTheme.error : AppTheme.textPrimary,
            onPressed: onFavorite,
          ),
        ),
        if (images.length > 1)
          Positioned(
            left: 14,
            top: 0,
            bottom: 0,
            child: Center(
              child: _CircleIconButton(
                icon: Icons.chevron_left_rounded,
                onPressed: () => carouselController.previousPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                ),
              ),
            ),
          ),
        if (images.length > 1)
          Positioned(
            right: 14,
            top: 0,
            bottom: 0,
            child: Center(
              child: _CircleIconButton(
                icon: Icons.chevron_right_rounded,
                onPressed: () => carouselController.nextPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                ),
              ),
            ),
          ),
        if (images.length > 1)
          Positioned(
            bottom: 42,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                final isActive = currentIndex == entry.key;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isActive ? 18 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: isActive ? 0.95 : 0.5,
                    ),
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _CircleIconButton({
    required this.icon,
    this.color = AppTheme.textPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationBox extends StatelessWidget {
  final String location;
  final dynamic latitude;
  final dynamic longitude;

  const _LocationBox({
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = latitude != null && longitude != null;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (hasCoordinates) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${latitude.toString()}, ${longitude.toString()}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

IconData _categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'villa':
      return Icons.villa_outlined;
    case 'chalet':
      return Icons.beach_access_outlined;
    case 'office':
      return Icons.business_center_outlined;
    default:
      return Icons.apartment_outlined;
  }
}

String _formatLabel(dynamic value) {
  final text = (value ?? '').toString().trim();
  if (text.isEmpty) {
    return 'Property';
  }
  return text[0].toUpperCase() + text.substring(1);
}
