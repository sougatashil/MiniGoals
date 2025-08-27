import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ProgressRing extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;
  final Widget? child;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool showBackground;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 8,
    this.color = AppColors.primaryColor,
    this.backgroundColor = AppColors.borderColor,
    this.child,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.animationCurve = Curves.easeOutCubic,
    this.showBackground = true,
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = oldWidget.progress;
      _progressAnimation = Tween<double>(
        begin: _previousProgress.clamp(0.0, 1.0),
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      ));

      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          // Progress Ring
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: ProgressRingPainter(
                  progress: _progressAnimation.value,
                  strokeWidth: widget.strokeWidth,
                  color: widget.color,
                  backgroundColor: widget.backgroundColor,
                  showBackground: widget.showBackground,
                ),
                size: Size(widget.size, widget.size),
              );
            },
          ),
          
          // Center content
          if (widget.child != null)
            Center(
              child: widget.child,
            ),
        ],
      ),
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;
  final bool showBackground;

  ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
    required this.showBackground,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    if (showBackground) {
      final backgroundPaint = Paint()
        ..color = backgroundColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius, backgroundPaint);
    }

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            color,
            color.withOpacity(0.8),
            color,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2; // Start from top
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );

      // Glow effect
      if (progress > 0.1) {
        final glowPaint = Paint()
          ..color = color.withOpacity(0.3)
          ..strokeWidth = strokeWidth + 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          glowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ProgressRingPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        strokeWidth != oldDelegate.strokeWidth ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor ||
        showBackground != oldDelegate.showBackground;
  }
}

/// Multi-colored progress ring for category-based progress
class MultiProgressRing extends StatefulWidget {
  final List<ProgressSegment> segments;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Widget? child;
  final Duration animationDuration;

  const MultiProgressRing({
    super.key,
    required this.segments,
    this.size = 120,
    this.strokeWidth = 8,
    this.backgroundColor = AppColors.borderColor,
    this.child,
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<MultiProgressRing> createState() => _MultiProgressRingState();
}

class _MultiProgressRingState extends State<MultiProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _segmentAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _createSegmentAnimations();
    _animationController.forward();
  }

  void _createSegmentAnimations() {
    _segmentAnimations = [];
    
    for (int i = 0; i < widget.segments.length; i++) {
      final segment = widget.segments[i];
      final delay = i * 0.1; // Stagger the animations
      
      _segmentAnimations.add(
        Tween<double>(
          begin: 0,
          end: segment.progress.clamp(0.0, 1.0),
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
        )),
      );
    }
  }

  @override
  void didUpdateWidget(MultiProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.segments != oldWidget.segments) {
      _createSegmentAnimations();
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: MultiProgressRingPainter(
                  segments: widget.segments,
                  segmentAnimations: _segmentAnimations,
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: widget.backgroundColor,
                ),
                size: Size(widget.size, widget.size),
              );
            },
          ),
          if (widget.child != null)
            Center(child: widget.child),
        ],
      ),
    );
  }
}

class MultiProgressRingPainter extends CustomPainter {
  final List<ProgressSegment> segments;
  final List<Animation<double>> segmentAnimations;
  final double strokeWidth;
  final Color backgroundColor;

  MultiProgressRingPainter({
    required this.segments,
    required this.segmentAnimations,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw each segment
    double currentAngle = -math.pi / 2; // Start from top
    
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final animatedProgress = segmentAnimations[i].value;
      
      if (animatedProgress > 0) {
        final segmentAngle = 2 * math.pi * animatedProgress;
        
        final segmentPaint = Paint()
          ..color = segment.color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          currentAngle,
          segmentAngle,
          false,
          segmentPaint,
        );
        
        currentAngle += segmentAngle;
      }
    }
  }

  @override
  bool shouldRepaint(covariant MultiProgressRingPainter oldDelegate) {
    return segments != oldDelegate.segments ||
        segmentAnimations != oldDelegate.segmentAnimations ||
        strokeWidth != oldDelegate.strokeWidth ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

/// Data class for progress segments
class ProgressSegment {
  final double progress;
  final Color color;
  final String? label;

  const ProgressSegment({
    required this.progress,
    required this.color,
    this.label,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressSegment &&
          runtimeType == other.runtimeType &&
          progress == other.progress &&
          color == other.color &&
          label == other.label;

  @override
  int get hashCode => progress.hashCode ^ color.hashCode ^ label.hashCode;
}