import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../providers/farm_provider.dart';
import '../../models/care_log.dart';
import '../../models/planting_lot.dart';

class CareLogFormScreen extends StatefulWidget {
  const CareLogFormScreen({super.key});

  @override
  State<CareLogFormScreen> createState() => _CareLogFormScreenState();
}

class _CareLogFormScreenState extends State<CareLogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _materialsController = TextEditingController();
  final _certificationController = TextEditingController();
  final _performedByController = TextEditingController();

  String? _selectedLotId;
  ActivityType _selectedActivity = ActivityType.other;
  DateTime? _activityDate;
  final List<String> _imagePaths = [];

  @override
  void dispose() {
    _descriptionController.dispose();
    _materialsController.dispose();
    _certificationController.dispose();
    _performedByController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _activityDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _activityDate = picked;
      });
    }
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

    if (_selectedLotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn lô trồng')),
      );
      return;
    }

    if (_activityDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày hoạt động')),
      );
      return;
    }

    final farmProvider = Provider.of<FarmProvider>(context, listen: false);

    final newLog = CareLog(
      id: const Uuid().v4(),
      plantingLotId: _selectedLotId!,
      activityType: _selectedActivity,
      activityDate: _activityDate!,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      materialsUsed: _materialsController.text.trim().isEmpty
          ? null
          : _materialsController.text.trim(),
      materialCertification: _certificationController.text.trim().isEmpty
          ? null
          : _certificationController.text.trim(),
      performedBy: _performedByController.text.trim().isEmpty
          ? null
          : _performedByController.text.trim(),
      evidenceImages: _imagePaths,
    );

    await farmProvider.addCareLog(newLog);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã ghi nhật ký thành công')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi Nhật ký Chăm sóc'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer<FarmProvider>(
                builder: (context, farmProvider, _) {
                  if (farmProvider.plantingLots.isEmpty) {
                    return const Text('Chưa có lô trồng nào');
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedLotId,
                    decoration: const InputDecoration(
                      labelText: 'Lô trồng *',
                    ),
                    items: farmProvider.plantingLots.map((lot) {
                      return DropdownMenuItem(
                        value: lot.id,
                        child: Text('${lot.lotName} (${lot.lotCode})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLotId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng chọn lô trồng';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ActivityType>(
                value: _selectedActivity,
                decoration: const InputDecoration(
                  labelText: 'Loại hoạt động *',
                ),
                items: ActivityType.values.map((type) {
                  final log = CareLog(
                    id: '',
                    plantingLotId: '',
                    activityType: type,
                    activityDate: DateTime.now(),
                  );
                  return DropdownMenuItem(
                    value: type,
                    child: Text(log.activityTypeText),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedActivity = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày hoạt động *',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _activityDate != null
                        ? DateFormat('dd/MM/yyyy').format(_activityDate!)
                        : 'Chọn ngày',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả hoạt động',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _materialsController,
                decoration: const InputDecoration(
                  labelText: 'Vật tư sử dụng',
                  hintText: 'Loại, lượng vật tư',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _certificationController,
                decoration: const InputDecoration(
                  labelText: 'Giấy chứng nhận vật tư',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _performedByController,
                decoration: const InputDecoration(
                  labelText: 'Người thực hiện',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ảnh minh chứng',
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
                child: const Text('Lưu nhật ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



