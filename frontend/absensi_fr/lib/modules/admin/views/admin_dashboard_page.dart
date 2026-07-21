import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/session/session_service.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/live_clock.dart';
import '../controllers/admin_controller.dart';
import '../models/business_intelligence_model.dart';
import 'dart:ui' as ui;

class AdminDashboardPage extends GetView<AdminController> {
  const AdminDashboardPage({super.key});
  static const labels = {
    'employees': 'Pegawai',
    'offices': 'Kantor',
    'shifts': 'Shift',
    'holidays': 'Hari Libur',
    'attendance_recap': 'Rekap Absensi',
    'business_intelligence': 'BI Dashboard',
  };
  static const icons = {
    'employees': Icons.people_outline,
    'offices': Icons.business_outlined,
    'shifts': Icons.schedule_outlined,
    'holidays': Icons.event_outlined,
    'attendance_recap': Icons.fact_check_outlined,
    'business_intelligence': Icons.insights_outlined,
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
    if (type == 'business_intelligence') {
      return _businessIntelligence(context);
    }
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

  Widget _businessIntelligence(BuildContext context) {
    final data = controller.businessIntelligence.value;
    if (controller.isBusinessIntelligenceLoading.value || data == null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          SizedBox(height: 160),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }
    final summary = data.summary;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _biToolbar(context, data.period),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _biMetric(
              'Tingkat Hadir',
              '${summary.attendanceRate.toStringAsFixed(1)}%',
              '${summary.presentCount}/${summary.expectedPresence} target',
              Icons.trending_up,
              AppColor.success,
            ),
            _biMetric(
              'Terlambat',
              '${summary.lateRate.toStringAsFixed(1)}%',
              '${summary.lateCount} kejadian',
              Icons.warning_amber_rounded,
              AppColor.warning,
            ),
            _biMetric(
              'Selesai Pulang',
              '${summary.completionRate.toStringAsFixed(1)}%',
              '${summary.checkedOutToday} checkout hari ini',
              Icons.logout_rounded,
              AppColor.primary,
            ),
            _biMetric(
              'Belum Check-in',
              summary.notCheckedInToday.toString(),
              '${summary.activeEmployees} pegawai aktif',
              Icons.person_off_outlined,
              AppColor.danger,
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 900;
            final trend = _biTrendCard(context, data.dailyTrend);
            final status = _biStatusCard(context, data.statusBreakdown);
            if (!desktop) {
              return Column(children: [trend, const SizedBox(height: 14), status]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: trend),
                const SizedBox(width: 14),
                Expanded(child: status),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 900;
            final offices = _biOfficeCard(context, data.officePerformance);
            final attention = _biAttentionCard(context, data.attentionList);
            if (!desktop) {
              return Column(children: [offices, const SizedBox(height: 14), attention]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: offices),
                const SizedBox(width: 14),
                Expanded(child: attention),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _biToolbar(BuildContext context, BusinessIntelligencePeriod period) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _sectionHeading(
            context,
            'Business Intelligence',
            '${period.startDate} - ${period.endDate} (${period.workdays} hari kerja)',
          ),
          OutlinedButton.icon(
            onPressed: () => _pickBiRange(context),
            icon: const Icon(Icons.date_range_outlined),
            label: const Text('Periode'),
          ),
          IconButton(
            tooltip: 'Muat ulang BI',
            onPressed: controller.loadBusinessIntelligence,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    ),
  );

  Widget _sectionHeading(BuildContext context, String title, String subtitle) => SizedBox(
    width: 360,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 3),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );

  Widget _biMetric(
    String label,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) => SizedBox(
    width: 230,
    child: Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const Spacer(),
                Text(label, style: const TextStyle(color: AppColor.textMuted)),
              ],
            ),
            const SizedBox(height: 14),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColor.textMuted)),
          ],
        ),
      ),
    ),
  );

  Widget _biTrendCard(BuildContext context, List<BusinessIntelligenceDailyItem> items) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tren Kehadiran Harian', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          SizedBox(height: 230, child: _BiTrendChart(items: items)),
        ],
      ),
    ),
  );

  Widget _biStatusCard(BuildContext context, List<BusinessIntelligenceStatusItem> items) {
    final total = items.fold<int>(0, (sum, item) => sum + item.total);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Komposisi Status', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...items.map((item) => _biStatusRow(item, total)),
          ],
        ),
      ),
    );
  }

  Widget _biStatusRow(BusinessIntelligenceStatusItem item, int total) {
    final percent = total == 0 ? 0.0 : item.total / total;
    final color = _statusColor(item.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(_titleText(item.status))),
              Text('${item.total}'),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            color: color,
            backgroundColor: color.withValues(alpha: .12),
          ),
        ],
      ),
    );
  }

  Widget _biOfficeCard(BuildContext context, List<BusinessIntelligenceOfficeItem> items) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performa Kantor', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text('Belum ada data kantor.')
          else
            ...items.map(
              (item) => _biOfficeRow(
                item.office,
                item.attendanceRate,
                '${item.hadir} hadir, ${item.terlambat} terlambat, score ${item.averageFaceScore.toStringAsFixed(1)}',
              ),
            ),
        ],
      ),
    ),
  );

  Widget _biOfficeRow(String name, double rate, String subtitle) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700))),
            Text('${rate.toStringAsFixed(1)}%'),
          ],
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppColor.textMuted, fontSize: 12)),
        const SizedBox(height: 7),
        LinearProgressIndicator(
          value: (rate / 100).clamp(0, 1),
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    ),
  );

  Widget _biAttentionCard(BuildContext context, List<BusinessIntelligenceAttentionItem> items) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Perlu Perhatian', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text('Tidak ada anomali keterlambatan atau alpa pada periode ini.')
          else
            ...items.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.priority_high_rounded, color: AppColor.warning),
                title: Text(item.nama, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${item.office} - ${item.jabatan}'),
                trailing: Text('${item.terlambat} TL / ${item.alpa} A'),
              ),
            ),
        ],
      ),
    ),
  );

  Future<void> _pickBiRange(BuildContext context) async {
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: controller.biStart.value,
        end: controller.biEnd.value,
      ),
    );
    if (selected != null) {
      await controller.setBusinessIntelligenceRange(selected.start, selected.end);
    }
  }

  Widget _attendanceRecap(
    BuildContext context,
    List<Map<String, dynamic>> items,
  ) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColor.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: AppColor.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekap Absensi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Pantau ringkasan kehadiran pegawai berdasarkan periode.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blueGrey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      _recapToolbar(context),
      const SizedBox(height: 20),
      Row(
        children: [
          Text(
            'Hasil Rekap',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColor.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${items.length} pegawai',
              style: const TextStyle(
                color: AppColor.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
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
                'Alpa: ${item['alpa'] ?? 0}\n'
                'Izin: ${item['izin'] ?? 0} • '
                'Sakit: ${item['sakit'] ?? 0} • '
                'Cuti: ${item['cuti'] ?? 0}',
              ),
              isThreeLine: true,
              trailing: _RecapLateBadge(value: item['terlambat'] ?? 0),
            ),
          ),
        ),
    ],
  );

  Widget _recapToolbar(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.filter_alt_outlined,
                    color: AppColor.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filter Periode',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Pilih rentang tanggal untuk menampilkan dan mengunduh rekap.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blueGrey.shade600,
                ),
              ),
              const SizedBox(height: 18),
              Obx(
                () => Flex(
                  direction: compact ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: compact
                      ? CrossAxisAlignment.stretch
                      : CrossAxisAlignment.end,
                  children: [
                    if (compact)
                      _recapDateField(
                        label: 'Tanggal mulai',
                        value: controller.recapStart.value,
                        onTap: () => _selectRecapDate(context, true),
                      )
                    else
                      Expanded(
                        child: _recapDateField(
                          label: 'Tanggal mulai',
                          value: controller.recapStart.value,
                          onTap: () => _selectRecapDate(context, true),
                        ),
                      ),
                    SizedBox(width: compact ? 0 : 12, height: compact ? 12 : 0),
                    if (compact)
                      _recapDateField(
                        label: 'Tanggal akhir',
                        value: controller.recapEnd.value,
                        onTap: () => _selectRecapDate(context, false),
                      )
                    else
                      Expanded(
                        child: _recapDateField(
                          label: 'Tanggal akhir',
                          value: controller.recapEnd.value,
                          onTap: () => _selectRecapDate(context, false),
                        ),
                      ),
                    SizedBox(width: compact ? 0 : 12, height: compact ? 16 : 0),
                    SizedBox(
                      height: 50,
                      width: compact ? double.infinity : null,
                      child: FilledButton.icon(
                        onPressed: controller.loadRecapRange,
                        icon: const Icon(Icons.search),
                        label: const Text('Tampilkan Rekap'),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Divider(height: 1),
              ),
              Flex(
                direction: compact ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: compact
                    ? CrossAxisAlignment.stretch
                    : CrossAxisAlignment.center,
                children: [
                  if (compact)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unduh Rekap',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'File mengikuti periode yang dipilih di atas.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.blueGrey.shade600),
                        ),
                      ],
                    )
                  else
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Unduh Rekap',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'File mengikuti periode yang dipilih di atas.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.blueGrey.shade600),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(width: compact ? 0 : 16, height: compact ? 12 : 0),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => controller.exportRecap('xlsx'),
                        icon: const Icon(Icons.table_view_outlined),
                        label: const Text('Download Excel'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => controller.exportRecap('pdf'),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Download PDF'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  );

  Widget _recapDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_month_outlined),
        suffixIcon: const Icon(Icons.expand_more),
      ),
      child: Text(
        DateFormat('dd MMM yyyy').format(value),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (type == 'employees')
                IconButton(
                  tooltip: hasFace
                      ? 'Ganti foto identifikasi'
                      : 'Upload foto identifikasi',
                  onPressed: () => _selectFace(item['id'] as int),
                  icon: Icon(
                    hasFace
                        ? Icons.add_a_photo_outlined
                        : Icons.camera_alt_outlined,
                    color: AppColor.primary,
                  ),
                ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showForm(context, type, item: item);
                  } else if (value == 'password') {
                    _showPasswordForm(context, item);
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
                  if (type == 'employees')
                    const PopupMenuItem(
                      value: 'password',
                      child: Text('Ubah password'),
                    ),
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
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (image == null) return;

      final size = await image.length();
      if (size > 10 * 1024 * 1024) {
        Get.snackbar(
          'Foto terlalu besar',
          'Gunakan foto berukuran maksimal 10 MB.',
        );
        return;
      }
      await controller.uploadEmployeeFace(employeeId, image);
    } catch (_) {
      Get.snackbar(
        'Foto tidak dapat dipilih',
        'Browser memblokir pemilih file. Coba gunakan tombol kamera pada baris pegawai.',
      );
    }
  }

  Future<void> _showPasswordForm(
    BuildContext context,
    Map<String, dynamic> employee,
  ) async {
    final formKey = GlobalKey<FormState>();
    final password = TextEditingController();
    final confirmation = TextEditingController();
    var hidePassword = true;
    var hideConfirmation = true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Ubah password pegawai'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee['nama']?.toString() ?? '-',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('Username: ${employee['username'] ?? '-'}'),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: password,
                    obscureText: hidePassword,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Password baru',
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setModalState(() => hidePassword = !hidePassword),
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) => (value?.length ?? 0) < 6
                        ? 'Password minimal 6 karakter'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: confirmation,
                    obscureText: hideConfirmation,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi password baru',
                      suffixIcon: IconButton(
                        onPressed: () => setModalState(
                          () => hideConfirmation = !hideConfirmation,
                        ),
                        icon: Icon(
                          hideConfirmation
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) => value != password.text
                        ? 'Konfirmasi password tidak sama'
                        : null,
                  ),
                ],
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
                final saved = await controller.changeEmployeePassword(
                  employee['id'] as int,
                  password.text,
                  confirmation.text,
                );
                if (saved && dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              icon: const Icon(Icons.lock_reset_outlined),
              label: const Text('Ubah password'),
            ),
          ],
        ),
      ),
    );
    password.dispose();
    confirmation.dispose();
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
    final fields = _fields(type, isEdit: item != null);
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

  List<String> _fields(String type, {bool isEdit = false}) => switch (type) {
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
      if (!isEdit) 'username',
      if (!isEdit) 'password',
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

class _RecapLateBadge extends StatelessWidget {
  final dynamic value;

  const _RecapLateBadge({required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: AppColor.warning.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColor.warning.withValues(alpha: .3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          size: 16,
          color: AppColor.warning,
        ),
        const SizedBox(width: 5),
        Text(
          'Terlambat $value',
          style: const TextStyle(
            color: AppColor.warning,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _BiTrendChart extends StatelessWidget {
  final List<BusinessIntelligenceDailyItem> items;

  const _BiTrendChart({required this.items});

  @override
  Widget build(BuildContext context) {
    final maxValue = items.fold<int>(0, (max, item) {
      final value = item.hadir + item.terlambat + item.izin + item.alpa;
      return value > max ? value : max;
    });
    if (items.isEmpty) {
      return const Center(child: Text('Tidak ada data tren.'));
    }
    return CustomPaint(
      painter: _BiTrendPainter(items: items, maxValue: maxValue <= 0 ? 1 : maxValue),
      child: const SizedBox.expand(),
    );
  }
}

class _BiTrendPainter extends CustomPainter {
  final List<BusinessIntelligenceDailyItem> items;
  final int maxValue;

  _BiTrendPainter({required this.items, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / (items.length * 1.35);
    final gap = barWidth * .35;
    final bottom = size.height - 28;
    final chartHeight = size.height - 40;
    final outline = Paint()
      ..color = AppColor.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final colors = [
      AppColor.success,
      AppColor.warning,
      AppColor.secondary,
      AppColor.danger,
    ];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final values = [item.hadir, item.terlambat, item.izin, item.alpa];
      final x = i * (barWidth + gap) + 12;
      double stackTop = bottom;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 0, barWidth, bottom),
          const Radius.circular(6),
        ),
        outline,
      );
      for (var j = 0; j < values.length; j++) {
        final value = values[j];
        if (value <= 0) continue;
        final height = (value / maxValue) * chartHeight;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, stackTop - height, barWidth, height),
          const Radius.circular(6),
        );
        canvas.drawRRect(
          rect,
          Paint()..color = colors[j].withValues(alpha: .88),
        );
        stackTop -= height;
      }
      final textPainter = TextPainter(
        text: TextSpan(
          text: item.label,
          style: const TextStyle(fontSize: 11, color: AppColor.textMuted),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: barWidth + 18);
      textPainter.paint(canvas, Offset(x - 4, bottom + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _BiTrendPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.maxValue != maxValue;
  }
}

String _titleText(String value) => value
    .replaceAll('_', ' ')
    .split(' ')
    .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
    .join(' ');

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'hadir':
      return AppColor.success;
    case 'terlambat':
      return AppColor.warning;
    case 'izin':
    case 'sakit':
    case 'cuti':
      return AppColor.secondary;
    case 'alpa':
      return AppColor.danger;
    default:
      return AppColor.primary;
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
