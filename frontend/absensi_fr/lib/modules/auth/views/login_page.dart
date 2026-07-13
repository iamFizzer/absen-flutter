import 'package:flutter/material.dart';

import '../widgets/login_card.dart';
import '../widgets/login_form.dart';
import '../widgets/login_logo.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF0F4C81),
        child: LoginCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              LoginLogo(),
              SizedBox(height: 30),
              LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}