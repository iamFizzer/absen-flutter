import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/session/session_service.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/live_clock.dart';
import '../controllers/admin_controller.dart';

class AdminDashboardPage extends GetView<AdminController> {
  const AdminDashboardPage({super.key});
  static const labels = {
    'employees': 'Pegawai',
    'offices': 'Kantor',
    'shifts': 'Shift',
    'holidays': 'Hari Libur',
    'attendance_recap': 'Rekap Absensi',
  };
  static const icons = {
    'employees': Icons.people_outline,
    'offices': Icons.business_outlined,
    'shifts': Icons.schedule_outlined,
    'holidays': Icons.event_outlined,
    'attendance_recap': Icons.fact_check_outlined,
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, size) {
        final desktop = size.maxWidth >= 800;
        return Row(
          children: [
            if (desktop) _navigation(context, true),
            Expanded(
              child: Column(
                children: [
                  _header(context, desktop),
                  Expanded(
                    child: Obx(
                      () => RefreshIndicator(
                        onRefresh: controller.loadAll,
                        child: _content(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
    drawer: Builder(
      builder: (context) => MediaQuery.sizeOf(context).width < 800
          ? Drawer(child: _navigation(context, false))
          : const SizedBox(),
    ),
  );

  Widget _navigation(BuildContext context, bool desktop) => Container(
    width: desktop ? 230 : double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF174783), Color(0xFF0D2D59)],
      ),
    ),
    child: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Image.asset('assets/logo/logo-big.png'),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Presensi Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24),
          ...labels.entries.map(
            (entry) => Obx(
              () => _HoverNavigationTile(
                selected: controller.selected.value == entry.key,
                icon: icons[entry.key]!,
                label: entry.value,
                onTap: () {
                  controller.selected.value = entry.key;
                  if (!desktop) Navigator.pop(context);
                },
              ),
            ),
          ),
          const Spacer(),
          _HoverNavigationTile(
            icon: Icons.logout,
            label: 'Keluar',
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    ),
  );

  Widget _header(BuildContext context, bool desktop) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: AppColor.primaryDark.withValues(alpha: .06),
          blurRadius: 18,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Row(
      children: [
        if (!desktop)
          Builder(
            builder: (context) => IconButton(
              onPressed: Scaffold.of(context).openDrawer,
              icon: const Icon(Icons.menu),
            ),
          ),
        Expanded(
          child: Obx(
            () => Text(
              labels[controller.selected.value]!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        const LiveClock(compact: true),
        const SizedBox(width: 8),
        IconButton(
          onPressed: controller.loadAll,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
  );

  Widget _content(BuildContext context) {
    if (controller.isLoading.value) {
      return ListView(
        children: const [
          SizedBox(height: 180),
          Center(child: _AdminLoadingState()),
        ],
      );
    }
    if (controller.error.value != null) {
      return ListView(
        children: [
          const SizedBox(height: 200),
          Center(child: Text('Data tidak dapat dimuat')),
        ],
      );
    }
    final type = controller.selected.value;
    final items = controller.data[type] ?? [];
    if (type == 'attendance_recap') {
      return _attendanceRecap(context, items);
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: labels.entries
              .map(
                (e) => _stat(
                  e.value,
                  controller.data[e.key]?.length ?? 0,
                  icons[e.key]!,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                'Daftar ${labels[type]}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            FilledButton.icon(
              onPressed: () => _showForm(context, type),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            ),
          ],
        ),
        if (type == 'employees') ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => controller.exportEmployees('xlsx'),
                icon: const Icon(Icons.table_view_outlined),
                label: const Text('Download Excel'),
              ),
              OutlinedButton.icon(
                onPressed: () => controller.exportEmployees('pdf'),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Download PDF'),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Belum ada data.')),
            ),
          )
        else
          ...items.map((item) => _item(context, type, item)),
      ],
    );
  }

  Widget _attendanceRecap(
    BuildContext context,
    List<Map<String, dynamic>> items,
  ) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Rekap Absensi Bulanan',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      Obx(
        () => Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => _selectRecapDate(context, true),
              icon: const Icon(Icons.date_range_outlined),
              label: Text(
                'Dari ${DateFormat('dd/MM/yyyy').format(controller.recapStart.value)}',
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _selectRecapDate(context, false),
              icon: const Icon(Icons.event_available_outlined),
              label: Text(
                'Sampai ${DateFormat('dd/MM/yyyy').format(controller.recapEnd.value)}',
              ),
            ),
            FilledButton.icon(
              onPressed: controller.loadRecapRange,
              icon: const Icon(Icons.search),
              label: const Text('Tampilkan'),
            ),
            OutlinedButton.icon(
              onPressed: () => controller.exportRecap('xlsx'),
              icon: const Icon(Icons.table_view_outlined),
              label: const Text('Excel'),
            ),
            OutlinedButton.icon(
              onPressed: () => controller.exportRecap('pdf'),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('PDF'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      if (items.isEmpty)
        const Card(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Center(child: Text('Belum ada data rekap.')),
          ),
        )
      else
        ...items.map(
          (item) => Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColor.primarySoft,
                backgroundImage: item['face_image'] != null
                    ? NetworkImage(item['face_image'].toString())
                    : null,
                child: item['face_image'] == null
                    ? const Icon(Icons.person_outline)
                    : null,
              ),
              title: Text(item['nama']?.toString() ?? '-'),
              subtitle: Text(
                'NIP: ${item['nip'] ?? '-'}\n'
                'Hadir: ${item['total_hadir'] ?? 0} • '
                'Terlambat: ${item['terlambat'] ?? 0} • '
                'Alpa: ${item['alpa'] ?? 0}\n'
                'Izin: ${item['izin'] ?? 0} • '
                'Sakit: ${item['sakit'] ?? 0} • '
                'Cuti: ${item['cuti'] ?? 0}',
              ),
              isThreeLine: true,
            ),
          ),
        ),
    ],
  );

  Future<void> _selectRecapDate(BuildContext context, bool isStart) async {
    final current = isStart
        ? controller.recapStart.value
        : controller.recapEnd.value;
    final selected = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (selected == null) return;

    if (isStart) {
      if (selected.isAfter(controller.recapEnd.value)) {
        Get.snackbar(
          'Tanggal tidak valid',
          'Tanggal mulai melewati tanggal akhir.',
        );
        return;
      }
      controller.recapStart.value = selected;
    } else {
      if (selected.isBefore(controller.recapStart.value)) {
        Get.snackbar(
          'Tanggal tidak valid',
          'Tanggal akhir sebelum tanggal mulai.',
        );
        return;
      }
      controller.recapEnd.value = selected;
    }
  }

  Widget _stat(String label, int count, IconData icon) => SizedBox(
    width: 180,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColor.primarySoft,
              child: Icon(icon, color: AppColor.primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(label),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _item(BuildContext context, String type, Map<String, dynamic> item) {
    final title = item['nama']?.toString() ?? item['nip']?.toString() ?? '-';
    final subtitle = type == 'employees'
        ? '${item['nip']} • ${item['jabatan']}'
        : type == 'offices'
        ? item['alamat']?.toString()
        : type == 'shifts'
        ? '${item['jam_masuk']} – ${item['jam_pulang']}'
        : item['tanggal']?.toString();
    final faceImage = item['face_image']?.toString();
    final hasFace = type == 'employees' && item['face_registered'] == true;
    final itemSubtitle = type == 'employees'
        ? '$subtitle\n${hasFace ? 'Foto identifikasi tersedia' : 'Foto identifikasi belum tersedia'}'
        : subtitle;
    final lastUpdate = _formatLastUpdate(item['last_update']);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColor.primarySoft,
            backgroundImage: hasFace && faceImage != null
                ? NetworkImage(faceImage)
                : null,
            child: hasFace ? null : Icon(icons[type], color: AppColor.primary),
          ),
          title: Text(title),
          subtitle: Text(
            '${itemSubtitle ?? ''}\nTerakhir diperbarui: $lastUpdate',
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showForm(context, type, item: item);
              } else if (value == 'view-face') {
                _showFace(context, item);
              } else if (value == 'face') {
                _selectFace(item['id'] as int);
              } else {
                _confirmDelete(context, type, item);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              if (hasFace)
                const PopupMenuItem(
                  value: 'view-face',
                  child: Text('Lihat wajah'),
                ),
              if (type == 'employees')
                PopupMenuItem(
                  value: 'face',
                  child: Text(
                    hasFace
                        ? 'Ganti foto identifikasi'
                        : 'Tambah foto identifikasi',
                  ),
                ),
              const PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLastUpdate(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (parsed == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
  }

  Future<void> _showFace(
    BuildContext context,
    Map<String, dynamic> employee,
  ) async {
    final imageUrl = employee['face_image']?.toString();
    if (imageUrl == null || imageUrl.isEmpty) return;

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(employee['nama']?.toString() ?? 'Foto identifikasi'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    const Center(child: Text('Foto tidak dapat ditampilkan.')),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectFace(int employeeId) async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image != null) {
      await controller.uploadEmployeeFace(employeeId, image);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String type,
    Map<String, dynamic> item,
  ) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus data?'),
        content: Text(
          'Hapus "${item['nama'] ?? item['nip'] ?? 'data ini'}"? '
          'Data yang sudah dihapus tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yes == true) await controller.remove(type, item['id']);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.logout, color: AppColor.danger, size: 36),
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Session admin akan dihapus dan Anda perlu login kembali.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.logout),
            label: const Text('Ya, keluar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await SessionService.logout();
    Get.offAllNamed(AppRoutes.login);
    Get.snackbar(
      'Berhasil keluar',
      'Session Anda sudah dihapus.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _showForm(
    BuildContext context,
    String type, {
    Map<String, dynamic>? item,
  }) async {
    final fields = _fields(type);
    final formKey = GlobalKey<FormState>();
    final values = {
      for (final f in fields)
        f: TextEditingController(text: item?[f]?.toString() ?? ''),
    };
    if (item == null) {
      if (type == 'employees') {
        values['jenis_kelamin']?.text = 'L';
        values['status']?.text = 'aktif';
      }
      if (type == 'offices') values['status']?.text = 'true';
      if (type == 'shifts') values['aktif']?.text = 'true';
    }
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('${item == null ? 'Tambah' : 'Edit'} ${labels[type]}'),
          content: SizedBox(
            width: 520,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: fields
                      .map(
                        (field) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _formField(
                            context,
                            type,
                            field,
                            values,
                            isEdit: item != null,
                            refresh: setModalState,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final data = <String, dynamic>{
                  for (final f in fields) f: _convert(type, f, values[f]!.text),
                };
                if (item != null && values['password']?.text.isEmpty == true) {
                  data.remove('password');
                }
                if (await controller.save(type, data, id: item?['id'])) {
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                }
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    for (final value in values.values) {
      value.dispose();
    }
  }

  List<String> _fields(String type) => switch (type) {
    'offices' => [
      'nama',
      'alamat',
      'latitude',
      'longitude',
      'radius',
      'status',
    ],
    'shifts' => ['nama', 'jam_masuk', 'jam_pulang', 'toleransi_menit', 'aktif'],
    'holidays' => ['nama', 'tanggal', 'keterangan'],
    'employees' => [
      'username',
      'password',
      'nip',
      'nama',
      'jenis_kelamin',
      'tanggal_lahir',
      'alamat',
      'telepon',
      'email',
      'jabatan',
      'office',
      'status',
    ],
    _ => [],
  };
  String _fieldLabel(String value) => value
      .split('_')
      .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
      .join(' ');

  Widget _formField(
    BuildContext context,
    String type,
    String field,
    Map<String, TextEditingController> values, {
    required bool isEdit,
    required StateSetter refresh,
  }) {
    final value = values[field]!;
    if (field == 'jenis_kelamin') {
      return DropdownButtonFormField<String>(
        initialValue: value.text,
        decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
        items: const [
          DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
          DropdownMenuItem(value: 'P', child: Text('Perempuan')),
        ],
        onChanged: (selected) => value.text = selected ?? 'L',
      );
    }
    if (field == 'office') {
      final offices = controller.data['offices'] ?? [];
      final selected = int.tryParse(value.text);
      return DropdownButtonFormField<int>(
        initialValue: offices.any((o) => o['id'] == selected) ? selected : null,
        decoration: const InputDecoration(labelText: 'Kantor'),
        hint: const Text('Pilih kantor'),
        items: offices
            .map(
              (office) => DropdownMenuItem<int>(
                value: office['id'] as int,
                child: Text(office['nama'].toString()),
              ),
            )
            .toList(),
        validator: (selected) =>
            selected == null ? 'Kantor wajib dipilih' : null,
        onChanged: (selected) => value.text = selected?.toString() ?? '',
      );
    }
    if (field == 'status' && type == 'employees') {
      return DropdownButtonFormField<String>(
        initialValue: value.text,
        decoration: const InputDecoration(labelText: 'Status Pegawai'),
        items: const [
          DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
          DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif')),
        ],
        onChanged: (selected) => value.text = selected ?? 'aktif',
      );
    }
    if (field == 'status' || field == 'aktif') {
      return DropdownButtonFormField<String>(
        initialValue: value.text.toLowerCase(),
        decoration: InputDecoration(labelText: _fieldLabel(field)),
        items: const [
          DropdownMenuItem(value: 'true', child: Text('Aktif')),
          DropdownMenuItem(value: 'false', child: Text('Nonaktif')),
        ],
        onChanged: (selected) => value.text = selected ?? 'true',
      );
    }
    final isDate = field == 'tanggal' || field == 'tanggal_lahir';
    final isTime = field == 'jam_masuk' || field == 'jam_pulang';
    final isNumber = [
      'radius',
      'toleransi_menit',
      'latitude',
      'longitude',
      'telepon',
    ].contains(field);
    final isLong = field == 'alamat' || field == 'keterangan';
    final isPassword = field == 'password';
    return TextFormField(
      controller: value,
      obscureText: isPassword,
      readOnly: isDate || isTime,
      maxLines: isLong ? 3 : 1,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : field == 'email'
          ? TextInputType.emailAddress
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: isPassword && isEdit
            ? 'Password baru (opsional)'
            : _fieldLabel(field),
        hintText: _hint(field),
        suffixIcon: isDate
            ? const Icon(Icons.calendar_today_outlined)
            : isTime
            ? const Icon(Icons.schedule_outlined)
            : null,
      ),
      validator: (text) {
        if (isPassword && isEdit && (text == null || text.isEmpty)) return null;
        if (text == null || text.trim().isEmpty) {
          if (field == 'keterangan') return null;
          return '${_fieldLabel(field)} wajib diisi';
        }
        if (isPassword && text.length < 6) return 'Password minimal 6 karakter';
        if (field == 'email' && !GetUtils.isEmail(text)) {
          return 'Format email tidak valid';
        }
        if (isNumber && double.tryParse(text) == null) {
          return 'Masukkan angka yang valid';
        }
        return null;
      },
      onTap: isDate
          ? () => _pickDate(context, value)
          : isTime
          ? () => _pickTime(context, value)
          : null,
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController value,
  ) async {
    final initial = DateTime.tryParse(value.text) ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      value.text =
          '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _pickTime(
    BuildContext context,
    TextEditingController value,
  ) async {
    final parts = value.text.split(':');
    final initial = parts.length >= 2
        ? TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 8,
            minute: int.tryParse(parts[1]) ?? 0,
          )
        : TimeOfDay.now();
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (selected != null) {
      value.text =
          '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
    }
  }

  String? _hint(String field) => switch (field) {
    'latitude' => 'Contoh: -6.2000000',
    'longitude' => 'Contoh: 106.8166667',
    'radius' => 'Radius dalam meter',
    'tanggal' || 'tanggal_lahir' => 'YYYY-MM-DD',
    'jam_masuk' || 'jam_pulang' => 'HH:mm',
    _ => null,
  };

  dynamic _convert(String type, String field, String value) {
    if (['radius', 'toleransi_menit'].contains(field)) {
      return int.tryParse(value) ?? 0;
    }
    if (field == 'office') return int.tryParse(value);
    if (['latitude', 'longitude'].contains(field)) return value;
    if (field == 'aktif' || (field == 'status' && type == 'offices')) {
      return !['false', '0', 'tidak', 'nonaktif'].contains(value.toLowerCase());
    }
    return value;
  }
}

class _HoverNavigationTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _HoverNavigationTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  State<_HoverNavigationTile> createState() => _HoverNavigationTileState();
}

class _HoverNavigationTileState extends State<_HoverNavigationTile> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hovered = true),
    onExit: (_) => setState(() => hovered = false),
    cursor: SystemMouseCursors.click,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: widget.selected
            ? Colors.white.withValues(alpha: .18)
            : hovered
            ? Colors.white.withValues(alpha: .10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(widget.icon, color: Colors.white),
        title: Text(widget.label, style: const TextStyle(color: Colors.white)),
        onTap: widget.onTap,
      ),
    ),
  );
}

class _AdminLoadingState extends StatefulWidget {
  const _AdminLoadingState();

  @override
  State<_AdminLoadingState> createState() => _AdminLoadingStateState();
}

class _AdminLoadingStateState extends State<_AdminLoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(
      begin: .45,
      end: 1,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 82,
          height: 82,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withValues(alpha: .15),
                blurRadius: 24,
              ),
            ],
          ),
          child: Image.asset('assets/logo/logo-big.png'),
        ),
        const SizedBox(height: 20),
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        const SizedBox(height: 14),
        Text(
          'Menyiapkan data admin...',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    ),
  );
}
