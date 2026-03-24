import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_home/auth_api.dart';
import 'movie_list_page.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _user = TextEditingController();
  final _pass = TextEditingController();

  bool _uErr = false, _pErr = false, _loading = false;
  String _msg = '';

  Future<void> _login() async {
    final u = _user.text.trim();
    final p = _pass.text.trim();

    setState(() {
      _uErr = u == '';
      _pErr = p == '';
      _msg = '';
    });
    if (_uErr || _pErr) return;

    setState(() => _loading = true);

    // Dùng Dio gọi DummyJSON
    final userData = await AuthApi.login(u, p);

    if (userData != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggedIn', true);
      await prefs.setString('accessToken', userData['accessToken'] ?? 'Lỗi: Không lấy được token từ API');
      await prefs.setString('currentUser', userData['username']);
      await prefs.setString('userImage', userData['image'] ?? '');
      await prefs.setString('userName', '${userData['firstName']} ${userData['lastName']}');
      await prefs.setString('userEmail', userData['email'] ?? '');
      
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MovieListPage()),
      );
    } else {
      setState(() => _msg = 'Sai tài khoản/mật khẩu!\n(Test thử: emilys / emilyspass)');
    }
    setState(() => _loading = false);
  }

  Widget _input(TextEditingController c, String t, IconData i, bool e, {bool pw = false}) {
    return TextField(
      controller: c,
      obscureText: pw,
      decoration: InputDecoration(
        labelText: t,
        prefixIcon: Icon(i, color: Colors.indigo),
        errorText: e ? 'Không được để trống' : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.indigo),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.movie_creation_rounded, size: 96, color: Colors.indigo),
              const SizedBox(height: 20),
              const Text('Cinema Booking', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              _input(_user, 'Tài khoản', Icons.person, _uErr),
              const SizedBox(height: 16),
              _input(_pass, 'Mật khẩu', Icons.lock, _pErr, pw: true),

              if (_msg != '')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('ĐĂNG NHẬP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.indigo),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('ĐĂNG KÝ', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}