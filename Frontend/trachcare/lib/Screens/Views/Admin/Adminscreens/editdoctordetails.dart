import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trachcare/Api/API_funcation/doctordetails.dart';
import 'package:trachcare/Api/API_funcation/json_client.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/NAppbar.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';

class Editdoctordetails extends StatefulWidget {
  final String doctorId;

  const Editdoctordetails({super.key, required this.doctorId});

  @override
  State<Editdoctordetails> createState() => _EditdoctordetailsState();
}

class _EditdoctordetailsState extends State<Editdoctordetails> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController doctorRegNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  File? _pickedImage;
  String _avatarUrl = '';
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  @override
  void dispose() {
    usernameController.dispose();
    doctorRegNoController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _hydrate() async {
    try {
      final raw =
          await fetchJson('$doctordetailsUrl?doctor_id=${widget.doctorId}');
      final data = raw is Map ? raw['doctorInfo'] : raw;
      if (!mounted || data == null) return;
      setState(() {
        usernameController.text = data['username']?.toString() ?? '';
        doctorRegNoController.text = data['doctor_reg_no']?.toString() ?? '';
        emailController.text = data['email']?.toString() ?? '';
        phoneNumberController.text = data['phone_number']?.toString() ?? '';
        passwordController.text = data['password']?.toString() ?? '';
        _avatarUrl = trachcareAsset(data['image_path']?.toString());
      });
    } catch (e) {
      if (!mounted) return;
      setState(() =>
          _loadError = 'Could not load this doctor. Check the connection.');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final file =
        await ImagePicker().pickImage(source: source, imageQuality: 92);
    if (file == null) return;
    setState(() => _pickedImage = File(file.path));
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    await updateDoctorDetails(
      context,
      widget.doctorId,
      _pickedImage,
      usernameController.text.trim(),
      doctorRegNoController.text.trim(),
      emailController.text.trim(),
      phoneNumberController.text.trim(),
      passwordController.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final canSave = !_saving && _loadError == null;

    return Scaffold(
      appBar: NormalAppbar(
        Title: 'Edit doctor',
        subtitle: 'Changes apply to their next sign-in',
        height: 92,
        onTap: () => Navigator.maybePop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.page, AppSpacing.lg, AppSpacing.page, 40),
        children: [
          if (_loadError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: TcCard(
                color: AppColors.dangerSoft,
                shadows: const [],
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.danger, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(_loadError!,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    TcIconButton(
                      icon: Icons.refresh_rounded,
                      background: Colors.white,
                      color: AppColors.danger,
                      onPressed: () {
                        setState(() => _loadError = null);
                        _hydrate();
                      },
                    ),
                  ],
                ),
              ),
            ),
          TcProfileHero(
            name: usernameController.text.trim().isEmpty
                ? 'New doctor'
                : usernameController.text.trim(),
            imagePath: _avatarUrl,
            localImage: _pickedImage?.path,
            role: 'Registration ${doctorRegNoController.text.trim()}',
            idLabel: 'Doctor ID ${widget.doctorId}',
            fallbackIcon: Icons.local_hospital_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TcButton(
                label: 'Change picture',
                icon: Icons.photo_camera_rounded,
                expand: false,
                height: 44,
                gradient: const LinearGradient(
                  colors: [AppColors.tealLight, AppColors.mint],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onPressed: _saving ? null : _showPicker,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
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
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a name'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TcField(
                  label: 'Registration number',
                  controller: doctorRegNoController,
                  icon: Icons.badge_outlined,
                  enabled: canSave,
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter the medical registration number'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TcField(
                  label: 'Email',
                  controller: emailController,
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  enabled: canSave,
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value == null || !value.contains('@'))
                      ? 'Enter a valid email address'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TcField(
                  label: 'Phone number',
                  controller: phoneNumberController,
                  icon: Icons.call_outlined,
                  keyboardType: TextInputType.phone,
                  enabled: canSave,
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a phone number'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TcField(
                  label: 'Password',
                  controller: passwordController,
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  enabled: canSave,
                  textInputAction: TextInputAction.done,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'A password is required to save'
                      : null,
                ),
                const SizedBox(height: AppSpacing.xxl),
                TcButton(
                  label: _saving ? 'Saving…' : 'Save changes',
                  icon: Icons.check_rounded,
                  onPressed: canSave ? _save : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                eyebrow: 'Profile photo',
                title: 'Where is the new picture?',
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
}
