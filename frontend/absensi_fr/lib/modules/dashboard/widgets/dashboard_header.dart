import 'package:flutter/material.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/live_clock.dart';

class DashboardHeader extends StatelessWidget {
  final String nama;
  final String jabatan;
  final String? faceImage;
  final VoidCallback onLogout;
  const DashboardHeader({
    super.key,
    required this.nama,
    required this.jabatan,
    this.faceImage,
    required this.onLogout,
  });

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

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
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .35),
                      width: 1.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: faceImage == null || faceImage!.isEmpty
                      ? _AvatarFallback(nama: nama)
                      : Image.network(
                          faceImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _AvatarFallback(nama: nama),
                        ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting, $nama',
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

class _AvatarFallback extends StatelessWidget {
  final String nama;

  const _AvatarFallback({required this.nama});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.white.withValues(alpha: .12),
    child: Center(
      child: Text(
        nama.isEmpty ? '?' : nama[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
