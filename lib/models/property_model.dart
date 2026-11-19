class PropertyModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String category;
  final String type;
  final String location;
  final double? latitude;
  final double? longitude;
  final double price;
  final int beds;
  final int baths;
  final double area;
  final String status;
  final List<String> images;
  final DateTime? createdAt;

  const PropertyModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.location,
    this.latitude,
    this.longitude,
    required this.price,
    required this.beds,
    required this.baths,
    required this.area,
    this.status = 'pending',
    this.images = const [],
    this.createdAt,
  });

  factory PropertyModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return PropertyModel(
      id: id ?? map['id']?.toString() ?? '',
      ownerId: map['ownerId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? 'apartment',
      type: map['type']?.toString() ?? 'rent',
      location: map['location']?.toString() ?? '',
      latitude: _toDouble(map['latitude']),
      longitude: _toDouble(map['longitude']),
      price: _toDouble(map['price']) ?? 0.0,
      beds: _toInt(map['beds']),
      baths: _toInt(map['baths']),
      area: _toDouble(map['area']) ?? 0.0,
      status: map['status']?.toString() ?? 'pending',
      images: (map['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      'status': status,
      'images': images,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Helper method to maintain drop-in compatibility with legacy map access
  Map<String, dynamic> data() => toMap();

  PropertyModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? category,
    String? type,
    String? location,
    double? latitude,
    double? longitude,
    double? price,
    int? beds,
    int? baths,
    double? area,
    String? status,
    List<String>? images,
    DateTime? createdAt,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      price: price ?? this.price,
      beds: beds ?? this.beds,
      baths: baths ?? this.baths,
      area: area ?? this.area,
      status: status ?? this.status,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }
}
