import 'dart:math' as math;
import 'package:flutter/material.dart';

class LiveWaveform extends StatefulWidget {
  final double amplitude;
  final bool isRecording;

  const LiveWaveform({
    super.key,
    required this.amplitude,
    required this.isRecording,
  });

  @override
  State<LiveWaveform> createState() => _LiveWaveformState();
}

class _LiveWaveformState extends State<LiveWaveform> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _barHeights = List.generate(30, (index) => 4.0);
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(() {
        if (widget.isRecording) {
          _updateBars();
        }
      });
    _controller.repeat();
  }

  void _updateBars() {
    setState(() {
      // Shift bars to the left
      for (int i = 0; i < _barHeights.length - 1; i++) {
        _barHeights[i] = _barHeights[i + 1];
      }
      
      // Add new bar at the end based on amplitude
      // Normalize amplitude (usually 0 to 1 or 0 to 100)
      double baseHeight = widget.amplitude * 60.0;
      double randomVariation = _random.nextDouble() * 10.0;
      _barHeights[_barHeights.length - 1] = math.max(4.0, baseHeight + randomVariation);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: CustomPaint(
        painter: WaveformPainter(
          barHeights: _barHeights,
          color: widget.isRecording ? Colors.red.shade400 : Colors.grey.shade300,
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> barHeights;
  final Color color;

  WaveformPainter({
    required this.barHeights,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    final double spacing = size.width / (barHeights.length);
    final double centerY = size.height / 2;

    for (int i = 0; i < barHeights.length; i++) {
      final double x = i * spacing + spacing / 2;
      final double height = barHeights[i];
      
      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.barHeights != barHeights || oldDelegate.color != color;
  }
}
