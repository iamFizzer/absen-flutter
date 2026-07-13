import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashPage extends StatelessWidget {

  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xff0F4C81),

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.fingerprint,
              size: 90,
              color: Colors.white,
            ),

            const SizedBox(height: 25),

            const Text(

              "Sistem Presensi Pegawai",

              style: TextStyle(

                color: Colors.white,

                fontSize: 24,

                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 12),

            const CircularProgressIndicator(

              color: Colors.white,

            ),

          ],

        ),

      ),

    );

  }

}