import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/style/responsive.dart';

/// TrachCare motion kit — native Flutter animations only.
///
/// Every widget honours [MediaQuery.disableAnimations] (the OS-level
/// "remove animations" accessibility switch) by rendering its static
/// equivalent, so nothing here needs a setting toggle of its own.
class Motion {
  const Motion._();

  /// True when the user asked the OS to reduce motion.
  static bool reduce(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 320);
  static const Curve entrance = Curves.easeOutCubic;
}

// ─────────────────────────────────────────────────────────────────────────────
// ECG trace — a realistic PQRST waveform with a bright pulse travelling it.
// Used wherever a screen talks about live vitals (dashboards, monitoring).
// ─────────────────────────────────────────────────────────────────────────────

class EcgTrace extends StatefulWidget {
  const EcgTrace({
    super.key,
    this.height = 40,
    this.color = AppColors.teal,
    this.trackColor,
    this.strokeWidth = 2.0,
    this.period = const Duration(seconds: 2),
  });

  final double height;
  final Color color;

  /// Dimmed baseline trace behind the travelling pulse.
  final Color? trackColor;
  final double strokeWidth;
  final Duration period;

  @override
  State<EcgTrace> createState() => _EcgTraceState();
}

class _EcgTraceState extends State<EcgTrace>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void initState() {
    super.initState();
    if (!Motion.reduce(context)) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = Motion.reduce(context);
    return SizedBox(
      height: AppSize.s(widget.height),
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _EcgPainter(
            progress: still ? -1 : _c.value,
            color: widget.color,
            trackColor:
                widget.trackColor ?? widget.color.withValues(alpha: 0.18),
            strokeWidth: widget.strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  _EcgPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  /// 0..1 position of the travelling pulse; negative draws a static trace.
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  // Gaussian bump helper for the PQRST deflections.
  static double _g(double x, double center, double width) {
    final d = (x - center) / width;
    return math.exp(-d * d);
  }

  /// Normalised ECG amplitude for x ∈ [0,1]. One cardiac cycle:
  /// P bump → Q dip → R spike → S dip → T bump → baseline.
  static double _wave(double x) {
    return 0.10 * _g(x, 0.14, 0.030) -
        0.10 * _g(x, 0.215, 0.010) +
        1.00 * _g(x, 0.240, 0.0095) -
        0.28 * _g(x, 0.270, 0.012) +
        0.24 * _g(x, 0.420, 0.038);
  }

  Path _build(Size size, double x0, double x1) {
    final path = Path();
    final midY = size.height * 0.62;
    final amp = size.height * 0.52;
    const steps = 160;
    for (var i = 0; i <= steps; i++) {
      final x = x0 + (x1 - x0) * (i / steps);
      final y = midY - _wave(x) * amp;
      final px = x * size.width;
      if (i == 0) {
        path.moveTo(px, y);
      } else {
        path.lineTo(px, y);
      }
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final full = _build(size, 0, 1);
    canvas.drawPath(full, track);

    if (progress < 0) {
      // Reduced-motion / static: draw the whole trace in the main colour.
      canvas.drawPath(full, Paint()..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth);
      return;
    }

    // Travelling bright segment: an eighth of the trace ahead of the head.
    final head = progress * 1.15; // sweep runs slightly past the edge
    const len = 0.14;
    if (head <= 0) return;

    final segStart = (head - len).clamp(0.0, 1.0);
    final segEnd = head.clamp(0.0, 1.0);
    if (segEnd <= 0) return;

    final segment = _build(size, segStart, segEnd);
    canvas.drawPath(
      segment,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Glow dot riding the front of the pulse.
    if (segEnd < 1.0) {
      final midY = size.height * 0.62;
      final amp = size.height * 0.52;
      final dotY = midY - _wave(segEnd) * amp;
      canvas.drawCircle(
        Offset(segEnd * size.width, dotY),
        strokeWidth * 1.6,
        Paint()..color = color,
      );
      canvas.drawCircle(
        Offset(segEnd * size.width, dotY),
        strokeWidth * 3.2,
        Paint()..color = color.withValues(alpha: 0.25),
      );
    }
  }

  @override
  bool shouldRepaint(_EcgPainter old) =>
      old.progress != progress || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Heartbeat — a heart icon that beats lub-dub, plus a soft sonar ring for
// status dots (online, recording, alert).
// ─────────────────────────────────────────────────────────────────────────────

class HeartbeatIcon extends StatefulWidget {
  const HeartbeatIcon({
    super.key,
    this.icon = Icons.favorite_rounded,
    this.size = 22,
    this.color = AppColors.coral,
    this.beat = const Duration(milliseconds: 1100),
  });

  final IconData icon;
  final double size;
  final Color color;
  final Duration beat;

  @override
  State<HeartbeatIcon> createState() => _HeartbeatIconState();
}

class _HeartbeatIconState extends State<HeartbeatIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.beat,
  );

  @override
  void initState() {
    super.initState();
    if (!Motion.reduce(context)) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        // Two quick squeezes then rest — reads as a beat, not a bounce.
        final t = _c.value;
        final scale = 1.0 +
            0.14 * _bump(t, 0.00, 0.12) +
            0.09 * _bump(t, 0.16, 0.12);
        return Transform.scale(scale: scale, child: child);
      },
      child: Icon(widget.icon, size: AppSize.s(widget.size), color: widget.color),
    );
  }

  static double _bump(double t, double start, double width) {
    if (t < start || t > start + width) return 0;
    final p = (t - start) / width;
    return math.sin(p * math.pi);
  }
}

/// Small dot with an expanding soft ring — "live" indicator.
class PulseDot extends StatefulWidget {
  const PulseDot({
    super.key,
    this.color = AppColors.success,
    this.size = 10,
    this.period = const Duration(milliseconds: 1600),
  });

