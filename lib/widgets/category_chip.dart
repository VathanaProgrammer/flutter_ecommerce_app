import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({super.key, required this.name, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(name),
        backgroundColor: selected ? Colors.black : Colors.white,
        labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
      ),
    );
  }
}
