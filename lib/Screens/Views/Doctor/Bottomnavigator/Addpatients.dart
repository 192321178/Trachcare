import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trachcare/Api/API_funcation/patientsdetails.dart';
import 'package:trachcare/Api/DataStore/Datastore.dart';
import 'package:trachcare/components/NAppbar.dart';
import 'package:trachcare/components/motion.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';

/// One text input on the registration form. Declaring the whole chart as data
/// keeps the 30 controllers, validators and section grouping in one place.
class _PatientField {
  const _PatientField(this.id, this.label,
      {this.icon, this.keyboard, this.obscure = false, this.date = false});

  final String id;
  final String label;
  final IconData? icon;
  final TextInputType? keyboard;
  final bool obscure;
  final bool date;
}

const List<_PatientField> _fields = [
  _PatientField('name', 'Full name', icon: Icons.badge_rounded),
  _PatientField('email', 'Email',
      icon: Icons.alternate_email_rounded,
      keyboard: TextInputType.emailAddress),
  _PatientField('phonenumber', 'Phone number',
      icon: Icons.phone_rounded, keyboard: TextInputType.phone),
  _PatientField('password', 'Account password',
      icon: Icons.lock_rounded, obscure: true),
  _PatientField('age', 'Age', keyboard: TextInputType.number),
  _PatientField('gender', 'Gender'),
  _PatientField('address', 'Address', icon: Icons.home_rounded),
  _PatientField('appoinment', 'Next appointment',
      icon: Icons.event_rounded, date: true),
  _PatientField('bmi', 'BMI', keyboard: TextInputType.number),
  _PatientField('diagnosis', 'Diagnosis'),
  _PatientField('surgeryStatus', 'Surgery status'),
  _PatientField('postOpTracheostomyDay', 'Post-op tracheostomy day'),
  _PatientField('tubeNameSize', 'Tube name and size'),
  _PatientField('indicationOfTracheostomy', 'Indication of tracheostomy'),
  _PatientField('comorbidities', 'Comorbidities'),
  _PatientField('baselineVitals', 'Baseline vitals'),
  _PatientField('respiratoryRate', 'Respiratory rate',
      keyboard: TextInputType.number),
  _PatientField('heartRate', 'Heart rate', keyboard: TextInputType.number),
  _PatientField('spo2RoomAir', 'SpO2 @ room air',
      keyboard: TextInputType.number),
  _PatientField('hemoglobin', 'Hemoglobin', keyboard: TextInputType.number),
  _PatientField('srSodium', 'Sodium (Sr.)', keyboard: TextInputType.number),
  _PatientField('srPotassium', 'Potassium (Sr.)',
      keyboard: TextInputType.number),
  _PatientField('srCalcium', 'Calcium (Sr.)', keyboard: TextInputType.number),
  _PatientField('srBicarbonate', 'Bicarbonate (Sr.)',
      keyboard: TextInputType.number),
  _PatientField('pt', 'PT', keyboard: TextInputType.number),
  _PatientField('aptt', 'APTT', keyboard: TextInputType.number),
  _PatientField('inr', 'INR', keyboard: TextInputType.number),
  _PatientField('platelets', 'Platelets', keyboard: TextInputType.number),
  _PatientField('liverFunctionTest', 'Liver function test'),
  _PatientField('renalFunctionTest', 'Renal function test'),
];

const List<(String, List<String>)> _sections = [
  (
    'Identity and contact',
    [
      'name',
      'email',
      'phonenumber',
      'password',
      'age',
      'gender',
      'address',
    ]
  ),
  (
    'Airway and surgical plan',
    [
      'appoinment',
      'bmi',
      'diagnosis',
      'surgeryStatus',
      'postOpTracheostomyDay',
      'tubeNameSize',
      'indicationOfTracheostomy',
      'comorbidities',
    ]
  ),
  (
    'Baseline vitals',
    [
      'baselineVitals',
      'respiratoryRate',
      'heartRate',
      'spo2RoomAir',
    ]
  ),
  (
    'Blood work',
    [
      'hemoglobin',
      'srSodium',
      'srPotassium',
      'srCalcium',
      'srBicarbonate',
      'pt',
      'aptt',
      'inr',
      'platelets',
      'liverFunctionTest',
      'renalFunctionTest',
    ]
  ),
];

/// Registers a new patient and links them to the signed-in doctor.
class Addpatients extends StatefulWidget {
  const Addpatients({super.key});

  @override
  State<Addpatients> createState() => _AddpatientsState();
}

