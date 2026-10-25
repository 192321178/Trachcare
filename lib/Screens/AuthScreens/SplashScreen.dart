import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trachcare/Screens/started/WelcomePage.dart';
import 'package:trachcare/components/motion.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/style/responsive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.6, curve: Curves.easeOut),
  );

  late final Animation<double> _rise = Tween<double>(begin: 26, end: 0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic)));

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Welcome_page()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: AppSize.s(-90),
                right: AppSize.s(-70),
                child: _Glow(size: AppSize.s(300), alpha: 0.16),
              ),
              Positioned(
                bottom: AppSize.s(-120),
                left: AppSize.s(-90),
                child: _Glow(size: AppSize.s(360), alpha: 0.12),
              ),
              SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: _fade,
                    child: AnimatedBuilder(
                      animation: _rise,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, _rise.value),
                        child: child,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: AppSize.s(116),
                            height: AppSize.s(116),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(AppSize.s(28)),
                              boxShadow: AppShadows.glow,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset('assets/images/0.png',
                                fit: BoxFit.cover),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          Text(
                            'TrachCare',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: AppSize.s(34),
                              fontWeight: FontWeight.w800,
                              letterSpacing: AppSize.s(-0.6),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Tracheostomy care, guided at home',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: AppSize.s(13),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          SizedBox(
                            width: AppSize.s(190),
                            child: EcgTrace(
                              height: 30,
                              color: Colors.white.withValues(alpha: 0.9),
                              trackColor:
                                  Colors.white.withValues(alpha: 0.20),
                              strokeWidth: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 4),
                  FadeTransition(
                    opacity: _fade,
                    child: Column(
                      children: [
                        const _PageDots(),
                        SizedBox(height: AppSize.s(12)),
                        Text(
                          'PREPARING YOUR CARE PLAN',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: AppSize.s(10),
                            fontWeight: FontWeight.w700,
                            letterSpacing: AppSize.s(1.4),
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: _fade,
                    child: Text(
                      'Version 2.0.0 · built with Flutter',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: AppSize.s(11.5),
                        letterSpacing: AppSize.s(0.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}

/// The three-step loading indicator drawn under the tagline in the mock.
class _PageDots extends StatefulWidget {
  const _PageDots();

  @override
  State<_PageDots> createState() => _PageDotsState();
}

class _PageDotsState extends State<_PageDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.s(3.5)),
              child: Container(
                width: AppSize.s(7),
                height: AppSize.s(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(
                    alpha: (_c.value * 3).floor() % 3 == i ? 0.95 : 0.35,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: alpha),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
