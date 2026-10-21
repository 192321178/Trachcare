import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trachcare/Api/API_funcation/doctordetails.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/Api/DataStore/Datastore.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/Screens/Views/patient/patientscreens/patientprofile.dart';
import 'package:trachcare/style/design_system.dart';

class Editpatientprofile extends StatefulWidget {
  final String patientId;
  final String imagepath;
  final String username;
  final String doctorRegNo;
  final String email;
  final String phoneNumber;
  final String password;

  const Editpatientprofile({
    super.key,
    required this.patientId,
    required this.imagepath,
    required this.username,
    required this.doctorRegNo,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  @override
  State<Editpatientprofile> createState() => _EditpatientprofileState();
}

class _EditpatientprofileState extends State<Editpatientprofile> {
  final store = LoginDataStore();
  final _formKey = GlobalKey<FormState>();

  late final usernameController = TextEditingController(text: widget.username);
  late final emailController = TextEditingController(text: widget.email);
  late final phoneNumberController =
      TextEditingController(text: widget.phoneNumber);
  late final passwordController = TextEditingController(text: widget.password);

  File? imageFile;
  bool _obscure = true;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded,
            size: 38, color: AppColors.success),
        title: const Text('Profile saved'),
        content: const Text('Your details have been updated.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context).pushReplacement(CupertinoPageRoute(
                builder: (context) => const p_ProfilePage(),
              ));
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _formKey.currentState!.reset();
    updatePatientDetails(
      context,
      widget.patientId,
      imageFile,
      usernameController.text,
      emailController.text,
      phoneNumberController.text,
      passwordController.text,
    );
    store.Setusername(usernameController.text);
    _showSuccess();
  }

  Future<void> _getImage({required ImageSource source}) async {
    final file =
        await ImagePicker().pickImage(source: source, imageQuality: 100);
    if (file != null) {
      setState(() => imageFile = File(file.path));
    }
  }

  void _photoPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Change picture'),
        message: const Text('Choose where to get the new photo'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(ctx).pop();
              _getImage(source: ImageSource.camera);
            },
            child: const Text('Take a photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(ctx).pop();
              _getImage(source: ImageSource.gallery);
            },
            child: const Text('Choose from gallery'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = imageFile != null
        ? FileImage(imageFile!) as ImageProvider
        : NetworkImage(trachcareAsset('${widget.imagepath}'));

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 120,
              backgroundColor: AppColors.teal,
              leading: TcIconButton(
                icon: Icons.arrow_back_rounded,
                color: Colors.white,
                onPressed: () => Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(
                      builder: (context) => const p_ProfilePage()),
                ),
              ),
              title: const Text('Edit profile',
                  style: TextStyle(color: Colors.white)),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -44),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: AppShadows.card,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image(image: image, fit: BoxFit.cover),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () => _photoPicker(context),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.teal,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded,
                                        size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Center(
                          child: TextButton(
                            onPressed: () => _photoPicker(context),
                            child: const Text('Change picture'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TcCard(
                          child: Column(
                            children: [
                              TcField(
                                label: 'Username',
                                controller: usernameController,
                                icon: Icons.person_outline_rounded,
                                textInputAction: TextInputAction.next,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Please enter a username'
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TcField(
                                label: 'Email ID',
                                controller: emailController,
                                icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (v) =>
                                    (v == null || v.isEmpty || !v.contains('@'))
                                        ? 'Please enter a valid email address'
                                        : null,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TcField(
                                label: 'Phone number',
                                controller: phoneNumberController,
                                icon: Icons.call_outlined,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Please enter a phone number'
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TcField(
                                label: 'Password',
                                controller: passwordController,
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscure,
                                textInputAction: TextInputAction.done,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Please enter a password'
                                    : null,
                                suffix: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                    color: AppColors.inkMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        TcButton(
                          label: 'Save changes',
                          icon: Icons.save_rounded,
                          onPressed: _save,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
