import 'package:dio/dio.dart';
import 'movie.dart';
import 'dart:math';

class MovieApi {
  static const String _apiKey = '5edf2f5ef1dd449dcebb7089840d0fb4';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static final Dio _dio = Dio();

  static Future<List<Movie>> fetchNowPlayingMovies() async {
    try {
      int randomPage = Random().nextInt(5) + 1;
      final url = '$_baseUrl/movie/now_playing?api_key=$_apiKey&language=vi-VN&page=$randomPage';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final List results = response.data['results'];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối API: $e');
    }
  }

  static Future<String?> fetchTrailerKey(int movieId) async {
    try {
      final url = '$_baseUrl/movie/$movieId/videos?api_key=$_apiKey';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final List list = response.data['results'];
        for (var item in list) {
          if (item['site'] == 'YouTube' && item['type'] == 'Trailer') {
            return item['key'];
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}