import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/session/session_service.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/live_clock.dart';
import '../controllers/attendance_controller.dart';

enum AttendanceActionType { checkIn, checkOut }

class AttendanceActionPage extends GetView<AttendanceController> {
  final AttendanceActionType action;
  const AttendanceActionPage({super.key, required this.action});

  bool get _isCheckIn => action == AttendanceActionType.checkIn;
  String get _label => _isCheckIn ? 'Masuk' : 'Pulang';
  String get _actionValue => _isCheckIn ? 'check_in' : 'check_out';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_label)),
    body: Obx(() {
      final attendance = controller.attendance.value;
      if (controller.isLoading.value && attendance == null) {
        return const Center(child: CircularProgressIndicator());
      }
      if (attendance == null) {
        return const Center(child: Text('Data presensi tidak tersedia.'));
      }

      final validAction = controller.action == _actionValue;
      final accent = _isCheckIn ? AppColor.success : AppColor.primary;
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 42),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  label: _label,
                  accent: accent,
                  office: attendance.office,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 680;
                    final details = Column(
                      children: [
                        _InformationCard(
                          checkIn: _isCheckIn ? null : attendance.checkIn,
                        ),
                        const SizedBox(height: 14),
                        _LocationCard(controller: controller),
                      ],
                    );
                    final selfie = _SelfieCard(controller: controller);
                    if (!wide) {
                      return Column(
                        children: [details, const SizedBox(height: 14), selfie],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: details),
                        const SizedBox(width: 14),
                        Expanded(child: selfie),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                _SubmitArea(
                  controller: controller,
                  label: _label,
                  action: _actionValue,
                  validAction: validAction,
                  accent: accent,
                ),
              ],
            ),
          ),
        ),
      );
    }),
  );
}

class _Header extends StatelessWidget {
  final String label;
  final Color accent;
  final String office;
  const _Header({
    required this.label,
    required this.accent,
    required this.office,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: accent,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 34),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                office,
                style: TextStyle(color: Colors.white.withValues(alpha: .8)),
              ),
            ],
          ),
        ),
        const LiveClock(color: Colors.white),
      ],
    ),
  );
}

class _InformationCard extends StatelessWidget {
  final String? checkIn;
  const _InformationCard({this.checkIn});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Title(icon: Icons.badge_outlined, text: 'Informasi Pegawai'),
          const SizedBox(height: 14),
          FutureBuilder(
            future: SessionService.getUser(),
            builder: (context, snapshot) => Text(
              snapshot.data?.nama.isNotEmpty == true
                  ? snapshot.data!.nama
                  : 'Pegawai',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (checkIn != null) ...[
            const Divider(height: 26),
            Text(
              'Check-in sebelumnya',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              checkIn!,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColor.success),
            ),
          ],
        ],
      ),
    ),
  );
}

class _LocationCard extends StatelessWidget {
  final AttendanceController controller;
  const _LocationCard({required this.controller});

  @override
  Widget build(BuildContext context) => Obx(() {
    final loading = controller.isLocationLoading.value;
    final error = controller.locationError.value;
    final valid = error == null && controller.isInsideOffice.value;
    final allowed = valid || !AppConfig.enforceAttendanceRadius;
    final color = allowed ? AppColor.success : AppColor.danger;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: _Title(
                    icon: Icons.location_on_outlined,
                    text: 'Validasi Lokasi',
                  ),
                ),
                IconButton(
                  onPressed: loading ? null : controller.loadLocation,
                  tooltip: 'Perbarui lokasi',
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (loading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    allowed ? Icons.check_circle : Icons.error_outline,
                    color: color,
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    loading
                        ? 'Mengambil lokasi terbaru...'
                        : error ??
                              (valid
                                  ? 'Anda berada dalam radius kantor.'
                                  : 'Anda berada di luar radius kantor.'),
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              error == null
                  ? 'Jarak ${controller.distance.value.toStringAsFixed(1)} meter'
                  : 'Koordinat belum tersedia',
            ),
          ],
        ),
      ),
    );
  });
}

class _SelfieCard extends StatelessWidget {
  final AttendanceController controller;
  const _SelfieCard({required this.controller});

  @override
  Widget build(BuildContext context) => Obx(() {
    final photo = controller.photo.value;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Title(icon: Icons.camera_alt_outlined, text: 'Foto Selfie'),
            const SizedBox(height: 14),
            if (photo == null)
              Container(
                constraints: const BoxConstraints(minHeight: 210),
                decoration: BoxDecoration(
                  color: AppColor.surfaceMuted,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.face_retouching_natural,
                  size: 70,
                  color: AppColor.textMuted,
                ),
              )
            else
              FutureBuilder<Uint8List>(
                future: photo.readAsBytes(),
                builder: (context, snapshot) => ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: snapshot.hasData
                      ? Image.memory(
                          snapshot.data!,
                          height: 260,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox(
                          height: 210,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                ),
              ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: controller.isUploading.value
                  ? null
                  : controller.openCamera,
              icon: Icon(photo == null ? Icons.camera_alt : Icons.refresh),
              label: Text(photo == null ? 'Ambil Selfie' : 'Ambil Ulang'),
            ),
          ],
        ),
      ),
    );
  });
}

class _SubmitArea extends StatelessWidget {
  final AttendanceController controller;
  final String label;
  final String action;
  final bool validAction;
  final Color accent;
  const _SubmitArea({
    required this.controller,
    required this.label,
    required this.action,
    required this.validAction,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Obx(() {
    final enabled =
        validAction &&
        controller.photo.value != null &&
        controller.canSubmit &&
        !controller.isUploading.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: accent),
          onPressed: enabled ? () => _confirm(context) : null,
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
            controller.isUploading.value ? 'Mengirim...' : 'Lakukan $label',
          ),
        ),
        if (!enabled && !controller.isUploading.value) ...[
          const SizedBox(height: 9),
          Text(
            !validAction
                ? 'Aktivitas ini tidak tersedia untuk status presensi Anda.'
                : controller.photo.value == null
                ? 'Ambil foto selfie terlebih dahulu.'
                : 'Tunggu validasi lokasi selesai atau perbarui lokasi.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  });

  Future<void> _confirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi $label'),
        content: Text(
          'Pastikan foto dan lokasi sudah benar sebelum melakukan $label.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final success = await controller.submitAttendance(expectedAction: action);
    if (success && context.mounted) {
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }
}

class _Title extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Title({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColor.primary, size: 21),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}