  final Color color;
  final double size;
  final Duration period;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void initState() {
    super.initState();
    if (!Motion.reduce(context)) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = AppSize.s(widget.size);
    return SizedBox(
      width: d * 2.6,
      height: d * 2.6,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: d * (1 + _c.value * 1.6),
              height: d * (1 + _c.value * 1.6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.30 * (1 - _c.value)),
              ),
            ),
            Container(
              width: d,
              height: d,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer — gradient sweep over skeleton blocks, replacing the static
// placeholder look while content loads.
// ─────────────────────────────────────────────────────────────────────────────

class TcShimmer extends StatefulWidget {
  const TcShimmer({super.key, required this.child});

  final Widget child;

  @override
  State<TcShimmer> createState() => _TcShimmerState();
}

class _TcShimmerState extends State<TcShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (!Motion.reduce(context)) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Motion.reduce(context)) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0x00000000),
            Color(0x55FFFFFF),
            Color(0x00000000),
          ],
          stops: [
            (_c.value * 1.6 - 0.6).clamp(0.0, 1.0),
            (_c.value * 1.6 - 0.3).clamp(0.0, 1.0),
            (_c.value * 1.6).clamp(0.0, 1.0),
          ],
        ).createShader(bounds),
        child: child,
      ),
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TcReveal — one-shot fade + rise entrance. Give siblings increasing [index]
// for a staggered cascade; capped so deep lists don't queue forever.
// ─────────────────────────────────────────────────────────────────────────────

class TcReveal extends StatelessWidget {
  const TcReveal({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 14,
    this.duration = Motion.normal,
  });

  final Widget child;
  final int index;
  final double offset;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (Motion.reduce(context)) return child;
    final delay = Duration(milliseconds: 35 * index.clamp(0, 10));
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration + delay,
      curve: Interval(
        delay.inMilliseconds / (duration + delay).inMilliseconds,
        1,
        curve: Motion.entrance,
      ),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, offset * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TcAsyncButton — gradient CTA that runs an async action exactly once at a
// time. Shows a spinner while in flight and a brief success check when the
// action completes — the success state only ever appears after the real work
// finished, never as decoration.
// ─────────────────────────────────────────────────────────────────────────────

class TcAsyncButton extends StatefulWidget {
  const TcAsyncButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busyLabel,
    this.icon,
    this.gradient = AppColors.brandGradient,
    this.height = 54,
    this.expand = true,
    this.showSuccess = true,
  });

  final String label;
  final String? busyLabel;

  /// Null disables the button; the future's completion drives busy/success.
  final Future<void> Function()? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final double height;
  final bool expand;

  /// Flash the check state after a successful run.
  final bool showSuccess;

  @override
  State<TcAsyncButton> createState() => _TcAsyncButtonState();
}

class _TcAsyncButtonState extends State<TcAsyncButton> {
  bool _busy = false;
  bool _done = false;

