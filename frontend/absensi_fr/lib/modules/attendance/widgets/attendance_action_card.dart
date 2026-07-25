import 'package:flutter/material.dart';

class AttendanceActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool enabled;
  final bool completed;
  final VoidCallback onTap;

  const AttendanceActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withValues(alpha: enabled ? .12 : .06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                completed ? Icons.check_rounded : icon,
                color: enabled || completed ? color : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 5),
                  Text(description),
                ],
              ),
            ),
            Icon(
              completed
                  ? Icons.verified_rounded
                  : enabled
                  ? Icons.arrow_forward_rounded
                  : Icons.lock_outline_rounded,
              color: completed ? color : Colors.grey,
            ),
          ],
        ),
      ),
    ),
  );
}
