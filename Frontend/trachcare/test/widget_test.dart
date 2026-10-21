import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/colors.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/style/responsive.dart';

Widget wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: SafeArea(child: child)),
    );

void main() {
  // Fonts ship as assets, so the suite must never depend on the network.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('design tokens', () {
    test('legacy aliases point at the new palette', () {
      expect(main_color, AppColors.teal);
      expect(admin_color, AppColors.teal);
      expect(BlackColor, AppColors.ink);
      expect(grey_color, AppColors.inkMuted);
      expect(sucess_color, AppColors.success);
      expect(maincolor, AppColors.brandGradient);
    });

    test('theme is Material 3 seeded from the brand teal', () {
      expect(AppTheme.light.useMaterial3, isTrue);
      expect(AppTheme.light.colorScheme.primary, AppColors.teal);
      expect(AppTheme.light.scaffoldBackgroundColor, AppColors.surfaceMuted);
    });

    test('radius scale keeps cards, sheets and fields distinct', () {
      expect(AppRadius.card.topLeft.x, 20);
      expect(AppRadius.sheet.topLeft.x, greaterThan(20));
      expect(AppRadius.field.topLeft.x, 14);
    });
  });

  group('responsive scale', () {
    void use(double widthDp, [double dpr = 3]) =>
        AppSize.init(Size(widthDp * dpr, 800 * dpr), dpr);

    test('a 360dp phone is the 1:1 design baseline', () {
      use(360);
      expect(AppSize.scale, closeTo(1, 0.001));
      expect(AppSize.s(20), closeTo(20, 0.001));
    });

    test('narrow phones shrink but never below the floor', () {
      use(280);
      expect(AppSize.scale, AppSize.minScale);
      use(320);
      expect(AppSize.scale, greaterThan(AppSize.minScale));
      expect(AppSize.scale, lessThan(1));
    });

    test('tablets stop growing at the ceiling', () {
      use(900);
      expect(AppSize.scale, AppSize.maxScale);
      expect(AppSize.isWide, isTrue);
    });

    test('page gutter scales but stays inside its band', () {
      use(320);
      expect(AppSize.pad(20), inInclusiveRange(12, 32));
      use(1200);
      expect(AppSize.pad(20), inInclusiveRange(12, 32));
    });

    test('content column caps width past the phone breakpoint', () {
      use(360);
      expect(AppSize.contentWidth, closeTo(360, 0.5));
      use(1200);
      expect(AppSize.contentWidth, AppSize.maxContentWidth);
    });

    test('a zero device pixel ratio does not divide by zero', () {
      AppSize.init(const Size(1080, 2400), 0);
      expect(AppSize.scale.isFinite, isTrue);
    });
  });

  group('asset paths', () {
    test('strips the backend ../ prefix', () {
      expect(trachcareAsset('../uploads/patient/a.png'),
          '$apiBase/uploads/patient/a.png');
      expect(trachcareAsset('../../uploads/patient/a.png'),
          '$apiBase/uploads/patient/a.png');
    });

    // Each endpoint used to hardcode its own scheme, which is how the app ended
    // up calling https:// against an http-only server.
    test('every endpoint is derived from apiBase', () {
      for (final url in [
        PatientLoginurl,
        DoctorLoginUrl,
        AdminLoginurl,
        PatientslistUrl,
        statusurl,
      ]) {
        expect(url, startsWith(apiBase));
      }
    });

    test('passes absolute URLs through untouched', () {
      expect(trachcareAsset('https://cdn.example.com/v.mp4'),
          'https://cdn.example.com/v.mp4');
    });

    test('returns empty for missing values', () {
      expect(trachcareAsset(null), isEmpty);
      expect(trachcareAsset(''), isEmpty);
    });
  });

  group('widget kit', () {
    testWidgets('TcCard renders its child', (tester) async {
      await tester.pumpWidget(wrap(const TcCard(child: Text('card body'))));
      expect(find.text('card body'), findsOneWidget);
    });

    testWidgets('TcStatTile shows label and value', (tester) async {
      await tester.pumpWidget(wrap(const TcStatTile(
        icon: Icons.water_drop_outlined,
        label: 'Volume',
        value: '4.5',
      )));
      expect(find.text('VOLUME'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
    });

    testWidgets('TcButton is inert without a handler', (tester) async {
      await tester
          .pumpWidget(wrap(const TcButton(label: 'Save', onPressed: null)));
      expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);
    });

    testWidgets('TcButton reports taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(wrap(TcButton(label: 'Save', onPressed: () => taps++)));
      await tester.tap(find.text('Save'));
      expect(taps, 1);
    });

    testWidgets('TcNavBar emits the selected index', (tester) async {
      int? selected;
      await tester.pumpWidget(wrap(TcNavBar(
        currentIndex: 0,
        onSelected: (i) => selected = i,
        items: const [
          TcNavItem(
              icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
          TcNavItem(
              icon: Icons.play_circle_outline,
              activeIcon: Icons.play_circle,
              label: 'Videos'),
          TcNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile'),
        ],
      )));
      // Only the selected tab expands to show its label, so tap by position.
      await tester.tap(find.byType(InkWell).last);
      expect(selected, 2);
    });

    testWidgets('TcEmptyState renders its message', (tester) async {
      await tester.pumpWidget(wrap(const TcEmptyState(
        title: 'No records yet',
        message: 'Reports you submit will appear here.',
      )));
      expect(find.text('No records yet'), findsOneWidget);
      expect(find.text('Reports you submit will appear here.'), findsOneWidget);
    });

    testWidgets('TcField keeps typed input', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(wrap(TcField(label: 'Patient name', controller: controller)));
      await tester.enterText(find.byType(TextField), 'Ananya Rao');
      expect(controller.text, 'Ananya Rao');
    });
  });
}
