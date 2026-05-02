import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/db_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../property/property_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminDashboard extends StatelessWidget {
  final bool showLogout;

  const AdminDashboard({super.key, this.showLogout = true});

  void _logout(BuildContext context) async {
    await Provider.of<AuthService>(context, listen: false).logout();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context, listen: false);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            if (showLogout)
              IconButton(
                icon: const Icon(Icons.logout, color: AppTheme.error),
                onPressed: () => _logout(context),
              ),
          ],
          bottom: const TabBar(
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            tabs: [
              Tab(text: 'Pending Approvals'),
              Tab(text: 'Live Properties'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _PendingPropertiesTab(dbService: dbService),
              _ApprovedPropertiesTab(dbService: dbService),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingPropertiesTab extends StatelessWidget {
  final DatabaseService dbService;
  const _PendingPropertiesTab({required this.dbService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: dbService.getPendingProperties(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No pending properties."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var property = doc.data() as Map<String, dynamic>;
            var propertyId = doc.id;
            var title = property['title'] ?? 'No Title';
            var ownerId = (property['ownerId'] ?? '').toString();
            String imageUrl =
                (property['images'] != null && property['images'].isNotEmpty)
                ? property['images'][0]
                : '';

            return _OwnerNameBuilder(
              dbService: dbService,
              ownerId: ownerId,
              builder: (ownerName) {
                return _AdminPropertyCard(
                  title: title,
                  subtitle: 'By Owner: $ownerName',
                  price: '\$${property['price']}',
                  category: property['category'] ?? 'apartment',
                  listingType: property['type'] ?? 'rent',
                  imageUrl: imageUrl,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailsScreen(property: doc),
                      ),
                    );
                  },
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.check_circle,
                        color: AppTheme.success,
                      ),
                      onPressed: () => dbService.updatePropertyStatus(
                        propertyId,
                        'approved',
                      ),
                      tooltip: 'Approve',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: AppTheme.error),
                      onPressed: () => dbService.updatePropertyStatus(
                        propertyId,
                        'rejected',
                      ),
                      tooltip: 'Reject',
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ApprovedPropertiesTab extends StatelessWidget {
  final DatabaseService dbService;
  const _ApprovedPropertiesTab({required this.dbService});

  void _confirmDelete(BuildContext context, String propertyId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Property?'),
        content: const Text(
          'Are you sure you want to delete this live property? All associated images will be deleted.',
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
              await dbService.deleteProperty(propertyId);
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
    return StreamBuilder<QuerySnapshot>(
      stream: dbService.getApprovedProperties(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No live properties."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var property = doc.data() as Map<String, dynamic>;
            var propertyId = doc.id;
            var title = property['title'] ?? 'No Title';
            var ownerId = (property['ownerId'] ?? '').toString();
            String imageUrl =
                (property['images'] != null && property['images'].isNotEmpty)
                ? property['images'][0]
                : '';

            return _OwnerNameBuilder(
              dbService: dbService,
              ownerId: ownerId,
              builder: (ownerName) {
                return _AdminPropertyCard(
                  title: title,
                  subtitle: 'By Owner: $ownerName',
                  price: '\$${property['price']}',
                  category: property['category'] ?? 'apartment',
                  listingType: property['type'] ?? 'rent',
                  imageUrl: imageUrl,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailsScreen(property: doc),
                      ),
                    );
                  },
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppTheme.error),
                      onPressed: () => _confirmDelete(context, propertyId),
                      tooltip: 'Delete',
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _AdminPropertyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String category;
  final String listingType;
  final String imageUrl;
  final VoidCallback onTap;
  final List<Widget> actions;

  const _AdminPropertyCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.category,
    required this.listingType,
    required this.imageUrl,
    required this.onTap,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 76,
                  width: 76,
                  color: Colors.grey.shade300,
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Icon(Icons.downloading, color: Colors.grey),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image, color: Colors.grey),
                        )
                      : const Icon(Icons.image, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MiniChip(text: _formatLabel(category)),
                        _MiniChip(text: _formatLabel(listingType)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(children: actions),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerNameBuilder extends StatelessWidget {
  final DatabaseService dbService;
  final String ownerId;
  final Widget Function(String ownerName) builder;

  const _OwnerNameBuilder({
    required this.dbService,
    required this.ownerId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (ownerId.isEmpty) {
      return builder('Unknown owner');
    }

    return FutureBuilder<DocumentSnapshot>(
      future: dbService.getUserProfile(ownerId),
      builder: (context, snapshot) {
        var ownerName = 'Loading owner...';
        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          ownerName = (userData['fullName'] ?? userData['email'] ?? ownerId)
              .toString();
        } else if (snapshot.hasError ||
            snapshot.connectionState == ConnectionState.done) {
          ownerName = ownerId;
        }

        return builder(ownerName);
      },
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String text;

  const _MiniChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _formatLabel(String value) {
  if (value.trim().isEmpty) {
    return 'Property';
  }
  final clean = value.trim().replaceAll('_', ' ');
  return clean[0].toUpperCase() + clean.substring(1);
}
