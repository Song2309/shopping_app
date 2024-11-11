import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {

  // Hàm xây dựng một mục setting chung với khung bao quanh
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5, // Độ sâu của bóng đổ
      margin: EdgeInsets.symmetric(vertical: 8), // Khoảng cách trên dưới giữa các mục
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Padding cho nội dung
        leading: Icon(icon, size: 30),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Language Section
            _buildSettingItem(
              icon: Icons.language,
              title: 'Language',
              onTap: () {
                // Tác vụ khi chọn Language
              },
            ),

            // Notification Section
            _buildSettingItem(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {
                // Tác vụ khi chọn Notifications
              },
            ),

            // Terms of Use Section
            _buildSettingItem(
              icon: Icons.description,
              title: 'Terms of Use',
              onTap: () {
                // Tác vụ khi chọn Terms of Use
              },
            ),

            // Privacy Policy Section
            _buildSettingItem(
              icon: Icons.lock,
              title: 'Privacy Policy',
              onTap: () {
                // Tác vụ khi chọn Privacy Policy
              },
            ),

            // Chat Support Section
            _buildSettingItem(
              icon: Icons.chat,
              title: 'Chat Support',
              onTap: () {
                // Tác vụ khi chọn Chat Support
              },
            ),
          ],
        ),
      ),
    );
  }
}
