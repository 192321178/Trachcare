import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:trachcare/Api/DataStore/Datastore.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/Screens/Views/patient/patientScreenmain.dart';
import 'package:trachcare/style/design_system.dart';
import '../Api/Apiurl.dart';

class Spigottingsheet extends StatefulWidget {
  const Spigottingsheet({super.key});

  @override
  State<Spigottingsheet> createState() => _SpigottingsheetState();
}

class _SpigottingsheetState extends State<Spigottingsheet> {
  /// 0 = YES, 1 = NO. Matches the value the API expects in `issues`.
  int _groupValue = 2;

  final _timingController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _timingController.dispose();
    super.dispose();
  }

  Future<bool> _updateSpigotting() async {
    final request =
        http.MultipartRequest('POST', Uri.parse(updatestatusspogotingurl));
    request.fields.addAll({
      'patient_id': patient_id,
      'cough_or_breathlessness': _groupValue == 0 ? 'YES' : 'NO',
      'breath_duration': _timingController.text,
    });

    final response = await request.send();
    if (response.statusCode != 200) return false;

    final data = jsonDecode(await response.stream.bytesToString())
        as Map<String, dynamic>;
    return data['Status'] == true;
  }

  Future<void> _save() async {
    if (_groupValue != 0 && _groupValue != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose Yes or No first')),
      );
      return;
    }
    setState(() => _saving = true);

    final messenger = ScaffoldMessenger.of(context);
    try {
      final request = http.MultipartRequest('POST', Uri.parse(updatestatusurl));
      request.fields.addAll({
        'patient_id': patient_id,
        'issues': _groupValue.toString(),
      });

      final response = await request.send();
      final spigottingStatus = await _updateSpigotting();

      _goToDashboard();

      if (response.statusCode == 200) {
        final data = jsonDecode(await response.stream.bytesToString());
        if (data['Status'] == true && spigottingStatus) {
          _toast(messenger, 'Spigotting status saved', AppColors.success);
        } else {
          _toast(messenger, data['message']?.toString() ?? 'Could not save',
              AppColors.danger);
        }
      } else {
        _toast(messenger, 'Server error: ${response.statusCode}',
            AppColors.danger);
      }
    } catch (e) {
      _toast(messenger, 'Something went wrong: $e', AppColors.danger);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _goToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const PatientMainScreen()),
      (route) => false,
    );
  }

  void _toast(ScaffoldMessengerState messenger, String message, Color color) {
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == AppColors.success
                  ? Icons.check_circle_rounded
                  : Icons.error_rounded,
              color: Colors.white,
              size: 19,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final yes = _groupValue == 0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.mintSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.air_rounded,
                        color: AppColors.teal, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Spigotting session', style: AppType.eyebrow),
                        const SizedBox(height: 3),
                        Text('Quick check-in',
                            style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                  TcIconButton(
                    icon: Icons.close_rounded,
                    size: 36,
                    background: AppColors.surfaceMuted,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Is the patient able to breathe through the nose while blocking the tube with hands?',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(height: 1.45, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _Choice(
                      label: 'Yes',
                      sublabel: 'Breathing comfortably',
                      icon: Icons.check_circle_rounded,
                      selected: yes,
                      accent: AppColors.success,
                      accentSoft: AppColors.successSoft,
                      onTap: () => setState(() => _groupValue = 0),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _Choice(
                      label: 'No',
                      sublabel: 'Struggling or coughing',
                      icon: Icons.cancel_rounded,
                      selected: _groupValue == 1,
                      accent: AppColors.danger,
                      accentSoft: AppColors.dangerSoft,
                      onTap: () => setState(() => _groupValue = 1),
                    ),
                  ),
                ],
              ),
              if (yes) ...[
                const SizedBox(height: AppSpacing.xl),
                TcCard(
                  color: AppColors.surfaceMuted,
                  shadows: null,
                  border: Border.all(color: AppColors.outline),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How long could they breathe?',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _timingController,
                              keyboardType: TextInputType.number,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: AppColors.ink),
                              decoration: const InputDecoration(
                                hintText: 'Minutes',
                                suffixText: 'min',
                                prefixIcon:
                                    Icon(Icons.timer_outlined, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          for (final minutes in const ['5', '10', '15'])
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: AppSpacing.xs),
                              child: ActionChip(
                                label: Text(minutes),
                                onPressed: () => setState(
                                    () => _timingController.text = minutes),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              TcButton(
                label: _saving ? 'Saving…' : 'Save session',
                icon: _saving ? null : Icons.check_rounded,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.accentSoft,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final IconData icon;
  final bool selected;
  final Color accent;
  final Color accentSoft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? accentSoft : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: selected ? accent : AppColors.outline, width: 1.6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: accent, size: 20),
                    const SizedBox(width: 7),
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: selected ? accent : AppColors.inkBody,
                      ),
                    ),
                    const Spacer(),
                    if (selected)
                      Icon(Icons.radio_button_checked_rounded,
                          size: 18, color: accent),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  sublabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
