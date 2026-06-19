import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/movie.dart';

class MoviesApi {
  static Future<List<Movie>> fetchMovies() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final String jsonString = await rootBundle.loadString('assets/movies.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => Movie.fromJson(j)).toList();
  }
}
