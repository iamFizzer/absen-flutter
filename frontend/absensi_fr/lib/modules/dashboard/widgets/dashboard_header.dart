import 'package:flutter/material.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/live_clock.dart';

class DashboardHeader extends StatelessWidget {
  final String nama;
  final String jabatan;
  final VoidCallback onLogout;
  const DashboardHeader({
    super.key,
    required this.nama,
    required this.jabatan,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColor.primaryDark, AppColor.primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
    ),
    child: SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 16, 26),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    nama.isEmpty ? '?' : nama[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $nama',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        jabatan,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const LiveClock(color: Colors.white, compact: true),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: onLogout,
                  tooltip: 'Keluar',
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
