import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/auth_shell.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/style/responsive.dart';

/// Self-service registration for Patient and Doctor.
///
/// Neither role used to have this because the account is not free-standing: a
/// patient row carries the `doctor_id` that owns their care, and a doctor row
/// is the authority an Admin is accountable for. Both are therefore gated on a
/// code that only the other side of the relationship can know.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.role});

  final String role;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _regNo = TextEditingController();
  final _linkCode = TextEditingController();

  bool _obscure = true;
  bool _busy = false;
  String? _error;

  bool get _isDoctor => widget.role == 'Doctor';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _regNo.dispose();
    _linkCode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final payload = <String, String>{
      'username': _name.text.trim(),
      'email': _email.text.trim(),
      'phone_number': _phone.text.trim(),
      'password': _password.text,
    };
    if (_isDoctor) {
      payload['doctor_reg_no'] = _regNo.text.trim();
      payload['admin_reg_no'] = _linkCode.text.trim();
    } else {
      payload['doctor_reg_no'] = _linkCode.text.trim();
    }
    try {
      final res = await http
          .post(
            Uri.parse(_isDoctor ? DoctorSignupUrl : PatientSignupUrl),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));
      if (!mounted) return;
      if (res.statusCode != 200) {
        setState(() {
          _busy = false;
          _error =
              'Server returned ${res.statusCode}. Is the updated backend deployed at $apiBase?';
        });
        return;
      }
      final data = jsonDecode(res.body);
      if (!mounted) return;
      if (data != null && data['Status'] == true) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Account created'),
            content: Text(
              data['message'] ??
                  'You can sign in with your email and password now.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to sign in'),
              ),
            ],
          ),
        );
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          _busy = false;
          _error = data?['message'] ?? 'We could not create that account.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not reach the server. Check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      portal: _isDoctor ? 'Doctor portal' : 'Patient portal',
      headline: 'Create account',
      hint: _isDoctor
          ? 'Join the TrachCare clinic roster. An administrator authorises every clinician.'
          : 'Register with the code your treating doctor gave you so your records stay linked.',
      roleIcon: _isDoctor
          ? Icons.medical_information_outlined
          : Icons.favorite_outline_rounded,
      sheetTitle: _isDoctor ? 'Doctor sign up' : 'Patient sign up',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthField(
              controller: _name,
              label: 'Full name',
              icon: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'Enter your full name'
                  : null,
            ),
            SizedBox(height: AppSize.s(14)),
            AuthField(
              controller: _email,
              label: 'Email',
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty || !t.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            SizedBox(height: AppSize.s(14)),
            AuthField(
              controller: _phone,
              label: 'Phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.replaceAll(RegExp(r'\D'), '').length < 10) {
                  return 'Enter a 10-digit number';
                }
                return null;
              },
            ),
            SizedBox(height: AppSize.s(14)),
            AuthField(
              controller: _password,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
              validator: (v) => (v == null || v.length < 8)
                  ? 'Use at least 8 characters'
                  : null,
              suffix: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: AppSize.s(20),
                  color: AppColors.inkMuted,
                ),
              ),
            ),
            if (_isDoctor) ...[
              SizedBox(height: AppSize.s(14)),
              AuthField(
                controller: _regNo,
                label: 'Medical council registration no',
                icon: Icons.badge_outlined,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter your registration number'
                    : null,
              ),
            ],
            SizedBox(height: AppSize.s(14)),
            AuthField(
              controller: _linkCode,
              label: _isDoctor ? 'Authorising admin reg no' : 'Doctor reg no',
              icon: Icons.link_rounded,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? _isDoctor
                      ? 'An administrator must authorise this account'
                      : 'Your doctor gives you this code'
                  : null,
            ),
            SizedBox(height: AppSize.s(8)),
            Padding(
              padding: EdgeInsets.only(left: AppSize.s(2), top: AppSize.s(6)),
              child: Text(
                _isDoctor
                    ? 'Without it the account is created but stays invisible to patients.'
                    : 'This links you to the clinician who reviews your daily report.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppSize.s(11.5),
                  height: 1.4,
                  color: AppColors.inkMuted,
                ),
              ),
            ),
            if (_error != null) ...[
              SizedBox(height: AppSize.s(14)),
              _ErrorBanner(text: _error!),
            ],
            SizedBox(height: AppSize.s(20)),
            TcButton(
              label: _busy ? 'Creating…' : 'Create account',
              onPressed: _busy ? null : _submit,
            ),
            SizedBox(height: AppSize.s(18)),
            const PrivacyNote(
              text:
                  'Passwords are stored server-side by the clinic. Ask your care team before sharing yours.',
            ),
          ],
        ),
      ),
    );
  }
}

