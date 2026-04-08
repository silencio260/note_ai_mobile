import 'dart:math' as math;
import 'package:flutter/material.dart';

class AudioWaveformPlayer extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final String seed; // Use this to generate the same waveform for the same recording
  final Function(Duration) onSeek;

  const AudioWaveformPlayer({
    super.key,
    required this.position,
    required this.duration,
    required this.seed,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a stable set of bar heights based on the seed
    final random = math.Random(seed.hashCode);
    final List<double> barHeights = List.generate(
      60,
      (index) => 5.0 + random.nextDouble() * 35.0,
    );

    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return GestureDetector(
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPos = box.globalToLocal(details.globalPosition);
        final relativePos = (localPos.dx / box.size.width).clamp(0.0, 1.0);
        final newSeek = Duration(
          milliseconds: (relativePos * duration.inMilliseconds).toInt(),
        );
        onSeek(newSeek);
      },
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: CustomPaint(
          painter: StaticWaveformPainter(
            barHeights: barHeights,
            progress: progress,
            activeColor: Colors.black,
            inactiveColor: Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}

class StaticWaveformPainter extends CustomPainter {
  final List<double> barHeights;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  StaticWaveformPainter({
    required this.barHeights,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final activePaint = Paint()
      ..color = activeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    final inactivePaint = Paint()
      ..color = inactiveColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    final double spacing = size.width / (barHeights.length);
    final double centerY = size.height / 2;

    for (int i = 0; i < barHeights.length; i++) {
      final double x = i * spacing + spacing / 2;
      final double height = barHeights[i];
      final double barProgress = i / barHeights.length;
      
      final paint = barProgress <= progress ? activePaint : inactivePaint;

      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StaticWaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.barHeights != barHeights ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}
