import 'package:flutter/material.dart';

// One saved contact (a person I can chat with).
class Contact {
  final String id;
  final String name;
  final String phone;
  final String countryCode;
  final String message;
  final String time;
  final Color color;

  const Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.countryCode,
    this.message = 'Tap to start chatting',
    this.time = '',
    this.color = const Color(0xFF009688),
  });

  factory Contact.fromMap(String id, Map<dynamic, dynamic> map) {
    return Contact(
      id: id,
      name: (map['name'] ?? 'Contact').toString(),
      phone: (map['phone'] ?? '').toString(),
      countryCode: (map['countryCode'] ?? '+91').toString(),
      message: (map['lastMessage'] ?? 'Tap to start chatting').toString(),
      time: (map['time'] ?? '').toString(),
      color: _colorFromId(id),
    );
  }

  static Color _colorFromId(String id) {
    const colors = [
      Color(0xFFE91E63),
      Color(0xFF3F51B5),
      Color(0xFF009688),
      Color(0xFFFF9800),
      Color(0xFF9C27B0),
      Color(0xFF795548),
      Color(0xFF607D8B),
      Color(0xFFF44336),
      Color(0xFF4CAF50),
      Color(0xFF2196F3),
    ];
    return colors[id.hashCode.abs() % colors.length];
  }
}