import 'package:flutter/material.dart';

class Movie {
  final int id;
  final String title;
  final String description;
  final int year;
  final String duration;
  final double rating;
  final int ageRating;
  final String category;
  final bool popular;
  final String image;
  final String trailerId;

  const Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.year,
    required this.duration,
    required this.rating,
    required this.ageRating,
    required this.category,
    required this.popular,
    required this.image,
    required this.trailerId,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      year: json['year'],
      duration: json['duration'],
      rating: (json['rating'] as num).toDouble(),
      ageRating: json['ageRating'],
      category: json['category'],
      popular: json['popular'],
      image: json['image'],
      trailerId: json['trailerId'],
    );
  }

  String get ageLabel {
    if (ageRating == 0) return 'ATP';
    return '+$ageRating';
  }

  Color get ageLabelColor {
    if (ageRating == 0) return const Color(0xFF4CAF50);
    if (ageRating == 13) return const Color(0xFF2196F3);
    if (ageRating == 16) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
}
