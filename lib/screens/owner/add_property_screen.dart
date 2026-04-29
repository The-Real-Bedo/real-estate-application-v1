import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/db_service.dart';
import '../../services/auth_service.dart';
import '../../shared/custom_buttons.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({Key? key}) : super(key: key);

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
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
  List<XFile> _selectedImages = [];

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 70, 
      );
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      debugPrint('Error picking images: \$e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitProperty() async {
    setState(() => _isLoading = true);
    
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (authService.user == null) {
      setState(() => _isLoading = false);
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image.'), backgroundColor: AppTheme.error),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Upload Images
    List<String> imageUrls = [];
    for (var i = 0; i < _selectedImages.length; i++) {
      String? url = await dbService.uploadImage(File(_selectedImages[i].path));
      if (url != null) {
        imageUrls.add(url);
      }
    }

    bool success = await dbService.addProperty(
      ownerId: authService.user!.uid,
      title: _titleCtrl.text,
      description: _descCtrl.text,
      type: _type,
      location: _locationCtrl.text,
      price: double.tryParse(_priceCtrl.text) ?? 0.0,
      beds: int.tryParse(_bedsCtrl.text) ?? 1,
      baths: int.tryParse(_bathsCtrl.text) ?? 1,
      area: double.tryParse(_areaCtrl.text) ?? 0.0,
      images: imageUrls,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property submitted. Awaiting Admin Approval.'),
          backgroundColor: AppTheme.warning,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Property', style: TextStyle(color: AppTheme.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _selectedImages.isEmpty 
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 40, color: AppTheme.textSecondary),
                        SizedBox(height: 8),
                        Text('Upload Property Images', style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(File(_selectedImages[index].path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 12,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
              ),
            ),
            const SizedBox(height: 24),
            
            TextFormField(controller: _titleCtrl, decoration: const InputDecoration(hintText: 'Property Title', prefixIcon: Icon(Icons.title))),
            const SizedBox(height: 16),
            TextFormField(controller: _descCtrl, decoration: const InputDecoration(hintText: 'Description', prefixIcon: Icon(Icons.description))),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: TextFormField(controller: _priceCtrl, decoration: const InputDecoration(hintText: 'Price (\$)'), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(hintText: 'Type'),
                    items: const [
                      DropdownMenuItem(value: 'rent', child: Text('Rent')),
                      DropdownMenuItem(value: 'sale', child: Text('Sale')),
                    ],
                    onChanged: (val) => setState(() => _type = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(controller: _locationCtrl, decoration: const InputDecoration(hintText: 'Location / Address', prefixIcon: Icon(Icons.location_on_outlined))),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: TextFormField(controller: _bedsCtrl, decoration: const InputDecoration(hintText: 'Beds'), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(controller: _bathsCtrl, decoration: const InputDecoration(hintText: 'Baths'), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(controller: _areaCtrl, decoration: const InputDecoration(hintText: 'Area (m²)'), keyboardType: TextInputType.number)),
              ],
            ),
            
            const SizedBox(height: 48),
            PrimaryButton(
              isLoading: _isLoading,
              text: 'Submit for Review',
              onPressed: _submitProperty,
            ),
          ],
        ),
      ),
    );
  }
}
