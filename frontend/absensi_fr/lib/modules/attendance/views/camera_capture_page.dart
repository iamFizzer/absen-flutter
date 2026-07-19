import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/camera_service.dart';
import '../../../core/theme/app_color.dart';

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key});

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  bool _initializing = true;
  bool _capturing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize([CameraDescription? selected]) async {
    if (mounted) {
      setState(() {
        _initializing = true;
        _error = null;
      });
    }

    CameraException? lastError;
    try {
      _cameras = await CameraService.getCameras();
      if (_cameras.isEmpty) {
        throw CameraException('no-camera', 'Kamera tidak ditemukan.');
      }

      final preferred = selected ?? CameraService.preferredCamera(_cameras);
      final candidates = [
        preferred,
        ..._cameras.where((camera) => camera != preferred),
      ];
      final presets = kIsWeb
          ? const [ResolutionPreset.medium, ResolutionPreset.low]
          : const [ResolutionPreset.medium];

      await _controller?.dispose();
      _controller = null;

      for (final camera in candidates) {
        for (final preset in presets) {
          final candidate = CameraController(
            camera,
            preset,
            enableAudio: false,
            imageFormatGroup: ImageFormatGroup.jpeg,
          );
          try {
            await candidate.initialize();
            _controller = candidate;
            if (mounted) setState(() => _initializing = false);
            return;
          } on CameraException catch (error) {
            lastError = error;
            await candidate.dispose();
          }
        }
      }

      throw lastError ??
          CameraException('camera-unavailable', 'Webcam tidak dapat dibuka.');
    } on CameraException catch (error) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error = _cameraError(error);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error =
              'Webcam tidak dapat dibuka. Periksa koneksi dan izin kamera.';
        });
      }
    }
  }

  String _cameraError(CameraException error) {
    final details = '${error.code} ${error.description ?? ''}'.toLowerCase();
    if (error.code.contains('AccessDenied') ||
        details.contains('permission') ||
        details.contains('notallowed')) {
      return 'Izin kamera ditolak. Izinkan kamera pada pengaturan browser atau perangkat, lalu coba lagi.';
    }
    if (kIsWeb && Uri.base.scheme != 'https' && Uri.base.host != 'localhost') {
      return 'Browser hanya mengizinkan webcam melalui HTTPS atau localhost.';
    }
    if (details.contains('notreadable') ||
        details.contains('hardware') ||
        details.contains('could not start video')) {
      return 'Webcam sedang digunakan aplikasi lain atau dinonaktifkan oleh sistem. Tutup Zoom, Meet, atau aplikasi kamera, pastikan penutup kamera terbuka, lalu coba lagi.';
    }
    return error.description ?? 'Webcam tidak dapat dibuka.';
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing) {
      return;
    }
    setState(() => _capturing = true);
    try {
      final image = await controller.takePicture();
      if (mounted) Get.back(result: image);
    } on CameraException catch (error) {
      if (mounted) {
        setState(() {
          _capturing = false;
          _error = _cameraError(error);
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _initializing) return;
    final current = _controller?.description;
    final index = _cameras.indexWhere((camera) => camera == current);
    await _initialize(_cameras[(index + 1) % _cameras.length]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed && _cameras.isNotEmpty) {
      _initialize(_cameras.first);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Ambil Selfie'),
        actions: [
          if (_cameras.length > 1)
            IconButton(
              onPressed: _switchCamera,
              tooltip: 'Ganti kamera',
              icon: const Icon(Icons.cameraswitch_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Center(child: _cameraBody())),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
              child: Column(
                children: [
                  const Text(
                    'Posisikan wajah di tengah, lihat ke kamera, dan pastikan pencahayaan cukup.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 18),
                  Semantics(
                    label: 'Ambil foto selfie',
                    button: true,
                    child: InkWell(
                      onTap: _error == null ? _capture : null,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _error == null ? Colors.white : Colors.white24,
                          border: Border.all(color: AppColor.primary, width: 5),
                        ),
                        child: _capturing
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                color: AppColor.primary,
                                size: 30,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraBody() {
    if (_initializing) {
      return const CircularProgressIndicator(color: Colors.white);
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.videocam_off_outlined,
              color: Colors.white70,
              size: 54,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _initialize,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    final controller = _controller!;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}
