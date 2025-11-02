import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.green[100],
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          authProvider.userName ?? 'Người dùng',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (authProvider.userId != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'ID: ${authProvider.userId}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Account Information
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person, color: Colors.green[700]),
                        title: const Text('Tên đăng nhập'),
                        subtitle: Text(authProvider.userName ?? 'Chưa có'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to edit username
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.email, color: Colors.green[700]),
                        title: const Text('Email'),
                        subtitle: Text(authProvider.email ?? 'Chưa cập nhật'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to edit email
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.phone, color: Colors.green[700]),
                        title: const Text('Số điện thoại'),
                        subtitle: Text(authProvider.phone ?? 'Chưa cập nhật'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to edit phone
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Settings
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.settings, color: Colors.green[700]),
                        title: const Text('Cài đặt'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to settings
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.help_outline, color: Colors.green[700]),
                        title: const Text('Trợ giúp'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to help
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.info_outline, color: Colors.green[700]),
                        title: const Text('Về ứng dụng'),
                        subtitle: const Text('Version 1.0.0'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _showAboutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận đăng xuất'),
                          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Đăng xuất'),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirm == true) {
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                        }
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Đăng xuất'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Về ứng dụng'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bio App - Quản lý Quy trình Canh tác'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Ứng dụng hỗ trợ nông dân quản lý toàn bộ quy trình canh tác, từ vùng trồng, lô trồng, nhật ký chăm sóc đến thu hoạch, sơ chế và quản lý kho.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

