import 'package:flutter/material.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: const [

          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0,5),
          ),

        ],

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          CircleAvatar(

            radius: 22,

            backgroundColor: color.withOpacity(.15),

            child: Icon(
              icon,
              color: color,
            ),

          ),

          const SizedBox(height: 18),

          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),

        ],

      ),

    );

  }

}