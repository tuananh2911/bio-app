import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/farm_provider.dart';
import '../../models/warehouse.dart';
import 'warehouse_entry_form_screen.dart';
import 'packaging_form_screen.dart';

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Kho'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Nguyên liệu khô'),
            Tab(text: 'Đóng gói'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _WarehouseEntriesTab(),
          _PackagingTab(),
        ],
      ),
    );
  }
}

class _WarehouseEntriesTab extends StatelessWidget {
  const _WarehouseEntriesTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, _) {
          if (farmProvider.warehouseEntries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warehouse_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có nguyên liệu nào trong kho',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: farmProvider.warehouseEntries.length,
            itemBuilder: (context, index) {
              final entry = farmProvider.warehouseEntries[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.inventory, color: Colors.blue[700]),
                  ),
                  title: Text(
                    entry.materialName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ngày nhập: ${DateFormat('dd/MM/yyyy').format(entry.entryDate)}'),
                      Text('Khối lượng: ${entry.quantity} kg'),
                      if (entry.location != null) Text('Vị trí: ${entry.location}'),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WarehouseEntryFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nhập kho'),
      ),
    );
  }
}

class _PackagingTab extends StatelessWidget {
  const _PackagingTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, _) {
          if (farmProvider.packagings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có sản phẩm đóng gói nào',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: farmProvider.packagings.length,
            itemBuilder: (context, index) {
              final packaging = farmProvider.packagings[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple[100],
                    child: Icon(Icons.inventory_2, color: Colors.purple[700]),
                  ),
                  title: Text(
                    packaging.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mã lô: ${packaging.packagingLotCode}'),
                      Text('SKU: ${packaging.sku}'),
                      Text('Số lượng: ${packaging.quantity}'),
                      Text('Khối lượng: ${packaging.unitWeight} kg/đơn vị'),
                    ],
                  ),
                  trailing: packaging.qrCode != null
                      ? Icon(Icons.qr_code, color: Colors.green[700])
                      : const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PackagingFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Đóng gói'),
      ),
    );
  }
}