class _AddpatientsState extends State<Addpatients> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    for (final f in _fields) f.id: TextEditingController(),
  };
  File? _image;
  final ImagePicker _picker = ImagePicker();


  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _text(String id) => _controllers[id]!.text.trim();

  Future<void> _pickImage({required ImageSource source}) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _choosePhoto() {
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text('Patient photo',
                style: Theme.of(sheetContext).textTheme.titleMedium),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(sheetContext);
                _pickImage(source: ImageSource.camera);
              },
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Take a photo'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(sheetContext);
                _pickImage(source: ImageSource.gallery);
              },
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Choose from gallery'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(sheetContext),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(String id) async {
    final now = DateTime.now();
    final first = DateTime(now.year - 1, 1, 1);
    final last = DateTime(now.year + 5, 12, 31);

    DateTime? picked;
    if (Platform.isIOS) {
      picked = await showCupertinoModalPopup<DateTime>(
        context: context,
        builder: (popupContext) {
          var temp = now;
          return SafeArea(
            child: ColoredBox(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 220,
                    child: CupertinoDatePicker(
                      initialDateTime: now,
                      mode: CupertinoDatePickerMode.date,
                      maximumDate: last,
                      minimumDate: first,
                      onDateTimeChanged: (d) => temp = d,
                    ),
                  ),
                  CupertinoButton(
                    child: const Text('Confirm'),
                    onPressed: () => Navigator.pop(popupContext, temp),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: first,
        lastDate: last,
      );
    }

    if (picked == null) return;
    final y = picked.year.toString().padLeft(4, '0');
    final m = picked.month.toString().padLeft(2, '0');
    final d = picked.day.toString().padLeft(2, '0');
    setState(() => _controllers[id]!.text = '$y-$m-$d');
  }

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Add a photo and fill in every field before saving.')));
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final saved = await addPatientDetails(
      context,
      _image!,
      Doctor_id,
      _text('name'),
      _text('email'),
      _text('phonenumber'),
      _text('password'),
      _text('age'),
      _text('gender'),
      _text('address'),
      _text('appoinment'),
      _text('bmi'),
      _text('diagnosis'),
      _text('surgeryStatus'),
      _text('postOpTracheostomyDay'),
      _text('tubeNameSize'),
      _text('baselineVitals'),
      _text('respiratoryRate'),
      _text('heartRate'),
      _text('spo2RoomAir'),
      _text('indicationOfTracheostomy'),
      _text('comorbidities'),
      _text('hemoglobin'),
      _text('srSodium'),
      _text('srPotassium'),
      _text('srCalcium'),
      _text('srBicarbonate'),
      _text('pt'),
      _text('aptt'),
      _text('inr'),
      _text('platelets'),
      _text('liverFunctionTest'),
      _text('renalFunctionTest'),
    );
    if (!mounted) return;
    // Only leave the form once the chart really exists on the server — on
    // failure the entered data stays put so nothing has to be re-typed.
    if (saved) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Patient submitted for review.')));
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final byId = {for (final f in _fields) f.id: f};

    return Scaffold(
      appBar: NormalAppbar(
        Title: 'Add patient',
        subtitle: 'Create a chart and assign it to your list',
        height: 92,
        onTap: () => Navigator.maybePop(context),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, AppSpacing.lg, AppSpacing.page, 120),
          children: [
            _PhotoPicker(image: _image, onTap: _choosePhoto),
            const SizedBox(height: AppSpacing.xl),
            for (final (title, ids) in _sections) ...[
              TcSectionHeader(title: title),
              const SizedBox(height: AppSpacing.md),
              TcCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final id in ids) ...[
                      _buildField(byId[id]!, id),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            TcAsyncButton(
              label: 'Create patient',
              busyLabel: 'Creating chart',
              icon: Icons.person_add_alt_1_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(_PatientField f, String id) {
    if (f.date) {
      return GestureDetector(
        onTap: () => _pickDate(id),
        child: AbsorbPointer(
          child: TcField(
            label: f.label,
            icon: f.icon,
            controller: _controllers[id]!,
            validator: _required(f.label),
            suffix: const Icon(Icons.calendar_today_rounded,
                size: 18, color: AppColors.teal),
          ),
        ),
      );
    }
    return TcField(
      label: f.label,
      icon: f.icon,
      controller: _controllers[id]!,
      keyboardType: f.keyboard,
      obscure: f.obscure,
      textInputAction: TextInputAction.next,
      validator: _required(f.label),
    );
  }

  String? Function(String?) _required(String label) => (value) =>
      (value == null || value.trim().isEmpty) ? 'Enter $label' : null;
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.image, required this.onTap});

  final File? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              TcAvatar(
                  localImage: image?.path,
                  size: 96,
                  fallbackIcon: Icons.person_rounded),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: const Icon(Icons.add_a_photo_rounded,
                      size: 15, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            image == null ? 'Tap to add a photo' : 'Change photo',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}
