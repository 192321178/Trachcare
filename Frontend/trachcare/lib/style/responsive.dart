import 'package:flutter/widgets.dart';

/// Phone-first sizing scale for the "Clinical Calm" layout.
///
/// The screens were drawn against a 360dp-wide phone. [AppSize.s] maps those
/// design pixels onto the running device, clamped so a tablet does not inflate
/// a card into nonsense and a 320dp phone does not crush it.
class AppSize {
  const AppSize._();

  static const double designWidth = 360;
  static const double minScale = 0.85;
  static const double maxScale = 1.25;

  /// Above this width the phone layout stops making sense as a single column.
  static const double compactWidth = 600;
  static const double mediumWidth = 840;

  /// Content stops growing with the window past this width on tablets/desktop.
  static const double maxContentWidth = 560;

  static double _scale = 1;
  static double _widthDp = designWidth;

  static double get scale => _scale;
  static double get widthDp => _widthDp;
  static double get heightDp => _heightDp;
  static double _heightDp = 780;

  static void init(Size physicalSize, double devicePixelRatio) {
    final ratio = devicePixelRatio <= 0 ? 1.0 : devicePixelRatio;
    _widthDp = physicalSize.width / ratio;
    _heightDp = physicalSize.height / ratio;
    _scale = (_widthDp / designWidth).clamp(minScale, maxScale).toDouble();
  }

  /// Scale a design-pixel value (spacing, radius, icon size, font size).
  static double s(double designPx) => designPx * _scale;

  /// Horizontal page gutter: scales with the device but never eats the column.
  static double pad(double designPx) =>
      s(designPx).clamp(12.0, 32.0).toDouble();

  static bool get isCompact => _widthDp < compactWidth;
  static bool get isMedium =>
      _widthDp >= compactWidth && _widthDp < mediumWidth;
  static bool get isWide => _widthDp >= mediumWidth;

  /// Width the content column may actually use.
  static double get contentWidth =>
      isCompact ? _widthDp : _widthDp.clamp(0.0, maxContentWidth).toDouble();
}

/// Keeps a single-column app centred and readable on tablets and desktop
/// instead of stretching every card edge to edge.
class ContentColumn extends StatelessWidget {
  const ContentColumn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSize.maxContentWidth),
        child: child,
      ),
    );
  }
}
