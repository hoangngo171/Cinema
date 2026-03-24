import 'package:flutter/material.dart';
import 'package:movie_home/auth_api.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  bool _uErr = false, _pErr = false, _cErr = false, _loading = false;
  String _msg = '';

  Future<void> _register() async {
    setState(() {
      _uErr = _user.text.trim().isEmpty;
      _pErr = _pass.text.trim().isEmpty;
      _cErr = _confirm.text.trim().isEmpty;
      _msg = '';
    });

    if (_uErr || _pErr || _cErr) return;

    if (_pass.text != _confirm.text) {
      setState(() => _msg = 'Mật khẩu xác nhận không khớp');
      return;
    }

    setState(() => _loading = true);

    // Gọi API DummyJSON đăng ký
    bool isSuccess = await AuthApi.register(_user.text.trim(), _pass.text.trim());

    setState(() => _loading = false);

    if (isSuccess) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công! DummyJSON đã nhận yêu cầu.')),
      );
      Navigator.pop(context); // Trở về Login
    } else {
      setState(() => _msg = 'Đăng ký thất bại. Vui lòng thử lại!');
    }
  }

  Widget _field(TextEditingController c, String label, IconData icon, bool err, {bool pass = false}) {
    return TextField(
      controller: c,
      obscureText: pass,
      onChanged: (_) => setState(() => _msg = ''),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        errorText: err ? 'Không được để trống' : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        centerTitle: true,
        title: const Text('Đăng ký', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_add_alt_1, color: Colors.indigo, size: 80),
              const SizedBox(height: 20),
              const Text('Tạo tài khoản mới',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 30),

              _field(_user, 'Tên đăng nhập', Icons.person_outline, _uErr),
              const SizedBox(height: 16),
              _field(_pass, 'Mật khẩu', Icons.lock_outline, _pErr, pass: true),
              const SizedBox(height: 16),
              _field(_confirm, 'Xác nhận mật khẩu', Icons.lock_reset, _cErr, pass: true),

              if (_msg.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_msg, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _loading ? null : _register,
                  child: _loading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('ĐĂNG KÝ', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}