import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/farm_provider.dart';
import '../../models/farm_zone.dart';
import '../../utils/image_helper.dart';

class FarmZoneFormScreen extends StatefulWidget {
  final FarmZone? zone;

  const FarmZoneFormScreen({super.key, this.zone});

  @override
  State<FarmZoneFormScreen> createState() => _FarmZoneFormScreenState();
}

class _FarmZoneFormScreenState extends State<FarmZoneFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _addressController = TextEditingController();
  final _adminAddressController = TextEditingController();
  final _landHistoryController = TextEditingController();
  final List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    if (widget.zone != null) {
      _nameController.text = widget.zone!.name;
      _companyController.text = widget.zone!.company ?? '';
      _addressController.text = widget.zone!.address ?? '';
      _adminAddressController.text = widget.zone!.administrativeAddress ?? '';
      _landHistoryController.text = widget.zone!.landHistory ?? '';
      _imagePaths.addAll(widget.zone!.overviewImages);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _adminAddressController.dispose();
    _landHistoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePaths.add(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imagePaths.add(image.path);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final farmProvider = Provider.of<FarmProvider>(context, listen: false);

    if (widget.zone != null) {
      // Update existing zone
      final updatedZone = FarmZone(
        id: widget.zone!.id,
        name: _nameController.text.trim(),
        company: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        administrativeAddress: _adminAddressController.text.trim().isEmpty
            ? null
            : _adminAddressController.text.trim(),
        landHistory: _landHistoryController.text.trim().isEmpty
            ? null
            : _landHistoryController.text.trim(),
        overviewImages: _imagePaths,
        boundary: widget.zone!.boundary,
        createdAt: widget.zone!.createdAt,
        updatedAt: DateTime.now(),
      );
      await farmProvider.updateFarmZone(updatedZone);
    } else {
      // Create new zone
      final newZone = FarmZone(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        company: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        administrativeAddress: _adminAddressController.text.trim().isEmpty
            ? null
            : _adminAddressController.text.trim(),
        landHistory: _landHistoryController.text.trim().isEmpty
            ? null
            : _landHistoryController.text.trim(),
        overviewImages: _imagePaths,
      );
      await farmProvider.addFarmZone(newZone);
    }

    if (mounted) {
      Navigator.pop(context, true); // Return true to indicate save success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.zone == null ? 'Thêm Vùng trồng' : 'Chỉnh sửa Vùng trồng'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên vùng trồng *',
                  hintText: 'Nhập tên vùng trồng',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên vùng trồng';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Doanh nghiệp quản lý',
                  hintText: 'Nhập tên doanh nghiệp',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  hintText: 'Nhập địa chỉ vùng trồng',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adminAddressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ hành chính',
                  hintText: 'Nhập địa chỉ hành chính',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _landHistoryController,
                decoration: const InputDecoration(
                  labelText: 'Hồ sơ lịch sử đất',
                  hintText: 'Nhập thông tin lịch sử đất',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              // Image section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ảnh tổng quan',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_library),
                        onPressed: _pickImage,
                        tooltip: 'Chọn từ thư viện',
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: _takePhoto,
                        tooltip: 'Chụp ảnh',
                      ),
                    ],
                  ),
                ],
              ),
              if (_imagePaths.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imagePaths.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_imagePaths[index]),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.red,
                                child: IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  color: Colors.white,
                                  onPressed: () => _removeImage(index),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



