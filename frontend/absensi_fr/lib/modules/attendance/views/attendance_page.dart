import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/attendance_controller.dart';
import '../widgets/attendance_info_card.dart';
import '../../../core/config/app_config.dart';

class AttendancePage extends GetView<AttendanceController> {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Presensi"), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final attendance = controller.attendance.value;

        if (attendance == null) {
          return const Center(child: Text("Data presensi tidak ditemukan"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ==========================
              /// PRESENSI HARI INI
              /// ==========================
              const Text(
                "Presensi Hari Ini",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              AttendanceInfoCard(
                title: "Tanggal",
                value: attendance.tanggal,
                icon: Icons.calendar_today,
              ),

              AttendanceInfoCard(
                title: "Kantor",
                value: attendance.office,
                icon: Icons.business,
              ),

              AttendanceInfoCard(
                title: "Jam Masuk",
                value: attendance.jamMasuk ?? "-",
                icon: Icons.login,
              ),

              AttendanceInfoCard(
                title: "Jam Pulang",
                value: attendance.jamPulang ?? "-",
                icon: Icons.logout,
              ),

              AttendanceInfoCard(
                title: "Check In",
                value: attendance.checkIn ?? "-",
                icon: Icons.fingerprint,
              ),

              AttendanceInfoCard(
                title: "Check Out",
                value: attendance.checkOut ?? "-",
                icon: Icons.assignment_turned_in,
              ),

              AttendanceInfoCard(
                title: "Status",
                value: attendance.status,
                icon: Icons.info,
              ),

              const SizedBox(height: 30),

              /// ==========================
              /// LOKASI
              /// ==========================
              const Text(
                "Lokasi Saat Ini",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Latitude : ${controller.latitude.value}"),

                      const SizedBox(height: 8),

                      Text("Longitude : ${controller.longitude.value}"),

                      const SizedBox(height: 8),

                      Text(
                        "Jarak : ${controller.distance.value.toStringAsFixed(2)} Meter",
                      ),

                      const SizedBox(height: 15),

                      Row(
                        children: [
                          Icon(
                            controller.isInsideOffice.value
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: controller.isInsideOffice.value
                                ? Colors.green
                                : Colors.red,
                          ),

                          const SizedBox(width: 10),

                          Text(
                            controller.isInsideOffice.value
                                ? "Dalam Radius"
                                : AppConfig.enforceAttendanceRadius
                                ? "Di Luar Radius"
                                : "Di Luar Radius (Mode Development)",
                            style: TextStyle(
                              color: controller.isInsideOffice.value
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// ==========================
              /// BUTTON
              /// ==========================
              Obx(() {
                if (controller.photo.value == null) {
                  return SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: controller.canSubmit
                          ? controller.openCamera
                          : null,
                      icon: Icon(
                        controller.action == 'check_out'
                            ? Icons.logout
                            : Icons.login,
                      ),
                      label: Text(
                        controller.action == null
                            ? "PRESENSI SELESAI"
                            : "${controller.actionLabel} - BUKA KAMERA",
                      ),
                    ),
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.retakePhoto,

                        icon: const Icon(Icons.refresh),

                        label: const Text("Ambil Ulang"),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            controller.isUploading.value ||
                                !controller.canSubmit
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
                            : const Icon(Icons.send),

                        label: Text(
                          controller.isUploading.value
                              ? "Mengirim..."
                              : controller.actionLabel,
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 25),

              /// ==========================
              /// PREVIEW FOTO
              /// ==========================
              Obx(() {
                final photo = controller.photo.value;

                if (photo == null) {
                  return const SizedBox();
                }

                return FutureBuilder<Uint8List>(
                  future: photo.readAsBytes(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Preview Selfie",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.memory(
                            snapshot.data!,
                            width: double.infinity,
                            height: 320,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),

              const SizedBox(height: 32),
              const Text(
                "Riwayat Harian Bulan Ini",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Obx(
                () => controller.history.isEmpty
                    ? const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: Text("Belum ada riwayat.")),
                        ),
                      )
                    : Column(
                        children: controller.history.map((item) {
                          final status = item.status.replaceAll('_', ' ');
                          return Card(
                            child: ListTile(
                              leading: Icon(
                                item.status == 'alpa'
                                    ? Icons.cancel_outlined
                                    : Icons.event_available_outlined,
                                color: item.status == 'alpa'
                                    ? Colors.red
                                    : Colors.green,
                              ),
                              title: Text(item.tanggal),
                              subtitle: Text(
                                "Masuk: ${item.checkIn ?? '-'}  •  Pulang: ${item.checkOut ?? '-'}"
                                "${item.catatan == null ? '' : '\n${item.catatan}'}",
                              ),
                              trailing: Text(
                                status.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        );
      }),
    );
  }
}
