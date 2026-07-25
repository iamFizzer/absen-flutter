import 'package:flutter/material.dart';

import '../../../core/theme/app_color.dart';
import '../models/attendance_today_model.dart';

class AttendanceStatusCard extends StatelessWidget {
  final AttendanceTodayModel attendance;
  const AttendanceStatusCard({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColor.primaryDark, AppColor.primary],
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.fingerprint_rounded,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Presensi Hari Ini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${attendance.tanggal} • ${attendance.office}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .82),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _Time(
                label: 'Check In',
                value: attendance.checkIn ?? '--:--',
              ),
            ),
            Container(
              width: 1,
              height: 42,
              color: Colors.white.withValues(alpha: .25),
            ),
            Expanded(
              child: _Time(
                label: 'Check Out',
                value: attendance.checkOut ?? '--:--',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Time extends StatelessWidget {
  final String label;
  final String value;
  const _Time({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: .75))),
    ],
  );
}
