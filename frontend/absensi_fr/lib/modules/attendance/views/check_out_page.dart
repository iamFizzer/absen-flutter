import 'package:flutter/material.dart';

import '../widgets/attendance_action_page.dart';

class CheckOutPage extends StatelessWidget {
  const CheckOutPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const AttendanceActionPage(action: AttendanceActionType.checkOut);
}
