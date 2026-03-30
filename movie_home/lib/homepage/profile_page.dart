import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('userData');

    if (raw != null) {
      try {
        final data = jsonDecode(raw);
        setState(() {
          _userData = data;
        });
      } catch (e) {
        debugPrint("JSON ERROR: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name =
        "${_userData?['firstName'] ?? ''} ${_userData?['lastName'] ?? ''}";
    final email = _userData?['email'] ?? 'Chưa có email';
    final image = _userData?['image'] ?? '';
    final token = _userData?['token'] ?? 'Không có token';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ của tôi'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ===== AVATAR =====
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.indigo[100],
                backgroundImage:
                    image.isNotEmpty ? NetworkImage(image) : null,
                child: image.isEmpty
                    ? const Icon(Icons.person,
                        size: 50, color: Colors.indigo)
                    : null,
              ),

              const SizedBox(height: 16),

              Text(name,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo)),

              const SizedBox(height: 6),
              Text(email, style: const TextStyle(color: Colors.grey)),

              const SizedBox(height: 24),

              // ===== CARD =====
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Thông tin cá nhân",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: _field("Họ và tên", name)),
                        const SizedBox(width: 12),
                        Expanded(child: _field("Ngày sinh", _userData?['birthDate'])),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(child: _field("Số điện thoại", _userData?['phone'])),
                        const SizedBox(width: 12),
                        Expanded(child: _field("Email", email)),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(child: _field("Tuổi", _userData?['age'])),
                        const SizedBox(width: 12),
                        Expanded(child: _field("Giới tính", _userData?['gender'])),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(child: _field("Chiều cao", _userData?['height'])),
                        const SizedBox(width: 12),
                        Expanded(child: _field("Cân nặng", _userData?['weight'])),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _field(
                      "Địa chỉ",
                      "${_userData?['address']?['address'] ?? ''}, ${_userData?['address']?['city'] ?? ''}",
                    ),
                    const SizedBox(height: 20),
                    
                    const SizedBox(height: 12),

                    _field("Quốc gia", _userData?['address']?['country']),

                    const SizedBox(height: 12),

                    _field("Trường đại học", _userData?['university']),

                    const SizedBox(height: 12),

                    _field("Phòng ban", _userData?['company']?['department']),

                    const SizedBox(height: 12),

                    _field("Công ty", _userData?['company']?['name']),

                    const SizedBox(height: 12),

                    _field("Chức vụ", _userData?['company']?['title']),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===== TOKEN =====
              // ===== ACCESS TOKEN =====
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      "Access Token",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
    ),

    const SizedBox(height: 8),

    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300), // 🔥 thêm viền
      ),
      child: SelectableText(
        token,
        style: const TextStyle(fontSize: 13),
      ),
    ),
  ],
),
            ],
          ),
        ),
      ),
    );
  }

  // ===== FIELD UI =====
  Widget _field(String title, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 13, color: Colors.grey)),

        const SizedBox(height: 6),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value?.toString().isNotEmpty == true
                ? value.toString()
                : "N/A",
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }
}