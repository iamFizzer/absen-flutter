import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';

import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_menu_item.dart';
import '../widgets/dashboard_stat_card.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {

        /// Loading
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        /// Data tidak ada
        if (controller.dashboard.value == null) {
          return const Center(
            child: Text("Dashboard tidak dapat dimuat"),
          );
        }

        final dashboard = controller.dashboard.value!;

        return SingleChildScrollView(
          child: Column(
            children: [

              /// Header
              DashboardHeader(
                nama: dashboard.nama,
                jabatan: dashboard.jabatan,
              ),

              const SizedBox(height: 25),

              /// Statistik
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.4,
                  children: [

                    DashboardStatCard(
                      title: "Pegawai",
                      value: dashboard.totalPegawai.toString(),
                      icon: Icons.people_alt,
                      color: Colors.blue,
                    ),

                    DashboardStatCard(
                      title: "Kantor",
                      value: dashboard.totalKantor.toString(),
                      icon: Icons.business,
                      color: Colors.orange,
                    ),

                    DashboardStatCard(
                      title: "Presensi",
                      value: dashboard.totalPresensi.toString(),
                      icon: Icons.calendar_month,
                      color: Colors.green,
                    ),

                    DashboardStatCard(
                      title: "Terlambat",
                      value: dashboard.totalTerlambat.toString(),
                      icon: Icons.warning_amber,
                      color: Colors.red,
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// Judul Menu
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Menu",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// Menu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: .9,
                  children: [

                    DashboardMenuItem(
                      title: "Pegawai",
                      icon: Icons.people,
                      color: Colors.blue,
                      onTap: () {},
                    ),

                    DashboardMenuItem(
                      title: "Kantor",
                      icon: Icons.business,
                      color: Colors.orange,
                      onTap: () {},
                    ),

                    DashboardMenuItem(
                      title: "Presensi",
                      icon: Icons.fingerprint,
                      color: Colors.green,
                      onTap: () {
                        Get.toNamed(AppRoutes.attendance);
                      },
                    ),

                    DashboardMenuItem(
                      title: "Riwayat",
                      icon: Icons.history,
                      color: Colors.purple,
                      onTap: () {},
                    ),

                    DashboardMenuItem(
                      title: "Profile",
                      icon: Icons.person,
                      color: Colors.teal,
                      onTap: () {},
                    ),

                    DashboardMenuItem(
                      title: "Setting",
                      icon: Icons.settings,
                      color: Colors.red,
                      onTap: () {},
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 30),

            ],
          ),
        );
      }),
    );
  }
}