/// Password recovery by email + registered phone.
///
/// The clinic server has no SMTP or SMS gateway wired up, so the reset token is
/// returned to the app and shown once rather than mailed. That is a deliberate
/// trade-off, not an oversight — see the note in ResetPassword.php.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.role,
    required this.portal,
    required this.roleIcon,
  });

  final String role;
  final String portal;
  final IconData roleIcon;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _tempPassword;

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final res = await http
          .post(
            Uri.parse(ResetPasswordUrl),
            body: jsonEncode({
              'role': widget.role.toLowerCase(),
              'email': _email.text.trim(),
              'phone_number': _phone.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));
      if (!mounted) return;
      if (res.statusCode != 200) {
        setState(() {
          _busy = false;
          _error =
              'Server returned ${res.statusCode}. Is the updated backend deployed at $apiBase?';
        });
        return;
      }
      final data = jsonDecode(res.body);
      if (!mounted) return;
      if (data != null && data['Status'] == true) {
        setState(() {
          _busy = false;
          _tempPassword = data['temporary_password'];
        });
      } else {
        setState(() {
          _busy = false;
          _error = data?['message'] ?? 'We could not verify those details.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not reach the server. Check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      portal: widget.portal,
      headline: 'Reset password',
      hint: 'Confirm the email and phone number on your TrachCare record.',
      roleIcon: Icons.key_outlined,
      sheetTitle: '${widget.role} password reset',
      child: _tempPassword == null
          ? Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthField(
                    controller: _email,
                    label: 'Registered email',
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Enter your registered email'
                        : null,
                  ),
                  SizedBox(height: AppSize.s(14)),
                  AuthField(
                    controller: _phone,
                    label: 'Registered phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter the phone number on file'
                        : null,
                  ),
                  if (_error != null) ...[
                    SizedBox(height: AppSize.s(14)),
                    _ErrorBanner(text: _error!),
                  ],
                  SizedBox(height: AppSize.s(20)),
                  TcButton(
                    label: _busy ? 'Checking…' : 'Send reset code',
                    onPressed: _busy ? null : _submit,
                  ),
                  SizedBox(height: AppSize.s(18)),
                  const PrivacyNote(
                    text:
                        'Both details must match the record your care team created.',
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(AppSize.s(16)),
                  decoration: BoxDecoration(
                    color: AppColors.mintSoft,
                    borderRadius: AppRadius.field,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Temporary password',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppSize.s(11),
                          fontWeight: FontWeight.w700,
                          letterSpacing: AppSize.s(1.2),
                          color: AppColors.tealDeep,
                        ),
                      ),
                      SizedBox(height: AppSize.s(8)),
                      SelectableText(
                        _tempPassword!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppSize.s(22),
                          fontWeight: FontWeight.w800,
                          letterSpacing: AppSize.s(1.5),
                          color: AppColors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSize.s(14)),
                Text(
                  'Sign in with this password, then change it from your profile. It will stop working once you do.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: AppSize.s(12.5),
                    height: 1.45,
                    color: AppColors.inkMuted,
                  ),
                ),
                SizedBox(height: AppSize.s(22)),
                TcButton(
                  label: 'Back to sign in',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.s(12)),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: AppRadius.field,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 16, color: AppColors.danger),
          SizedBox(width: AppSize.s(10)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppSize.s(12),
                height: 1.4,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
