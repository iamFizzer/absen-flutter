import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_color.dart';
import '../controllers/leave_controller.dart';
import '../models/leave_request_model.dart';

class LeaveRequestPage extends GetView<LeaveController> {
  const LeaveRequestPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pengajuan Cuti & Izin')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _showForm(context),
      icon: const Icon(Icons.add),
      label: const Text('Buat Pengajuan'),
    ),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.error.value != null) {
        return Center(
          child: FilledButton.icon(
            onPressed: controller.load,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.load,
        child: controller.requests.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 160),
                  Icon(
                    Icons.event_note_outlined,
                    size: 52,
                    color: AppColor.textMuted,
                  ),
                  SizedBox(height: 12),
                  Center(child: Text('Belum ada pengajuan cuti atau izin.')),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: controller.requests.length,
                itemBuilder: (_, index) => _RequestCard(
                  item: controller.requests[index],
                  onCancel: controller.cancel,
                ),
              ),
      );
    }),
  );

  Future<void> _showForm(BuildContext context) async {
    var type = 'cuti';
    var start = DateTime.now();
    var end = DateTime.now();
    PlatformFile? attachment;
    final reason = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          scrollable: true,
          title: const Text('Buat Pengajuan'),
          content: Form(
            key: formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(
                    labelText: 'Jenis pengajuan',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cuti', child: Text('Cuti')),
                    DropdownMenuItem(value: 'izin', child: Text('Izin')),
                    DropdownMenuItem(value: 'sakit', child: Text('Sakit')),
                  ],
                  onChanged: (value) => setState(() => type = value!),
                ),
                const SizedBox(height: 14),
                _DateField(
                  label: 'Tanggal mulai',
                  value: start,
                  onTap: () async {
                    final value = await showDatePicker(
                      context: context,
                      initialDate: start,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (value != null) {
                      setState(() {
                        start = value;
                        if (end.isBefore(start)) end = start;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                _DateField(
                  label: 'Tanggal selesai',
                  value: end,
                  onTap: () async {
                    final value = await showDatePicker(
                      context: context,
                      initialDate: end.isBefore(start) ? start : end,
                      firstDate: start,
                      lastDate: start.add(const Duration(days: 30)),
                    );
                    if (value != null) setState(() => end = value);
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: reason,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Alasan',
                    hintText: 'Jelaskan alasan pengajuan',
                  ),
                  validator: (value) => (value?.trim().length ?? 0) < 5
                      ? 'Alasan minimal 5 karakter.'
                      : null,
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: const ['pdf'],
                      withData: true,
                    );
                    final document = result?.files.single;
                    if (document == null) return;
                    if (document.size > 5 * 1024 * 1024) {
                      Get.snackbar(
                        'Lampiran terlalu besar',
                        'Ukuran dokumen PDF maksimal 5 MB.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    if (document.bytes == null) {
                      Get.snackbar(
                        'Lampiran gagal dibaca',
                        'Silakan pilih kembali dokumen PDF.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    setState(() => attachment = document);
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(
                    attachment?.name ?? 'Lampirkan dokumen PDF (opsional)',
                  ),
                ),
                if (type == 'sakit')
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Lampirkan surat dokter dalam format PDF bila tersedia.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            Obx(
              () => FilledButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        final ok = await controller.submit(
                          type,
                          start,
                          end,
                          reason.text.trim(),
                          attachment,
                        );
                        if (ok && dialogContext.mounted) {
                          Navigator.pop(dialogContext, true);
                        }
                      },
                child: controller.isSubmitting.value
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Kirim'),
              ),
            ),
          ],
        ),
      ),
    );
    reason.dispose();
    if (submitted == true) await controller.load();
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      child: Text(DateFormat('dd MMMM yyyy').format(value)),
    ),
  );
}

class _RequestCard extends StatelessWidget {
  final LeaveRequestModel item;
  final Future<void> Function(int) onCancel;
  const _RequestCard({required this.item, required this.onCancel});
  @override
  Widget build(BuildContext context) {
    final color = item.status == 'approved'
        ? AppColor.success
        : item.status == 'rejected' || item.status == 'cancelled'
        ? AppColor.danger
        : AppColor.warning;
    final dates = item.startDate == item.endDate
        ? DateFormat('dd MMM yyyy').format(item.startDate)
        : '${DateFormat('dd MMM').format(item.startDate)} - ${DateFormat('dd MMM yyyy').format(item.endDate)}';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.typeLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(item.statusLabel),
                  backgroundColor: color.withValues(alpha: .12),
                  labelStyle: TextStyle(color: color),
                ),
              ],
            ),
            Text(dates, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(item.reason),
            if (item.decisionNote.isNotEmpty) ...[
              const Divider(height: 24),
              Text('Catatan admin: ${item.decisionNote}'),
            ],
            if (item.status == 'pending')
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => onCancel(item.id),
                  child: const Text('Batalkan pengajuan'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
