import 'package:flutter/material.dart';

// Helper function to get month name
String getMonthName(int month) {
  List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                         "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  return months[month - 1];
}

// Helper function to get short day name
String getShortDayName(int weekday) {
  List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  return days[weekday - 1];
}

// Helper function to format date with day name
String formatDateWithDay(DateTime date) {
  List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                         "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  
  String dayName = days[date.weekday - 1];
  String monthName = months[date.month - 1];
  
  return "$dayName, $monthName ${date.day}";
}

// Helper function to format time with AM/PM
String formatTime(DateTime date) {
  int hour = date.hour % 12;
  if (hour == 0) hour = 12;
  String minute = date.minute.toString().padLeft(2, '0');
  String period = date.hour < 12 ? "AM" : "PM";
  
  return "$hour:$minute $period";
}

// Helper function to capitalize first letter
String capitalizeFirst(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

Color getCategoryColor(String category) {
  switch (category) {
    case 'Task':
      return Colors.blue[200]!;
    case 'Event':
      return Colors.purple[200]!;
    default:
      return Colors.pink[200]!;
  }
}