import 'package:flutter/material.dart';

import '../../../core/theme/app_color.dart';

class AttendanceStatusCard extends StatelessWidget {
  final String status;

  const AttendanceStatusCard({super.key, required this.status});

  Color get statusColor {
    switch (status.toLowerCase()) {
      case "hadir":
        return Colors.green;

      case "terlambat":
        return Colors.orange;

      case "belum_checkin":
        return AppColor.secondary;

      default:
        return Colors.red;
    }
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case "belum_checkin":
        return "BELUM CHECK IN";

      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Icon(
              status.toLowerCase() == 'belum_checkin'
                  ? Icons.schedule_outlined
                  : Icons.fingerprint,
              color: statusColor,
              size: 45,
            ),
            const SizedBox(height: 10),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
