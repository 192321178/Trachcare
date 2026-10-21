import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/Api/DataStore/Datastore.dart';
import 'package:trachcare/components/NAppbar.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/Screens/Views/patient/Bottomnavigationscreens/Medication.dart';
import 'package:trachcare/style/design_system.dart';

class YourdailyReports extends StatefulWidget {
  final String name;
  final String imagePath;

  const YourdailyReports({
    super.key,
    required this.name,
    required this.imagePath,
  });

  @override
  State<YourdailyReports> createState() => _YourdailyReportsState();
}

class _YourdailyReportsState extends State<YourdailyReports> {
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> patientData = {
    'patient_id': patient_id,
    'respiratory_rate': '',
    'heart_rate': '',
    'spo2_room_air': '',
    'daily_dressing_done': false,
    'tracheostomy_tie_changed': false,
    'suctioning_done': false,
    'oral_feeds_started': false,
    'changed_to_green_tube': false,
    'able_to_breathe_through_nose': false,
    'secretion_color_consistency': '',
    'cough_or_breathlessness': false,
    'breath_duration': '',
    'spigotting_status': 'Not Applicable',
  };

  bool _submitting = false;

  Future<void> updatePatientData() async {
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final request = http.MultipartRequest('POST', Uri.parse(SubmitVitalsUrl));
      request.headers.addAll({'Content-Type': 'multipart/form-data'});

      patientData.forEach((key, value) {
        request.fields[key] =
            value is bool ? (value ? 'Yes' : 'No') : value.toString();
      });

      final response = await request.send();

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MedicationPage()),
          (route) => false,
        );
        messenger.showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 19),
                SizedBox(width: 8),
                Expanded(child: Text('Daily report submitted')),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        throw Exception('Failed to update patient data');
      }
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to update patient data'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    updatePatientData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppbar(
        Title: 'Daily queries',
        subtitle: 'Today · ${DateTime.now().day}/${DateTime.now().month}',
        height: 92,
        onTap: () => Navigator.pop(context),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(
              top: AppSpacing.lg, bottom: AppSpacing.xxxl),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Column(
                children: [
                  TcPatientHeader(
                    name: widget.name,
                    patientId: patient_id,
                    imagePath: trachcareAsset('${widget.imagePath}'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionCard(
                    title: 'Vitals',
                    caption: 'Enter the readings you measured today',
                    children: [
                      _NumberField(
                        label: 'Respiratory rate',
                        unit: 'breaths/min',
                        icon: Icons.air_rounded,
                        validatorMessage: 'Please enter respiratory rate',
                        onChanged: (v) => patientData['respiratory_rate'] = v,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _NumberField(
                        label: 'Heart rate',
                        unit: 'bpm',
                        icon: Icons.favorite_border_rounded,
                        validatorMessage: 'Please enter heart rate',
                        onChanged: (v) => patientData['heart_rate'] = v,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _NumberField(
                        label: 'SPO2 @ room air',
                        unit: '%',
                        icon: Icons.water_drop_outlined,
                        validatorMessage: 'Please enter SPO2',
                        onChanged: (v) => patientData['spo2_room_air'] = v,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionCard(
                    title: 'Care checklist',
                    caption: 'Tap Yes or No for each task',
                    children: [
                      _YesNoRow(
                        question: 'Daily dressing done?',
                        value: patientData['daily_dressing_done'] as bool,
                        onChanged: (v) => setState(
                            () => patientData['daily_dressing_done'] = v),
                      ),
                      _YesNoRow(
                        question: 'Tracheostomy tie changed?',
                        value: patientData['tracheostomy_tie_changed'] as bool,
                        onChanged: (v) => setState(
                            () => patientData['tracheostomy_tie_changed'] = v),
                      ),
                      _YesNoRow(
                        question: 'Suctioning done?',
                        value: patientData['suctioning_done'] as bool,
                        onChanged: (v) =>
                            setState(() => patientData['suctioning_done'] = v),
                      ),
                      if (patientData['suctioning_done'] == true)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: TextFormField(
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please describe the secretion'
                                : null,
                            onChanged: (v) =>
                                patientData['secretion_color_consistency'] = v,
                            decoration: const InputDecoration(
                              labelText: 'Secretion colour and consistency',
                              prefixIcon:
                                  Icon(Icons.palette_outlined, size: 20),
                            ),
                          ),
                        ),
                      _YesNoRow(
                        question: 'Started on oral feeds?',
                        value: patientData['oral_feeds_started'] as bool,
                        onChanged: (v) => setState(
                            () => patientData['oral_feeds_started'] = v),
                      ),
                      if (patientData['oral_feeds_started'] == true)
                        _YesNoRow(
                          question: 'Experiencing cough or breathlessness?',
                          value: patientData['cough_or_breathlessness'] as bool,
                          onChanged: (v) => setState(
                              () => patientData['cough_or_breathlessness'] = v),
                        ),
                      _YesNoRow(
                        question: 'Changed to green tube?',
                        value: patientData['changed_to_green_tube'] as bool,
                        onChanged: (v) => setState(
                            () => patientData['changed_to_green_tube'] = v),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        initialValue:
                            patientData['spigotting_status'] as String,
                        decoration: const InputDecoration(
                          labelText: 'Spigotting status',
                          prefixIcon: Icon(Icons.timer_outlined, size: 20),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Not Applicable',
                              child: Text('Not applicable')),
                          DropdownMenuItem(
                              value: 'Tolerated', child: Text('Tolerated')),
                          DropdownMenuItem(
                              value: 'Partial', child: Text('Partial')),
                          DropdownMenuItem(
                              value: 'Not tolerated',
                              child: Text('Not tolerated')),
                        ],
                        onChanged: (v) => setState(() =>
                            patientData['spigotting_status'] =
                                v ?? 'Not Applicable'),
                      ),
                      _YesNoRow(
                        question:
                            'Breathes through nose while the tube is blocked?',
                        value:
                            patientData['able_to_breathe_through_nose'] as bool,
                        onChanged: (v) => setState(() =>
                            patientData['able_to_breathe_through_nose'] = v),
                      ),
                      if (patientData['able_to_breathe_through_nose'] == true)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: _NumberField(
                            label: 'Breath duration',
                            unit: 'minutes',
                            icon: Icons.schedule_rounded,
                            validatorMessage: 'Please enter breath duration',
                            onChanged: (v) =>
                                patientData['breath_duration'] = v,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TcButton(
                    label: _submitting ? 'Submitting…' : 'Submit report',
                    icon: _submitting ? null : Icons.send_rounded,
                    onPressed: _submitting ? null : _save,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: Text(
                      'This report goes straight to your assigned doctor.',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5, color: AppColors.inkMuted),
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
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.caption,
    required this.children,
  });

  final String title;
  final String caption;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return TcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TcSectionHeader(eyebrow: 'Section', title: title, subtitle: caption),
          ...children,
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.unit,
    required this.icon,
    required this.validatorMessage,
    required this.onChanged,
  });

  final String label;
  final String unit;
  final IconData icon;
  final String validatorMessage;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      validator: (v) => (v == null || v.isEmpty) ? validatorMessage : null,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(color: AppColors.ink),
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        prefixIcon: Icon(icon, size: 20, color: AppColors.inkMuted),
      ),
    );
  }
}

class _YesNoRow extends StatelessWidget {
  const _YesNoRow({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final String question;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600, color: AppColors.ink),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: _Segment(
                  label: 'Yes',
                  selected: value,
                  accent: AppColors.success,
                  accentSoft: AppColors.successSoft,
                  onTap: () => onChanged(true),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Segment(
                  label: 'No',
                  selected: !value,
                  accent: AppColors.danger,
                  accentSoft: AppColors.dangerSoft,
                  onTap: () => onChanged(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.accent,
    required this.accentSoft,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final Color accentSoft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: selected ? accentSoft : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: selected ? accent : AppColors.outline, width: 1.4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 42,
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? accent : AppColors.inkMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
