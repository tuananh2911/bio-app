import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import '../../providers/farm_provider.dart';
import '../../models/warehouse.dart';

class PackagingFormScreen extends StatefulWidget {
  const PackagingFormScreen({super.key});

  @override
  State<PackagingFormScreen> createState() => _PackagingFormScreenState();
}

class _PackagingFormScreenState extends State<PackagingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lotCodeController = TextEditingController();
  final _skuController = TextEditingController();
  final _productNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitWeightController = TextEditingController();
  final _certificationController = TextEditingController();

  DateTime? _packagingDate;
  final List<String> _selectedMaterialIds = [];
  final List<String> _imagePaths = [];
  String? _generatedQrCode;

  @override
  void dispose() {
    _lotCodeController.dispose();
    _skuController.dispose();
    _productNameController.dispose();
    _quantityController.dispose();
    _unitWeightController.dispose();
    _certificationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _packagingDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _packagingDate = picked;
      });
    }
  }

  void _generateQrCode() {
    final qrData = 'PACKAGE:${_lotCodeController.text}:${_skuController.text}:${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _generatedQrCode = qrData;
    });
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

    if (_packagingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày đóng gói')),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số lượng hợp lệ')),
      );
      return;
    }

    final unitWeight = double.tryParse(_unitWeightController.text.trim());
    if (unitWeight == null || unitWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập khối lượng đơn vị hợp lệ')),
      );
      return;
    }

    if (_generatedQrCode == null) {
      _generateQrCode();
    }

    final farmProvider = Provider.of<FarmProvider>(context, listen: false);

    final newPackaging = Packaging(
      id: const Uuid().v4(),
      packagingLotCode: _lotCodeController.text.trim(),
      packagingDate: _packagingDate!,
      sku: _skuController.text.trim(),
      productName: _productNameController.text.trim(),
      materialIds: _selectedMaterialIds,
      quantity: quantity,
      unitWeight: unitWeight,
      packagingCertification: _certificationController.text.trim().isEmpty
          ? null
          : _certificationController.text.trim(),
      qrCode: _generatedQrCode,
      evidenceImages: _imagePaths,
    );

    await farmProvider.addPackaging(newPackaging);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tạo sản phẩm đóng gói')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đóng gói Sản phẩm'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _lotCodeController,
                decoration: const InputDecoration(
                  labelText: 'Mã lô đóng gói *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mã lô';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày đóng gói *',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _packagingDate != null
                        ? DateFormat('dd/MM/yyyy').format(_packagingDate!)
                        : 'Chọn ngày',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(
                  labelText: 'SKU *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập SKU';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên sản phẩm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Consumer<FarmProvider>(
                builder: (context, farmProvider, _) {
                  if (farmProvider.warehouseEntries.isEmpty) {
                    return const Text('Chưa có nguyên liệu trong kho');
                  }
                  return ExpansionTile(
                    title: Text('Nguyên liệu sử dụng (${_selectedMaterialIds.length})'),
                    children: farmProvider.warehouseEntries.map((entry) {
                      final isSelected = _selectedMaterialIds.contains(entry.id);
                      return CheckboxListTile(
                        title: Text('${entry.materialName} - ${entry.quantity} kg'),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedMaterialIds.add(entry.id);
                            } else {
                              _selectedMaterialIds.remove(entry.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Số lượng *',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số lượng';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Số lượng không hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitWeightController,
                      decoration: const InputDecoration(
                        labelText: 'Khối lượng/đơn vị (kg) *',
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
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _certificationController,
                decoration: const InputDecoration(
                  labelText: 'Chứng nhận bao bì',
                ),
              ),
              const SizedBox(height: 24),
              if (_generatedQrCode != null) ...[
                Text(
                  'QR Code',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Center(
                  child: QrImageView(
                    data: _generatedQrCode!,
                    size: 200,
                  ),
                ),
                const SizedBox(height: 16),
              ] else
                ElevatedButton.icon(
                  onPressed: _generateQrCode,
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Tạo QR Code'),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ảnh minh chứng',
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
                child: const Text('Lưu sản phẩm đóng gói'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



