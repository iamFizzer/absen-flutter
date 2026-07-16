import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  };
  static const icons = {
    'employees': Icons.people_outline,
    'offices': Icons.business_outlined,
    'shifts': Icons.schedule_outlined,
    'holidays': Icons.event_outlined,
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
    color: AppColor.primaryDark,
    child: SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(22),
            child: Row(
              children: [
                Icon(Icons.face_retouching_natural, color: Colors.white),
                SizedBox(width: 10),
                Text(
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
              () => ListTile(
                selected: controller.selected.value == entry.key,
                selectedTileColor: Colors.white12,
                leading: Icon(icons[entry.key], color: Colors.white),
                title: Text(
                  entry.value,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  controller.selected.value = entry.key;
                  if (!desktop) Navigator.pop(context);
                },
              ),
            ),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('Keluar', style: TextStyle(color: Colors.white)),
            onTap: () async {
              await SessionService.logout();
              Get.offAllNamed(AppRoutes.login);
            },
          ),
        ],
      ),
    ),
  );

  Widget _header(BuildContext context, bool desktop) => Container(
    color: Colors.white,
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
          SizedBox(height: 280),
          Center(child: CircularProgressIndicator()),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColor.primarySoft,
            child: Icon(icons[type], color: AppColor.primary),
          ),
          title: Text(title),
          subtitle: Text(subtitle ?? ''),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showForm(context, type, item: item);
              } else {
                _confirmDelete(context, type, item);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
          ),
        ),
      ),
    );
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
        content: const Text('Data yang dihapus tidak dapat dikembalikan.'),
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

  Future<void> _showForm(
    BuildContext context,
    String type, {
    Map<String, dynamic>? item,
  }) async {
    final fields = _fields(type);
    final values = {
      for (final f in fields)
        f: TextEditingController(text: item?[f]?.toString() ?? ''),
    };
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${item == null ? 'Tambah' : 'Edit'} ${labels[type]}'),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: fields
                  .map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: values[f],
                        decoration: InputDecoration(labelText: _fieldLabel(f)),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              final data = <String, dynamic>{
                for (final f in fields) f: _convert(f, values[f]!.text),
              };
              if (item != null && values['password']?.text.isEmpty == true) {
                data.remove('password');
              }
              if (await controller.save(type, data, id: item?['id'])) {
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
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
  dynamic _convert(String field, String value) {
    if (['radius', 'toleransi_menit'].contains(field)) {
      return int.tryParse(value) ?? 0;
    }
    if (field == 'office') return int.tryParse(value);
    if (['latitude', 'longitude'].contains(field)) return value;
    if (['status', 'aktif'].contains(field)) {
      return !['false', '0', 'tidak', 'nonaktif'].contains(value.toLowerCase());
    }
    return value;
  }
}
