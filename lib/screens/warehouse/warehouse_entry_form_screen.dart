import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../providers/farm_provider.dart';
import '../../models/warehouse.dart';

class WarehouseEntryFormScreen extends StatefulWidget {
  const WarehouseEntryFormScreen({super.key});

  @override
  State<WarehouseEntryFormScreen> createState() =>
      _WarehouseEntryFormScreenState();
}

class _WarehouseEntryFormScreenState extends State<WarehouseEntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _materialNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _entryDate;

  @override
  void dispose() {
    _materialNameController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _entryDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _entryDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_entryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày nhập kho')),
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

    final newEntry = WarehouseEntry(
      id: const Uuid().v4(),
      entryDate: _entryDate!,
      materialName: _materialNameController.text.trim(),
      quantity: quantity,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
    );

    await farmProvider.addWarehouseEntry(newEntry);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm nguyên liệu vào kho')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập kho Nguyên liệu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _materialNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên nguyên liệu *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên nguyên liệu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày nhập kho *',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _entryDate != null
                        ? DateFormat('dd/MM/yyyy').format(_entryDate!)
                        : 'Chọn ngày',
                  ),
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
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Vị trí trong kho',
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



