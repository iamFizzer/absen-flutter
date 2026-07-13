import 'package:flutter/material.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Image.asset(
          "assets/logo/logo-big.png",
          width: 90,
        ),

        const SizedBox(height: 20),

        Text(
          "Selamat Datang",
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 8),

        const Text(
          "Silakan masuk untuk melanjutkan",
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}