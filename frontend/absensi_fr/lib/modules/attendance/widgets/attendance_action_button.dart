import 'package:flutter/material.dart';

class AttendanceActionButton extends StatelessWidget {
  final VoidCallback onTap;

  const AttendanceActionButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.fingerprint),
        label: const Text(
          "CHECK IN",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}