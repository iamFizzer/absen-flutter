import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class AdminBinding extends Bindings {
  final String initialSection;

  AdminBinding({this.initialSection = 'dashboard'});

  @override
  void dependencies() =>
      Get.lazyPut(() => AdminController(initialSection: initialSection));
}
