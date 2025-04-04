// lib/features/todo/data/models/category_model.dart
import 'package:flutter/material.dart';

class Category {
  final String id;
  final String title;
  final String color; // Now storing color as HEX string like "#FFB6B9"

  Category({
    required this.id,
    required this.title,
    required this.color,
  });

  // Convert from JSON to Category object
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      color: json['color'] ?? '#FFFFFF', // Default to white if no color
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'color': color,
    };
  }

  // Helper method to convert HEX string to Color object
  static Color hexToColor(String hexString) {
    final hexColor = hexString.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  // Helper method to get Color object from category
  Color get colorValue {
    return hexToColor(color);
  }

  // Create a copy of this category with some fields replaced
  Category copyWith({
    String? id,
    String? title,
    String? color,
  }) {
    return Category(
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
    );
  }
}
