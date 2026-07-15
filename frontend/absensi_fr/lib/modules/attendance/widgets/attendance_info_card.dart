import 'package:flutter/material.dart';

class AttendanceInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const AttendanceInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}