// lib/features/todo/data/models/category_model.dart

import 'package:flutter/material.dart';

class Category {
  final String id;
  final String title;
  final String color;

  const Category({
    required this.id,
    required this.title,
    required this.color,
  });

  // Helper method to get the color as a Flutter Color object
  Color getColorValue() {
    try {
      return Color(int.parse(color));
    } catch (e) {
      // Fallback to a default color if parsing fails
      return Colors.blue.shade200;
    }
  }

  // Helper method to set color from a Flutter Color object
  static String colorToString(Color color) {
    return color.value.toString();
  }

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

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      color: json['color'] ?? Colors.blue.shade200.value.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'color': color,
    };
  }

  @override
  String toString() {
    return 'Category(id: $id, title: $title, color: $color)';
  }
}
