import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

class PropertyCard extends StatelessWidget {
  final String title;
  final String location;
  final String price;
  final String imageUrl;
  final String category;
  final String listingType;
  final int beds;
  final int baths;
  final double area;
  final double? width;
  final VoidCallback onTap;

  const PropertyCard({
    super.key,
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.listingType,
    required this.beds,
    required this.baths,
    required this.area,
    this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    height: 148,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                            ),
                          )
                        : const Icon(
                            Icons.apartment_rounded,
                            size: 44,
                            color: Colors.grey,
                          ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _Badge(
                    text: _formatLabel(category),
                    icon: _categoryIcon(category),
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: _Badge(
                    text: _formatLabel(listingType),
                    icon: listingType.toLowerCase() == 'sale'
                        ? Icons.sell_outlined
                        : Icons.key_outlined,
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Spec(icon: Icons.bed_outlined, text: '$beds'),
                      const SizedBox(width: 8),
                      _Spec(icon: Icons.bathtub_outlined, text: '$baths'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Spec(
                          icon: Icons.square_foot_outlined,
                          text:
                              '${area.toStringAsFixed(area % 1 == 0 ? 0 : 1)} m²',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: BorderSide(
                          color: AppTheme.primary.withValues(alpha: 0.24),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const _Badge({
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Spec({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppTheme.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
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

String _formatLabel(String value) {
  if (value.trim().isEmpty) {
    return 'Property';
  }
  final clean = value.trim().replaceAll('_', ' ');
  return clean[0].toUpperCase() + clean.substring(1);
}
