import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../providers/farm_provider.dart';
import '../../models/planting_lot.dart';
import '../../models/farm_zone.dart';

class PlantingLotFormScreen extends StatefulWidget {
  final PlantingLot? lot;
  final String? initialZoneId;

  const PlantingLotFormScreen({super.key, this.lot, this.initialZoneId});

  @override
  State<PlantingLotFormScreen> createState() => _PlantingLotFormScreenState();
}

class _PlantingLotFormScreenState extends State<PlantingLotFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lotCodeController = TextEditingController();
  final _lotNameController = TextEditingController();
  final _varietyController = TextEditingController();
  final _seedSourceController = TextEditingController();
  final _densityController = TextEditingController();
  final _treeCountController = TextEditingController();
  final _soilTestController = TextEditingController();
  
  String? _selectedZoneId;
  DateTime? _plantingDate;
  LotStatus _selectedStatus = LotStatus.preparing;
  final List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    if (widget.lot != null) {
      _lotCodeController.text = widget.lot!.lotCode;
      _lotNameController.text = widget.lot!.lotName;
      _selectedZoneId = widget.lot!.farmZoneId;
      _plantingDate = widget.lot!.plantingDate;
      _varietyController.text = widget.lot!.variety ?? '';
      _seedSourceController.text = widget.lot!.seedSource ?? '';
      _densityController.text = widget.lot!.density?.toString() ?? '';
      _treeCountController.text = widget.lot!.treeCount?.toString() ?? '';
      _soilTestController.text = widget.lot!.soilTestResult ?? '';
      _selectedStatus = widget.lot!.status;
      _imagePaths.addAll(widget.lot!.lotImages);
    } else if (widget.initialZoneId != null) {
      _selectedZoneId = widget.initialZoneId;
    }
  }

  @override
  void dispose() {
    _lotCodeController.dispose();
    _lotNameController.dispose();
    _varietyController.dispose();
    _seedSourceController.dispose();
    _densityController.dispose();
    _treeCountController.dispose();
    _soilTestController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _plantingDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _plantingDate = picked;
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

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedZoneId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn vùng trồng')),
      );
      return;
    }

    if (_plantingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày trồng')),
      );
      return;
    }

    final farmProvider = Provider.of<FarmProvider>(context, listen: false);

    if (widget.lot != null) {
      final updatedLot = PlantingLot(
        id: widget.lot!.id,
        lotCode: _lotCodeController.text.trim(),
        lotName: _lotNameController.text.trim(),
        farmZoneId: _selectedZoneId!,
        plantingDate: _plantingDate!,
        variety: _varietyController.text.trim().isEmpty
            ? null
            : _varietyController.text.trim(),
        seedSource: _seedSourceController.text.trim().isEmpty
            ? null
            : _seedSourceController.text.trim(),
        density: _densityController.text.trim().isEmpty
            ? null
            : double.tryParse(_densityController.text.trim()),
        treeCount: _treeCountController.text.trim().isEmpty
            ? null
            : int.tryParse(_treeCountController.text.trim()),
        soilTestResult: _soilTestController.text.trim().isEmpty
            ? null
            : _soilTestController.text.trim(),
        status: _selectedStatus,
        lotImages: _imagePaths,
        boundary: widget.lot!.boundary,
        createdAt: widget.lot!.createdAt,
        updatedAt: DateTime.now(),
      );
      await farmProvider.updatePlantingLot(updatedLot);
    } else {
      final newLot = PlantingLot(
        id: const Uuid().v4(),
        lotCode: _lotCodeController.text.trim(),
        lotName: _lotNameController.text.trim(),
        farmZoneId: _selectedZoneId!,
        plantingDate: _plantingDate!,
        variety: _varietyController.text.trim().isEmpty
            ? null
            : _varietyController.text.trim(),
        seedSource: _seedSourceController.text.trim().isEmpty
            ? null
            : _seedSourceController.text.trim(),
        density: _densityController.text.trim().isEmpty
            ? null
            : double.tryParse(_densityController.text.trim()),
        treeCount: _treeCountController.text.trim().isEmpty
            ? null
            : int.tryParse(_treeCountController.text.trim()),
        soilTestResult: _soilTestController.text.trim().isEmpty
            ? null
            : _soilTestController.text.trim(),
        status: _selectedStatus,
        lotImages: _imagePaths,
      );
      await farmProvider.addPlantingLot(newLot);
    }

    if (mounted) {
      Navigator.pop(context, true); // Return true to indicate save success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lot == null ? 'Thêm Lô trồng' : 'Chỉnh sửa Lô trồng'),
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
                  if (farmProvider.farmZones.isEmpty) {
                    return const Text('Chưa có vùng trồng nào');
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedZoneId,
                    decoration: const InputDecoration(
                      labelText: 'Vùng trồng *',
                    ),
                    items: farmProvider.farmZones.map((zone) {
                      return DropdownMenuItem(
                        value: zone.id,
                        child: Text(zone.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedZoneId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng chọn vùng trồng';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lotCodeController,
                decoration: const InputDecoration(
                  labelText: 'Mã lô *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mã lô';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lotNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên lô *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên lô';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày trồng *',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _plantingDate != null
                        ? DateFormat('dd/MM/yyyy').format(_plantingDate!)
                        : 'Chọn ngày trồng',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _varietyController,
                decoration: const InputDecoration(
                  labelText: 'Giống',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _seedSourceController,
                decoration: const InputDecoration(
                  labelText: 'Nguồn giống',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _densityController,
                      decoration: const InputDecoration(
                        labelText: 'Mật độ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _treeCountController,
                      decoration: const InputDecoration(
                        labelText: 'Số cây',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _soilTestController,
                decoration: const InputDecoration(
                  labelText: 'Kết quả kiểm nghiệm đất',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<LotStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                ),
                items: LotStatus.values.map((status) {
                  final lot = PlantingLot(
                    id: '',
                    lotCode: '',
                    lotName: '',
                    farmZoneId: '',
                    plantingDate: DateTime.now(),
                    status: status,
                  );
                  return DropdownMenuItem(
                    value: status,
                    child: Text(lot.statusText),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ảnh lô',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate),
                    onPressed: _pickImage,
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



