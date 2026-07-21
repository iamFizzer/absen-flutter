import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_color.dart';
import '../controllers/attendance_controller.dart';
import '../models/attendance_history_model.dart';

class AttendancePage extends GetView<AttendanceController> {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Presensi'),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'Perbarui lokasi',
          onPressed: controller.loadLocation,
          icon: const Icon(Icons.my_location_outlined),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final attendance = controller.attendance.value;
      if (attendance == null) {
        return const _EmptyState();
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PageIntro(
                  date: attendance.tanggal,
                  office: attendance.office,
                  status: attendance.status,
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final desktop = constraints.maxWidth >= 720;
                    final summary = _TodaySummary(
                      scheduleIn: attendance.jamMasuk,
                      scheduleOut: attendance.jamPulang,
                      checkIn: attendance.checkIn,
                      checkOut: attendance.checkOut,
                    );
                    final location = Obx(
                      () => _LocationCard(controller: controller),
                    );
                    if (!desktop) {
                      return Column(
                        children: [
                          summary,
                          const SizedBox(height: 14),
                          location,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: summary),
                        const SizedBox(width: 14),
                        Expanded(child: location),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                Obx(() => _AttendanceAction(controller: controller)),
                const SizedBox(height: 24),
                _SectionTitle(
                  icon: Icons.history_outlined,
                  title: 'Riwayat Bulan Ini',
                  subtitle: '${controller.history.length} catatan presensi',
                ),
                const SizedBox(height: 10),
                if (controller.history.isEmpty)
                  const Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(child: Text('Belum ada riwayat presensi.')),
                    ),
                  )
                else
                  ...controller.history.map(_HistoryTile.new),
              ],
            ),
          ),
        ),
      );
    }),
  );
}

class _PageIntro extends StatelessWidget {
  final String date;
  final String office;
  final String status;

