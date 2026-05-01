import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';
import '../../shared/custom_buttons.dart';
import '../../theme/app_theme.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _bedsCtrl = TextEditingController();
  final TextEditingController _bathsCtrl = TextEditingController();
  final TextEditingController _areaCtrl = TextEditingController();

  String _type = 'rent';
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    _bedsCtrl.dispose();
    _bathsCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final images = await _picker.pickMultiImage(imageQuality: 70);
      if (images.isNotEmpty && mounted) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one image.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final dbService = Provider.of<DatabaseService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final imageUrls = <String>[];
    for (final image in _selectedImages) {
      final url = await dbService.uploadImage(File(image.path));
      if (url != null) {
        imageUrls.add(url);
      }
    }

    if (imageUrls.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image upload failed. Please try again.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
      return;
    }

    final success = await dbService.addProperty(
      ownerId: authService.user!.uid,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      type: _type,
      location: _locationCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim()),
      beds: int.parse(_bedsCtrl.text.trim()),
      baths: int.parse(_bathsCtrl.text.trim()),
      area: double.parse(_areaCtrl.text.trim()),
      images: imageUrls,
    );

    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property submitted. Awaiting Admin Approval.'),
          backgroundColor: AppTheme.warning,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not submit property. Please try again.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Property')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Property photos',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add clear photos first. The admin will review the property before it appears in Home.',
                  style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 16),
                _ImagePickerBox(
                  images: _selectedImages,
                  onPickImages: _pickImages,
                  onRemoveImage: _removeImage,
                ),
                const SizedBox(height: 28),
                Text(
                  'Basic details',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Property Title',
                    hintText: 'Modern apartment in New Cairo',
                    prefixIcon: Icon(Icons.title),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().length < 4) {
                      return 'Please enter a clear property title.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Write a short description for the buyer/renter',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  minLines: 3,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  validator: (value) {
                    if (value == null || value.trim().length < 10) {
                      return 'Please write at least 10 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Location / Address',
                    hintText: 'City, area, or street',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return 'Please enter the property location.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(
                    labelText: 'Listing Type',
                    prefixIcon: Icon(Icons.sell_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'rent', child: Text('Rent')),
                    DropdownMenuItem(value: 'sale', child: Text('Sale')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _type = val);
                    }
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  'Numbers',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    hintText: 'Example: 15000',
                    prefixIcon: Icon(Icons.attach_money_rounded),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) => _validatePositiveNumber(value, 'price'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _bedsCtrl,
                        decoration: const InputDecoration(labelText: 'Beds'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            _validatePositiveInt(value, 'beds'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _bathsCtrl,
                        decoration: const InputDecoration(labelText: 'Baths'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            _validatePositiveInt(value, 'baths'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _areaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Area',
                    hintText: 'Area in square meters',
                    prefixIcon: Icon(Icons.square_foot_outlined),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) => _validatePositiveNumber(value, 'area'),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  isLoading: _isLoading,
                  text: 'Submit for Review',
                  icon: Icons.send_rounded,
                  onPressed: _submitProperty,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePickerBox extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveImage;

  const _ImagePickerBox({
    required this.images,
    required this.onPickImages,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImages,
      child: Container(
        height: images.isEmpty ? 160 : 132,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: images.isEmpty
                ? AppTheme.primary.withValues(alpha: 0.25)
                : AppTheme.border,
          ),
        ),
        child: images.isEmpty
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 42,
                    color: AppTheme.primary,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tap to upload property images',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'At least one image is required',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              )
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length + 1,
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  if (index == images.length) {
                    return Container(
                      width: 92,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppTheme.primary,
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 104,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(File(images[index].path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 16,
                        child: GestureDetector(
                          onTap: () => onRemoveImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppTheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

String? _validatePositiveNumber(String? value, String fieldName) {
  final number = double.tryParse(value?.trim() ?? '');
  if (number == null || number <= 0) {
    return 'Enter a valid $fieldName greater than 0.';
  }
  return null;
}

String? _validatePositiveInt(String? value, String fieldName) {
  final number = int.tryParse(value?.trim() ?? '');
  if (number == null || number <= 0) {
    return 'Enter valid $fieldName.';
  }
  return null;
}
