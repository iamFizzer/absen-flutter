import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/session/session_service.dart';
import '../../../core/theme/app_color.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_model.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_stat_card.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.dashboard.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = controller.dashboard.value;
        if (data == null) return _ErrorState(onRetry: controller.loadDashboard);

        return RefreshIndicator(
          onRefresh: controller.refreshDashboard,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: DashboardHeader(
                      nama: data.nama,
                      jabatan: data.jabatan,
                      faceImage: data.faceImage,
                      onLogout: () => _logout(context),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      wide ? 40 : 20,
                      24,
                      wide ? 40 : 20,
                      40,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1050),
                          child: Column(
                            children: [
                              if (wide)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: _TodayCard(data: data),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      flex: 4,
                                      child: _Summary(data: data),
                                    ),
                                  ],
                                )
                              else ...[
                                _TodayCard(data: data),
                                const SizedBox(height: 20),
                                _Summary(data: data),
                              ],
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      Get.toNamed(AppRoutes.leaveRequests),
                                  icon: const Icon(Icons.event_note_outlined),
                                  label: const Text('PENGAJUAN CUTI / IZIN'),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _MonthlyHistory(data: data),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Anda perlu masuk kembali untuk melakukan presensi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await SessionService.logout();
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar(
        'Berhasil keluar',
        'Session Anda sudah dihapus.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class _TodayCard extends StatelessWidget {
  final DashboardModel data;
  const _TodayCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isLeave = const {'cuti', 'izin', 'sakit'}.contains(data.status);
    final complete = data.status == 'selesai' || isLeave;
    final checkedIn = data.checkIn != null;
    final title = isLeave
        ? 'Pengajuan ${data.status} disetujui'
        : complete
        ? 'Presensi selesai'
        : checkedIn
        ? 'Saatnya Pulang'
        : 'Siap untuk presensi?';
    final subtitle = isLeave
        ? 'Anda tidak perlu melakukan presensi hari ini.'
        : complete
        ? 'Terima kasih, aktivitas hari ini sudah tercatat.'
        : 'Pastikan wajah terlihat jelas dan GPS perangkat aktif.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: AppColor.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: AppColor.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timelapse_rounded, color: AppColor.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Durasi kerja hari ini',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          _duration(data.durasiKerjaMenit),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _InfoChip(icon: Icons.business_outlined, label: data.office),
                _InfoChip(
                  icon: Icons.schedule,
                  label:
                      '${data.shift} • ${data.jamMasuk ?? '--:--'}–${data.jamPulang ?? '--:--'}',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _TimeItem(
                    label: 'Masuk',
                    value: data.checkIn ?? '--:--',
                    icon: Icons.login_rounded,
                  ),
                ),
                Container(width: 1, height: 54, color: AppColor.border),
                Expanded(
                  child: _TimeItem(
                    label: 'Pulang',
                    value: data.checkOut ?? '--:--',
                    icon: Icons.logout_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: complete
                    ? null
                    : () async {
                        await Get.toNamed(AppRoutes.attendance);
                        await Get.find<DashboardController>()
                            .refreshDashboard();
                      },
                icon: Icon(
                  checkedIn
                      ? Icons.logout_rounded
                      : Icons.face_retouching_natural,
                ),
                label: Text(
                  isLeave
                      ? '${data.status.toUpperCase()} DISETUJUI'
                      : complete
                      ? 'PRESENSI HARI INI SELESAI'
                      : checkedIn
                      ? 'LANJUT PULANG'
                      : 'MULAI PRESENSI',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _duration(int minutes) {
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (hours == 0) return '$remaining menit';
    return '$hours jam $remaining menit';
  }
}

class _MonthlyHistory extends StatelessWidget {
  final DashboardModel data;
  const _MonthlyHistory({required this.data});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: AppColor.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Rekap Kehadiran Bulan Berjalan',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (data.historyBulanIni.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Belum ada rekap kehadiran bulan ini.'),
              ),
            )
          else
            ...data.historyBulanIni.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColor.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.status == 'alpa'
                          ? Icons.cancel_outlined
                          : item.status == 'belum_checkin'
                          ? Icons.schedule_outlined
                          : Icons.check_circle_outline,
                      color: item.status == 'alpa'
                          ? AppColor.danger
                          : item.status == 'belum_checkin'
                          ? AppColor.secondary
                          : AppColor.success,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.tanggal,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text('${item.checkIn ?? '-'} — ${item.checkOut ?? '-'}'),
                    const SizedBox(width: 14),
                    _StatusBadge(status: item.status),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final danger = status == 'alpa';
    final pending = status == 'belum_checkin';
    final color = danger
        ? AppColor.danger
        : pending
        ? AppColor.secondary
        : AppColor.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final DashboardModel data;
  const _Summary({required this.data});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Ringkasan bulan ini',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: DashboardStatCard(
              title: 'Kehadiran',
              value: '${data.hadirBulanIni}',
              icon: Icons.calendar_month_outlined,
              color: AppColor.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DashboardStatCard(
              title: 'Terlambat',
              value: '${data.terlambatBulanIni}',
              icon: Icons.timer_outlined,
              color: AppColor.warning,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColor.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Presensi divalidasi dengan kecocokan wajah dan lokasi perangkat.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: AppColor.surfaceMuted,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: AppColor.textMuted),
        const SizedBox(width: 7),
        Text(label),
      ],
    ),
  );
}

class _TimeItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _TimeItem({
    required this.label,
    required this.value,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: AppColor.primary, size: 21),
      const SizedBox(height: 6),
      Text(value, style: Theme.of(context).textTheme.titleLarge),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: AppColor.textMuted,
          ),
          const SizedBox(height: 14),
          Text(
            'Dashboard tidak dapat dimuat',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Periksa koneksi ke server lalu coba kembali.',
            textAlign: TextAlign.center,
          ),
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
