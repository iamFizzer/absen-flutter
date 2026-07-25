import 'package:flutter/material.dart';

import '../widgets/attendance_action_page.dart';

class CheckInPage extends StatelessWidget {
  const CheckInPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const AttendanceActionPage(action: AttendanceActionType.checkIn);
}
