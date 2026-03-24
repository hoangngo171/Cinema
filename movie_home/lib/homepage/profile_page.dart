import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = '';
  String _userEmail = '';
  String _userImage = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Tên người dùng';
      _userEmail = prefs.getString('userEmail') ?? 'Chưa có email';
      _userImage = prefs.getString('userImage') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ của tôi'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.indigo[100],
              backgroundImage: _userImage.isNotEmpty ? NetworkImage(_userImage) : null,
              child: _userImage.isEmpty ? const Icon(Icons.person, size: 60, color: Colors.indigo) : null,
            ),
            const SizedBox(height: 24),
            Text(_userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 8),
            Text(_userEmail, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}