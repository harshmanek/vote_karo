import 'package:flutter/material.dart';

class Vote {
  final String option;
  final IconData icon;
  int count;

  Vote({required this.option, required this.icon, this.count = 0});
}
