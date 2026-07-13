import 'package:flutter/material.dart';

class LoginCard extends StatelessWidget {
  final Widget child;

  const LoginCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              blurRadius: 30,
              color: Colors.black12,
              offset: Offset(0, 10),
            )
          ],
        ),
        child: child,
      ),
    );
  }
}