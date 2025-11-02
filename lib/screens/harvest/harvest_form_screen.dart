import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../providers/farm_provider.dart';
import '../../models/harvest.dart';

class HarvestFormScreen extends StatefulWidget {
  const HarvestFormScreen({super.key});

  @override
  State<HarvestFormScreen> createState() => _HarvestFormScreenState();
}

class _HarvestFormScreenState extends State<HarvestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _harvestGroupController = TextEditingController();
  final _quantityController = TextEditingController();

  String? _selectedLotId;
  DateTime? _harvestDate;
  bool _dnaSampleTaken = false;
  final List<String> _imagePaths = [];

  @override
  void dispose() {
    _harvestGroupController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _harvestDate = picked;
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

    if (_selectedLotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn lô trồng')),
      );
      return;
    }

    if (_harvestDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày thu hoạch')),
      );
      return;
    }

    final quantity = double.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập khối lượng hợp lệ')),
      );
      return;
    }

    final farmProvider = Provider.of<FarmProvider>(context, listen: false);

    final newHarvest = Harvest(
      id: const Uuid().v4(),
      plantingLotId: _selectedLotId!,
      harvestDate: _harvestDate!,
      harvestGroup: _harvestGroupController.text.trim().isEmpty
          ? null
          : _harvestGroupController.text.trim(),
      quantity: quantity,
      dnaSampleTaken: _dnaSampleTaken,
      harvestImages: _imagePaths,
    );

    await farmProvider.addHarvest(newHarvest);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã ghi thu hoạch thành công')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi Thu hoạch'),
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
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày thu hoạch *',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _harvestDate != null
                        ? DateFormat('dd/MM/yyyy').format(_harvestDate!)
                        : 'Chọn ngày',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _harvestGroupController,
                decoration: const InputDecoration(
                  labelText: 'Nhóm thực hiện',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Khối lượng (kg) *',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập khối lượng';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Khối lượng không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Đã lấy mẫu DNA'),
                value: _dnaSampleTaken,
                onChanged: (value) {
                  setState(() {
                    _dnaSampleTaken = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ảnh thu hoạch',
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
                child: const Text('Lưu thu hoạch'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



