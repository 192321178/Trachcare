import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trachcare/Api/API_funcation/doctordetails.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';

/// Admin tab body: register a new clinician account.
class Adddoctor extends StatefulWidget {
  const Adddoctor({super.key});

  @override
  State<Adddoctor> createState() => _AdddoctorState();
}

class _AdddoctorState extends State<Adddoctor> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController doctorRegNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  File? _image;
  bool _saving = false;

  @override
  void dispose() {
    usernameController.dispose();
    doctorRegNoController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final file =
        await ImagePicker().pickImage(source: source, imageQuality: 92);
    if (file == null) return;
    setState(() => _image = File(file.path));
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
              child: TcSectionHeader(
                eyebrow: 'Clinician photo',
                title: 'Where is the picture?',
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_camera_rounded, color: AppColors.teal),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.teal),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Add a photo and complete every field before saving.')));
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    await addDoctorDetails(
      context,
      _image!,
      usernameController.text.trim(),
      doctorRegNoController.text.trim(),
      emailController.text.trim(),
      phoneNumberController.text.trim(),
      passwordController.text,
    );
    if (!mounted) return;
    _formKey.currentState?.reset();
    setState(() {
      _saving = false;
      _image = null;
      usernameController.clear();
      doctorRegNoController.clear();
      emailController.clear();
      phoneNumberController.clear();
      passwordController.clear();
    });
    messenger.showSnackBar(const SnackBar(
        content: Text('Doctor created. They can sign in with these details.')));
  }

  String? _required(String label, String? value, {int? min}) {
    if (value == null || value.trim().isEmpty) return 'Enter $label';
    if (min != null && value.trim().length < min) {
      return '$label must be at least $min characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final canSave = !_saving;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.page, AppSpacing.lg, AppSpacing.page, 120),
      children: [
        TcSectionHeader(
          eyebrow: 'Team',
          title: 'Add a doctor',
          subtitle: 'They sign in with this email and password',
        ),
        TcCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              GestureDetector(
                onTap: _showPicker,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    TcAvatar(
                        localImage: _image?.path,
                        size: 92,
                        fallbackIcon: Icons.local_hospital_rounded),
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
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _image == null ? 'Tap to add a photo' : 'Change photo',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TcField(
                label: 'Display name',
                controller: usernameController,
                icon: Icons.person_outline_rounded,
                enabled: canSave,
                maxChars: 40,
                textInputAction: TextInputAction.next,
                validator: (v) => _required('a username', v),
              ),
              const SizedBox(height: AppSpacing.md),
              TcField(
                label: 'Medical registration number',
                controller: doctorRegNoController,
                icon: Icons.badge_outlined,
                enabled: canSave,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    _required('the registration number', v, min: 5),
              ),
              const SizedBox(height: AppSpacing.md),
              TcField(
                label: 'Email',
                controller: emailController,
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                enabled: canSave,
                maxChars: 50,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final base = _required('an email address', v);
                  if (base != null) return base;
                  if (!v!.contains('@')) return 'Email must contain "@"';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TcField(
                label: 'Phone number',
                controller: phoneNumberController,
                icon: Icons.call_outlined,
                keyboardType: TextInputType.phone,
                enabled: canSave,
                textInputAction: TextInputAction.next,
                validator: (v) => _required('a phone number', v),
              ),
              const SizedBox(height: AppSpacing.md),
              TcField(
                label: 'Temporary password',
                controller: passwordController,
                icon: Icons.lock_outline_rounded,
                obscure: true,
                enabled: canSave,
                maxChars: 20,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
                validator: (v) => _required('a password', v, min: 8),
              ),
              const SizedBox(height: AppSpacing.xxl),
              TcButton(
                label: _saving ? 'Creating…' : 'Create doctor',
                icon: Icons.person_add_alt_1_rounded,
                onPressed: canSave ? _save : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
