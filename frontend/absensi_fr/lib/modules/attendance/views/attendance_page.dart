import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_color.dart';
import '../controllers/attendance_controller.dart';
import '../models/attendance_history_model.dart';
import '../widgets/attendance_action_card.dart';
import '../widgets/attendance_status_card.dart';

class AttendancePage extends GetView<AttendanceController> {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Presensi'),
      actions: [
        IconButton(
          tooltip: 'Perbarui data',
          onPressed: controller.refreshAll,
          icon: const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: Obx(() {
      if (controller.isLoading.value && controller.attendance.value == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final attendance = controller.attendance.value;
      if (attendance == null) {
        return _EmptyState(onRetry: controller.refreshAll);
      }

      return RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AttendanceStatusCard(attendance: attendance),
                  if (!attendance.presensiDibuka &&
                      attendance.checkIn == null) ...[
                    const SizedBox(height: 14),
                    Card(
                      color: AppColor.warning.withValues(alpha: .1),
                      child: ListTile(
                        leading: const Icon(
                          Icons.event_busy_outlined,
                          color: AppColor.warning,
                        ),
                        title: const Text('Presensi hari ini ditutup'),
                        subtitle: Text(
                          attendance.informasiHari ?? 'Bukan hari kerja.',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'Pilih aktivitas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Gunakan foto selfie dan lokasi perangkat untuk mencatat kehadiran.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 640;
                      final checkIn = AttendanceActionCard(
                        title: 'Masuk',
                        description: attendance.checkIn == null
                            ? 'Catat waktu kedatangan Anda.'
                            : 'Tercatat pukul ${attendance.checkIn}.',
                        icon: Icons.login_rounded,
                        color: AppColor.success,
                        enabled:
                            attendance.presensiDibuka &&
                            attendance.checkIn == null,
                        completed: attendance.checkIn != null,
                        onTap: () => _openAction(AppRoutes.checkIn),
                      );
                      final checkOut = AttendanceActionCard(
                        title: 'Pulang',
                        description: attendance.checkOut != null
                            ? 'Tercatat pukul ${attendance.checkOut}.'
                            : attendance.checkIn == null
                            ? 'Tersedia setelah Anda Melakukan Presensi Masuk.'
                            : 'Catat waktu kepulangan Anda.',
                        icon: Icons.logout_rounded,
                        color: AppColor.primary,
                        enabled:
                            attendance.checkIn != null &&
                            attendance.checkOut == null,
                        completed: attendance.checkOut != null,
                        onTap: () => _openAction(AppRoutes.checkOut),
                      );
                      if (!wide) {
                        return Column(
                          children: [
                            checkIn,
                            const SizedBox(height: 14),
                            checkOut,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: checkIn),
                          const SizedBox(width: 16),
                          Expanded(child: checkOut),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Icon(
                        Icons.history_outlined,
                        color: AppColor.primary,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Riwayat Bulan Ini',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        '${controller.history.length} catatan',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (controller.history.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(28),
                        child: Center(
                          child: Text('Belum ada riwayat presensi.'),
                        ),
                      ),
                    )
                  else
                    ...controller.history.map(_HistoryTile.new),
                ],
              ),
            ),
          ),
        ),
      );
    }),
  );

  Future<void> _openAction(String route) async {
    await controller.retakePhoto();
    await Get.toNamed(route);
    await controller.refreshAll();
  }
}

class _HistoryTile extends StatelessWidget {
  final AttendanceHistoryModel item;
  const _HistoryTile(this.item);

  @override
  Widget build(BuildContext context) {
    final normalized = item.status.toLowerCase();
    final color = normalized == 'terlambat'
        ? AppColor.warning
        : normalized == 'alpa'
        ? AppColor.danger
        : normalized == 'belum_checkin'
        ? AppColor.secondary
        : AppColor.success;
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .1),
          child: Icon(Icons.event_available_outlined, color: color),
        ),
        title: Text(
          item.tanggal,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Masuk: ${item.checkIn ?? '-'}  •  Pulang: ${item.checkOut ?? '-'}'
          "${item.catatan == null ? '' : '\n${item.catatan}'}",
        ),
        trailing: Text(
          item.status.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 52,
            color: AppColor.textMuted,
          ),
          const SizedBox(height: 14),
          Text(
            'Data presensi tidak tersedia',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Periksa koneksi lalu coba kembali.'),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    ),
  );
}
