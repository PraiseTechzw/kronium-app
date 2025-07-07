import 'package:flutter/material.dart';

class Project {
  final String title;
  final String date;
  final String status;
  final double progress;
  final Color color;
  final IconData icon;
  final String details;
  final String client;
  final String location;
  final List<String> team;
  final List<String> images;

  Project({
    required this.title,
    required this.date,
    required this.status,
    required this.progress,
    required this.color,
    required this.icon,
    required this.details,
    required this.client,
    required this.location,
    required this.team,
    required this.images,
  });
}