import 'dart:async';
import 'package:flutter/material.dart';

class LiveClock extends StatefulWidget {
  final Color? color;
  final bool compact;
  const LiveClock({super.key, this.color, this.compact = false});

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  static const days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  DateTime now = DateTime.now();
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => now = DateTime.now());
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${_two(now.hour)}:${_two(now.minute)}:${_two(now.second)}',
          style: TextStyle(
            color: color,
            fontSize: widget.compact ? 17 : 24,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (!widget.compact)
          Text(
            '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}',
            style: TextStyle(color: color.withValues(alpha: .75), fontSize: 12),
          ),
      ],
    );
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