  Future<void> _run() async {
    final action = widget.onPressed;
    if (action == null || _busy) return;
    setState(() {
      _busy = true;
      _done = false;
    });
    try {
      await action();
      if (!mounted) return;
      if (widget.showSuccess) {
        setState(() => _done = true);
        // Keep the confirmation visible long enough to register.
        await Future.delayed(const Duration(milliseconds: 900));
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _done = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !_busy;
    return SizedBox(
      width: widget.expand ? double.infinity : null,
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled || _busy ? widget.gradient : null,
          color: enabled || _busy ? null : AppColors.surfaceAlt,
          borderRadius: AppRadius.button,
          boxShadow: enabled ? AppShadows.raised : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? _run : null,
            borderRadius: AppRadius.button,
            child: Center(
              child: AnimatedSwitcher(
                duration: Motion.fast,
                child: _busy
                    ? _done
                        ? Icon(Icons.check_circle_rounded,
                            key: const ValueKey('done'),
                            color: Colors.white,
                            size: AppSize.s(22))
                        : Row(
                            key: const ValueKey('busy'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: AppSize.s(18),
                                height: AppSize.s(18),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                widget.busyLabel ?? '${widget.label}…',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: AppSize.s(15),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                    : Row(
                        key: const ValueKey('idle'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon,
                                size: AppSize.s(20),
                                color: enabled
                                    ? Colors.white
                                    : AppColors.inkMuted),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          Flexible(
                            child: Text(
                              widget.label,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: AppSize.s(15),
                                fontWeight: FontWeight.w700,
                                color: enabled
                                    ? Colors.white
                                    : AppColors.inkMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SuccessCheck — circle + checkmark drawn on, for post-save confirmations and
// dialogs. Callers present it only after the real operation succeeded.
// ─────────────────────────────────────────────────────────────────────────────

class SuccessCheck extends StatefulWidget {
  const SuccessCheck({
    super.key,
    this.size = 64,
    this.color = AppColors.success,
    this.onDone,
  });

  final double size;
  final Color color;
  final VoidCallback? onDone;

  @override
  State<SuccessCheck> createState() => _SuccessCheckState();
}

class _SuccessCheckState extends State<SuccessCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  @override
  void initState() {
    super.initState();
    if (Motion.reduce(context)) {
      _c.value = 1;
    } else {
      _c.forward().then((_) => widget.onDone?.call());
    }
    if (Motion.reduce(context)) widget.onDone?.call();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSize.s(widget.size),
      height: AppSize.s(widget.size),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _CheckPainter(
            progress: _c.value,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;

    // Soft filled disc.
    canvas.drawCircle(
      center,
      r * (0.85 + 0.15 * progress),
      Paint()..color = color.withValues(alpha: 0.14 * progress),
    );

    // Ring sweeps on during the first 60%.
    final ringT = (progress / 0.6).clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r * 0.86),
      -math.pi / 2,
      ringT * 2 * math.pi,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.10
        ..strokeCap = StrokeCap.round,
    );

    // Tick draws during the last 40%.
    final tickT = ((progress - 0.6) / 0.4).clamp(0.0, 1.0);
    if (tickT > 0) {
      final p1 = Offset(center.dx - r * 0.36, center.dy + r * 0.02);
      final p2 = Offset(center.dx - r * 0.10, center.dy + r * 0.28);
      final p3 = Offset(center.dx + r * 0.38, center.dy - r * 0.24);
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.11
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      if (tickT < 0.5) {
        final t = tickT / 0.5;
        canvas.drawLine(p1, Offset.lerp(p1, p2, t)!, paint);
      } else {
        canvas.drawLine(p1, p2, paint);
        final t = (tickT - 0.5) / 0.5;
        canvas.drawLine(p2, Offset.lerp(p2, p3, t)!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// LoadingDots — three-dot typing/thinking indicator (refreshing lists,
// "checking history", chat-style states).
// ─────────────────────────────────────────────────────────────────────────────

class LoadingDots extends StatefulWidget {
  const LoadingDots({
    super.key,
    this.color = AppColors.teal,
    this.size = 7,
    this.period = const Duration(milliseconds: 1200),
  });

  final Color color;
  final double size;
  final Duration period;

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void initState() {
    super.initState();
    if (!Motion.reduce(context)) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.s(2.5)),
              child: Opacity(
                opacity: 0.25 +
                    0.75 *
                        (0.5 +
                            0.5 *
                                math.sin(
                                    2 * math.pi * _c.value - i * 0.9)),
                child: Container(
                  width: AppSize.s(widget.size),
                  height: AppSize.s(widget.size),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TcPageRoute — the shared forward navigation: quick fade + slight rise.
// ─────────────────────────────────────────────────────────────────────────────

class TcPageRoute<T> extends PageRouteBuilder<T> {
  TcPageRoute({required Widget page})
      : super(
          transitionDuration: Motion.normal,
          reverseTransitionDuration: Motion.fast,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Motion.entrance,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

// ─────────────────────────────────────────────────────────────────────────────
// Floaty — slow, gentle vertical bob. Gives empty-state icons a hint of life
// without bouncing (clinical, not playful).
// ─────────────────────────────────────────────────────────────────────────────

class Floaty extends StatefulWidget {
  const Floaty({
    super.key,
    required this.child,
    this.amplitude = 5,
    this.period = const Duration(milliseconds: 2600),
  });

  final Widget child;
  final double amplitude;
  final Duration period;

  @override
  State<Floaty> createState() => _FloatyState();
}

class _FloatyState extends State<Floaty> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void initState() {
    super.initState();
    if (!Motion.reduce(context)) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => Transform.translate(
        offset: Offset(
            0, -widget.amplitude * (0.5 + 0.5 * math.sin(2 * math.pi * _c.value))),
        child: child,
      ),
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CountUp — numbers ease to their value when a dashboard stat loads.
// ─────────────────────────────────────────────────────────────────────────────

class CountUp extends StatelessWidget {
  const CountUp({
    super.key,
    required this.value,
    this.style,
    this.suffix = '',
    this.duration = const Duration(milliseconds: 700),
  });

  final int value;
  final TextStyle? style;
  final String suffix;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (Motion.reduce(context)) {
      return Text('$value$suffix', style: style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(
        '${v.round()}$suffix',
        style: style,
      ),
    );
  }
}
