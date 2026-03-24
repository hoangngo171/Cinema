import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_home/movie.dart';
import 'package:movie_home/movie_api.dart';
import 'package:movie_home/homepage/login.dart';
import 'movie_detail_page.dart';
import 'profile_page.dart';
import 'package:movie_home/homepage/my_tickets_page.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieListPage extends StatefulWidget {
  const MovieListPage({super.key});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  late Future<List<Movie>> _movies;
  String _userAvatarUrl = '';

  @override
  void initState() {
    super.initState();
    _movies = MovieApi.fetchNowPlayingMovies();
    _loadUserAvatar();
  }

  Future<void> _loadUserAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userAvatarUrl = prefs.getString('userImage') ?? '';
    });
  }

  Future<void> _openGitHub() async {
    final Uri url = Uri.parse('https://github.com/hoangngo171');
    if (await canLaunchUrl(url)) {
      // Mở link bằng trình duyệt mặc định của điện thoại
      await launchUrl(url, mode: LaunchMode.externalApplication); 
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở được link GitHub!')),
      );
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // Nút Menu bên trái (Drawer)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.movie_filter, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text('Cinema App', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // THÊM: Mục Vé của tôi trong Drawer
            ListTile(
              leading: const Icon(Icons.confirmation_number_outlined, color: Colors.indigo),
              title: const Text('Vé của tôi'),
              onTap: () {
                Navigator.pop(context); // Đóng menu trước
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyTicketsPage()));
              },
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.code, color: Colors.black87),
              title: const Text('Mã nguồn GitHub'),
              onTap: () {
                Navigator.pop(context); // Đóng menu trượt lại
                _openGitHub(); // Gọi hàm mở web
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent)),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('🎬 Phim đang chiếu', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // THÊM LẠI: Nút Vé của tôi trên AppBar
          IconButton(
            icon: const Icon(
              Icons.confirmation_number_outlined,
              color: Colors.indigo,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyTicketsPage()),
            ),
          ),
          
          // Nút Profile bên phải
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ).then((_) => _loadUserAvatar()), 
            child: Padding(
              padding: const EdgeInsets.only(right: 16, left: 8),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.indigo[100],
                backgroundImage: _userAvatarUrl.isNotEmpty ? NetworkImage(_userAvatarUrl) : null,
                child: _userAvatarUrl.isEmpty ? const Icon(Icons.person, size: 20, color: Colors.indigo) : null,
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Movie>>(
        future: _movies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return const Center(child: Text('Không thể tải phim.'));

          final movies = snapshot.data ?? [];
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) => MovieCard(movie: movies[index]),
          );
        },
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailPage(movie: movie)),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(movie.posterUrl, fit: BoxFit.cover, width: double.infinity),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(movie.voteAverage.toStringAsFixed(1), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}