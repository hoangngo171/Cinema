import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../movie.dart';
import '../movie_api.dart';
import 'booking_page.dart'; 
class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  YoutubePlayerController? _ytController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initTrailer();
  }

  Future<void> _initTrailer() async {
    final key = await MovieApi.fetchTrailerKey(widget.movie.id);
    if (key != null && mounted) {
      _ytController = YoutubePlayerController(
        params: const YoutubePlayerParams(showFullscreenButton: true),
      )..loadVideoById(videoId: key);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _ytController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: Text(widget.movie.title, style: const TextStyle(color: Colors.white),),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSection('Trailer', _buildTrailerContent()),
          const SizedBox(height: 24),
          _buildSection('Giới thiệu phim', Text(
            widget.movie.overview.isEmpty ? 'Đang cập nhật...' : widget.movie.overview,
            style: const TextStyle(height: 1.5, fontSize: 16.5, color: Colors.black87),
            textAlign: TextAlign.justify,
          )),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: _buildBottomBtn(),
    );
  }


  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: _boxDecoration(radius: 16, hasShadow: true),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(widget.movie.posterUrl, width: 130, height: 195, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.movie.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo, height: 1.3)),
              const SizedBox(height: 12),
              _iconText(Icons.calendar_today, 'Khởi chiếu: ${widget.movie.releaseDate}',),
              const SizedBox(height: 8),
              _iconText(Icons.star_rounded, '${widget.movie.voteAverage.toStringAsFixed(1)} / 10', color: Colors.amber),
              const SizedBox(height: 16),
              Wrap(spacing: 8, children: ['2D', 'Phụ đề', 'T16'].map(_tag).toList()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: content is Text ? const EdgeInsets.all(16) : null,
          decoration: _boxDecoration(color: content is Text ? Colors.white : Colors.black, radius: 16),
          child: ClipRRect(borderRadius: BorderRadius.circular(16), child: content),
        ),
      ],
    );
  }

  Widget _buildTrailerContent() {
    if (_isLoading) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    if (_ytController == null) return const SizedBox(height: 150, child: Center(child: Text('Không có trailer', style: TextStyle(color: Colors.white))));
    return AspectRatio(aspectRatio: 16 / 9, child: YoutubePlayer(controller: _ytController!));
  }

  Widget _buildBottomBtn() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))]),
      child: SafeArea(
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingPage(movie: widget.movie))),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('ĐẶT VÉ NGAY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }


  BoxDecoration _boxDecoration({double radius = 12, Color color = Colors.white, bool hasShadow = false}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: hasShadow ? [BoxShadow(color: Colors.indigo.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))] : null,
    );
  }

  Widget _iconText(IconData icon, String text, {Color color = Colors.grey}) {
    return Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 6), Text(text, style: const TextStyle(fontWeight: FontWeight.w900))]);
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(color: Colors.indigo, fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }
}