  const _PageIntro({
    required this.date,
    required this.office,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final isLate = normalized == 'terlambat';
    final isPending = normalized == 'belum_checkin';
    final statusColor = isLate
        ? AppColor.warning
        : isPending
        ? AppColor.secondary
        : AppColor.success;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColor.primaryDark, AppColor.primary],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.fingerprint_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Presensi Hari Ini',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date  •  $office',
                  style: TextStyle(color: Colors.white.withValues(alpha: .82)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusText(status),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaySummary extends StatelessWidget {
  final String? scheduleIn;
  final String? scheduleOut;
  final String? checkIn;
  final String? checkOut;

  const _TodaySummary({
    this.scheduleIn,
    this.scheduleOut,
    this.checkIn,
    this.checkOut,
  });

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            icon: Icons.schedule_outlined,
            title: 'Waktu Presensi',
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _TimeItem(
                  label: 'Check In',
                  value: checkIn ?? '-',
                  icon: Icons.login_rounded,
                  color: AppColor.success,
                ),
              ),
              Container(width: 1, height: 54, color: AppColor.border),
              Expanded(
                child: _TimeItem(
                  label: 'Check Out',
                  value: checkOut ?? '-',
                  icon: Icons.logout_rounded,
                  color: AppColor.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          Text(
            'Jadwal kantor: ${scheduleIn ?? '-'} - ${scheduleOut ?? '-'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

class _LocationCard extends StatelessWidget {
  final AttendanceController controller;

  const _LocationCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final inside = controller.isInsideOffice.value;
    final loading = controller.isLocationLoading.value;
    final error = controller.locationError.value;
    final color = error == null && inside ? AppColor.success : AppColor.danger;
    final description =
        error ??
        (inside
            ? 'Anda berada dalam radius kantor.'
            : AppConfig.enforceAttendanceRadius
            ? 'Anda berada di luar radius kantor.'
            : 'Di luar radius (mode development).');

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardTitle(
              icon: Icons.location_on_outlined,
              title: 'Validasi Lokasi',
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: .25)),
              ),
              child: Row(
                children: [
                  if (loading)
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: color,
                      ),
                    )
                  else
                    Icon(
                      inside ? Icons.check_circle : Icons.error_outline,
                      color: color,
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      loading ? 'Mengambil lokasi terbaru...' : description,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            Text(
              'Jarak dari kantor',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              error == null
                  ? '${controller.distance.value.toStringAsFixed(1)} meter'
                  : '-',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${controller.latitude.value.toStringAsFixed(6)}, '
              '${controller.longitude.value.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceAction extends StatelessWidget {
  final AttendanceController controller;

  const _AttendanceAction({required this.controller});

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(
            icon: Icons.camera_alt_outlined,
            title: controller.action == null
                ? 'Presensi Selesai'
                : controller.actionLabel,
            subtitle: controller.action == null
                ? 'Check-in dan check-out hari ini sudah lengkap.'
                : 'Ambil selfie terbaru untuk verifikasi identitas.',
          ),
          const SizedBox(height: 16),
          if (controller.photo.value != null) ...[
            _PhotoPreview(photo: controller.photo.value!),
            const SizedBox(height: 14),
          ],
          if (controller.photo.value == null)
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: controller.canSubmit ? controller.openCamera : null,
                icon: Icon(
                  controller.action == 'check_out'
                      ? Icons.logout_rounded
                      : Icons.camera_alt_outlined,
                ),
                label: Text(
                  controller.action == null
                      ? 'PRESENSI HARI INI SELESAI'
                      : 'BUKA KAMERA UNTUK ${controller.actionLabel}',
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.isUploading.value
                        ? null
                        : controller.retakePhoto,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Ambil Ulang'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed:
                        controller.isUploading.value || !controller.canSubmit
                        ? null
                        : controller.submitAttendance,
                    icon: controller.isUploading.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.verified_outlined),
                    label: Text(
                      controller.isUploading.value
                          ? 'Mengirim...'
                          : controller.actionLabel,
                    ),
                  ),
                ),
              ],
            ),
          if (!controller.canSubmit && controller.action != null) ...[
            const SizedBox(height: 10),
            Text(
              controller.isLocationLoading.value
                  ? 'Tunggu hingga lokasi selesai diperbarui.'
                  : 'Tombol aktif setelah lokasi Anda memenuhi ketentuan.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    ),
  );
}

class _PhotoPreview extends StatelessWidget {
  final dynamic photo;

  const _PhotoPreview({required this.photo});

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
    future: photo.readAsBytes(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.memory(
          snapshot.data!,
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    },
  );
}

class _HistoryTile extends StatelessWidget {
  final AttendanceHistoryModel item;

  const _HistoryTile(this.item);

  @override
  Widget build(BuildContext context) {
    final status = item.status.toLowerCase();
    final isLate = status == 'terlambat';
    final isAbsent = status == 'alpa';
    final isPending = status == 'belum_checkin';
    final color = isLate
        ? AppColor.warning
        : isAbsent
        ? AppColor.danger
        : isPending
        ? AppColor.secondary
        : AppColor.success;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isLate
                ? Icons.warning_amber_rounded
                : isAbsent
                ? Icons.event_busy_outlined
                : isPending
                ? Icons.schedule_outlined
                : Icons.event_available_outlined,
            color: color,
          ),
        ),
        title: Text(
          item.tanggal,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Masuk: ${item.checkIn ?? '-'}  •  Pulang: ${item.checkOut ?? '-'}'
          "${item.catatan == null ? '' : '\n${item.catatan}'}",
        ),
        trailing: _StatusBadge(status: item.status),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = normalized == 'terlambat'
        ? AppColor.warning
        : normalized == 'alpa'
        ? AppColor.danger
        : normalized == 'belum_checkin'
        ? AppColor.secondary
        : AppColor.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Text(
        _statusText(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TimeItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _TimeItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: color),
      const SizedBox(height: 6),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      Text(
        value,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CardTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColor.primary, size: 21),
      const SizedBox(width: 8),
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColor.primarySoft,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: AppColor.primary, size: 21),
      ),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.event_busy_outlined,
          size: 48,
          color: AppColor.textMuted,
        ),
        const SizedBox(height: 12),
        Text(
          'Data presensi tidak ditemukan',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    ),
  );
}

String _statusText(String status) => status
    .replaceAll('_', ' ')
    .split(' ')
    .map(
      (word) =>
          word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}',
    )
    .join(' ');
