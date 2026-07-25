import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/session/session_service.dart';

class UnauthorizedPage extends StatelessWidget {
  final bool notFound;

  const UnauthorizedPage({super.key, this.notFound = false});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    notFound
                        ? Icons.travel_explore_outlined
                        : Icons.lock_outline_rounded,
                    size: 58,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    notFound ? 'Halaman tidak ditemukan' : 'Akses ditolak',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notFound
                        ? 'URL yang Anda buka tidak tersedia.'
                        : 'Akun Anda tidak memiliki izin untuk membuka halaman ini.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: () async {
                      final user = await SessionService.getUser();
                      final admin =
                          user?.role == 'admin' || user?.role == 'superadmin';
                      Get.offAllNamed(
                        admin ? AppRoutes.adminDashboard : AppRoutes.dashboard,
                      );
                    },
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Kembali ke Dashboard'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
