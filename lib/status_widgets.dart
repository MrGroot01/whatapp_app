import 'dart:convert';
import 'dart:math' as math;

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';

// The green ring around an avatar: one segment per status.
// Segments of statuses I have already seen are grey.
class StatusRingPainter extends CustomPainter {
  final int count;
  final int seen;

  const StatusRingPainter({required this.count, required this.seen});

  @override
  void paint(Canvas canvas, Size size) {
    if (count <= 0) return;

    const stroke = 3.0;
    const grey = Color(0xFFB8C2C0);
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    if (count == 1) {
      paint.color = seen >= 1 ? grey : AppColors.emeraldLight;
      canvas.drawArc(rect, 0, math.pi * 2, false, paint);
      return;
    }

    const gap = 0.16;
    final sweep = (math.pi * 2 - count * gap) / count;
    for (var i = 0; i < count; i++) {
      paint.color = i < seen ? grey : AppColors.emeraldLight;
      canvas.drawArc(
        rect,
        -math.pi / 2 + i * (sweep + gap) + gap / 2,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StatusRingPainter old) =>
      old.count != count || old.seen != seen;
}

// A profile picture (live from the public profile) with the status ring.
class StatusAvatar extends StatelessWidget {
  final String uid;
  final String name;
  final Color color;
  final double radius;
  final int count; // number of statuses (0 = no ring)
  final int seen; // how many of them I have seen

  const StatusAvatar({
    super.key,
    required this.uid,
    required this.name,
    required this.color,
    this.radius = 26,
    this.count = 0,
    this.seen = 0,
  });

  @override
  Widget build(BuildContext context) {
    final size = (radius + 5) * 2;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: StatusRingPainter(count: count, seen: seen),
        child: Center(
          child: StreamBuilder<DatabaseEvent>(
            stream: uid.isEmpty
                ? null
                : FirebaseDatabase.instance
                .ref('publicProfiles/$uid/photoBase64')
                .onValue,
            builder: (context, snapshot) {
              final value = snapshot.data?.snapshot.value;
              final encoded = value is String ? value : '';

              MemoryImage? photo;
              if (encoded.isNotEmpty) {
                try {
                  photo = MemoryImage(base64Decode(encoded));
                } catch (_) {}
              }

              return CircleAvatar(
                radius: radius,
                backgroundColor: color,
                backgroundImage: photo,
                child: photo == null
                    ? Text(
                  initial,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: radius * 0.85,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }
}