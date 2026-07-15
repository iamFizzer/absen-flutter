import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {

  final String nama;
  final String jabatan;

  const DashboardHeader({
    super.key,
    required this.nama,
    required this.jabatan,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(24),

      decoration: const BoxDecoration(

        color: Color(0xff0F4C81),

        borderRadius: BorderRadius.only(

          bottomLeft: Radius.circular(30),

          bottomRight: Radius.circular(30),

        ),

      ),

      child: SafeArea(

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Row(

              children: [

                const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),

                const Spacer(),

                IconButton(

                  onPressed: () {},

                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),

                ),

              ],

            ),

            const SizedBox(height: 20),

            const Text(

              "Selamat Datang",

              style: TextStyle(

                color: Colors.white70,

                fontSize: 16,

              ),

            ),

            const SizedBox(height: 8),

            Text(

              nama,

              style: const TextStyle(

                color: Colors.white,

                fontSize: 24,

                fontWeight: FontWeight.bold,

              ),

            ),

            Text(

              jabatan,

              style: const TextStyle(

                color: Colors.white70,

              ),

            ),

          ],

        ),

      ),

    );

  }

}