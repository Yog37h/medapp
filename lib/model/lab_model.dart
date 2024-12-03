// lib/models/lab_model.dart

import 'package:flutter/material.dart';

class Lab {
  final String name;
  final String domain;
  final String about;
  final List<Map<String, String>> faqs;
  final List<String> benefits;
  final Icon icon;


  Lab({
    required this.name,
    required this.domain,
    required this.about,
    required this.faqs,
    required this.benefits,
    required this.icon,
  });
}