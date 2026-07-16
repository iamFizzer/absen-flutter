import 'package:flutter/material.dart';

import '../widgets/login_card.dart';
import '../widgets/login_form.dart';
import '../widgets/login_logo.dart';
import '../../../core/theme/app_color.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.primaryDark, AppColor.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.sizeOf(context).height -
                    40 -
                    MediaQuery.paddingOf(context).vertical,
              ),
              child: const LoginCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [LoginLogo(), SizedBox(height: 30), LoginForm()],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
