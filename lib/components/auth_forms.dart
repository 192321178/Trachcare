import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/Api/DataStore/Datastore.dart';
import 'package:trachcare/Screens/Views/patient/patientScreenmain.dart';
import 'package:trachcare/components/auth_shell.dart';
import 'package:trachcare/components/quotes.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/style/responsive.dart';

/// Strict real email validation pattern
String? validateRealEmail(String? v) {
  final t = v?.trim() ?? '';
  if (t.isEmpty) return 'Enter your email address';
  final emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(t)) {
    return 'Enter a valid email address (e.g. name@gmail.com)';
  }
  return null;
}

// ============================================================================
// SIGNUP SCREEN (With Real Email 6-Digit OTP Verification for Doctor & Patient)
// ============================================================================

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
  final _confirmPassword = TextEditingController();
  final _regNo = TextEditingController();

  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _busy = false;
  String? _error;

  // OTP Verification state
  bool _otpStep = false;
  String _enteredOtp = '';

  bool get _isAdmin => widget.role.toLowerCase() == 'admin';
  bool get _isDoctor => widget.role.toLowerCase() == 'doctor';
  bool get _isPatient => widget.role.toLowerCase() == 'patient';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _regNo.dispose();
    super.dispose();
  }

  /// Step 1: Validate inputs and request OTP from backend
  Future<void> _handleInitialSubmit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // For Admin: keep direct registration (status = PENDING)
    if (_isAdmin) {
      await _executeDirectSignup('');
      return;
    }

    // For Doctor & Patient: Request 6-digit Email OTP
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final res = await http
          .post(
            Uri.parse(RequestOtpUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _email.text.trim(),
              'role': widget.role.toUpperCase(),
              'purpose': 'SIGNUP',
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data != null && data['success'] == true) {
        setState(() {
          _busy = false;
          _otpStep = true;
          _enteredOtp = '';
        });
        toastification.show(
          type: ToastificationType.info,
          style: ToastificationStyle.flatColored,
          context: context,
          title: const Text('Verification code sent to your email.'),
          showProgressBar: false,
          autoCloseDuration: const Duration(seconds: 4),
        );
      } else {
        setState(() {
          _busy = false;
          _error = data?['message'] ?? 'Could not send verification code.';
        });
      }
    } catch (_) {
      // Fallback: If OTP endpoint is unreachable on remote host, attempt direct signup
      await _executeDirectSignup('');
    }
  }

  /// Step 2: Verify OTP and finalize account creation
  Future<void> _verifyOtpAndSignup() async {
    if (_enteredOtp.length != 6) {
      setState(() => _error = 'Please enter the complete 6-digit code.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    await _executeDirectSignup(_enteredOtp);
  }

  /// Execute account creation with backend
  Future<void> _executeDirectSignup(String otp) async {
    final payload = <String, String>{
      'username': _name.text.trim(),
      'email': _email.text.trim(),
      'phone_number': _phone.text.trim(),
      'password': _password.text,
      if (otp.isNotEmpty) 'otp': otp,
    };

    if (_isDoctor && _regNo.text.trim().isNotEmpty) {
      payload['doctor_reg_no'] = _regNo.text.trim();
    }

    String endpointUrl;
    if (_isAdmin) {
      endpointUrl = AdminSignupUrl;
    } else if (_isDoctor) {
      endpointUrl = DoctorSignupUrl;
    } else {
      endpointUrl = PatientSignupUrl;
    }

    try {
      var res = await http
          .post(
            Uri.parse(endpointUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      // Fallback to root endpoints if remote server has not updated routing
      if (res.statusCode == 404 && !_isAdmin) {
        final fallbackUrl = _isDoctor
            ? "$apiBase/Adddoctordetails.php"
            : "$apiBase/addpatientsdetails.php";
        res = await http
            .post(
              Uri.parse(fallbackUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 20));
      }

      if (!mounted) return;
      if (res.statusCode != 200) {
        setState(() {
          _busy = false;
          _error =
              'Server returned ${res.statusCode}. Is backend reachable at $apiBase?';
        });
        return;
      }

      final data = jsonDecode(res.body);
      if (!mounted) return;

      if (data != null && (data['Status'] == true || data['success'] == true)) {
        setState(() => _busy = false);

        if (_isPatient) {
          toastification.show(
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            context: context,
            title: Text(data['message'] ??
                'Registration successful. Welcome to TrachCare.'),
            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
            showIcon: true,
            showProgressBar: false,
            autoCloseDuration: const Duration(seconds: 3),
          );

          if (data['userInfo'] != null) {
            patient_id = data['userInfo']['patient_id']?.toString() ?? '';
            Doctor_id = data['userInfo']['doctor_id']?.toString() ?? '';
          }
          // Fresh "Thought for today" quote for the new session.
          startPatientSession();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const PatientMainScreen()),
            (route) => false,
          );
        } else {
          final title = _isDoctor
              ? 'Doctor registration submitted'
              : 'Admin registration submitted';
          final message = _isDoctor
              ? 'Doctor registration submitted successfully.\n\nYour account is waiting for Admin approval.\nStatus: PENDING'
              : 'Admin registration submitted successfully.\n\nYour account is waiting for approval.\nStatus: PENDING';

          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.s(20)),
              ),
              title: Row(
                children: [
                  const Icon(Icons.hourglass_top_rounded, color: AppColors.teal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: AppSize.s(16),
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppSize.s(13),
                  height: 1.5,
                  color: AppColors.ink,
                ),
              ),
              actions: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSize.s(12)),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Back to sign in'),
                ),
              ],
            ),
          );
        }
      } else {
        setState(() {
          _busy = false;
          _error = data?['message'] ?? 'Registration failed. Please try again.';
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

  /// Resend verification code
  Future<void> _resendSignupOtp() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final res = await http
          .post(
            Uri.parse(RequestOtpUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _email.text.trim(),
              'role': widget.role.toUpperCase(),
              'purpose': 'SIGNUP',
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      final data = jsonDecode(res.body);
      setState(() => _busy = false);

      if (res.statusCode == 200 && data != null && data['success'] == true) {
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          context: context,
          title: const Text('New 6-digit code sent to your email.'),
          showProgressBar: false,
          autoCloseDuration: const Duration(seconds: 3),
        );
      } else {
        setState(() {
          _error = data?['message'] ?? 'Could not resend code. Please wait.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not reach server to resend code.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String portalName;
    String headline;
    String hintText;
    IconData roleIcon;

    if (_isAdmin) {
      portalName = 'Admin portal';
      headline = 'Create admin';
      hintText = 'Submit your administrator credentials for backend approval.';
      roleIcon = Icons.shield_outlined;
    } else if (_isDoctor) {
      portalName = 'Doctor portal';
      headline = _otpStep ? 'Verify email' : 'Create account';
      hintText = _otpStep
          ? 'Enter the 6-digit verification code sent to your Gmail.'
          : 'Join the TrachCare clinic roster. Real email verification required.';
      roleIcon = Icons.medical_information_outlined;
    } else {
      portalName = 'Patient portal';
      headline = _otpStep ? 'Verify email' : 'Create account';
      hintText = _otpStep
          ? 'Enter the 6-digit verification code sent to your Gmail.'
          : 'Create your TrachCare account to access your guided home care plan.';
      roleIcon = Icons.favorite_outline_rounded;
    }

    return AuthShell(
      portal: portalName,
      headline: headline,
      hint: hintText,
      roleIcon: roleIcon,
      sheetTitle: _otpStep
          ? 'Verify your email'
          : '${widget.role} sign up',
      child: _otpStep
          ? OtpVerificationWidget(
              email: _email.text.trim(),
              busy: _busy,
              errorMessage: _error,
              onOtpChanged: (otp) => setState(() => _enteredOtp = otp),
              onVerify: _verifyOtpAndSignup,
              onResend: _resendSignupOtp,
              onChangeEmail: () => setState(() {
                _otpStep = false;
                _error = null;
              }),
            )
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthField(
                    controller: _name,
                    label: _isAdmin ? 'Username' : 'Full name',
                    icon: Icons.person_outline_rounded,
                    validator: (v) => (v == null || v.trim().length < 3)
                        ? 'Enter at least 3 characters'
                        : null,
                  ),
                  SizedBox(height: AppSize.s(14)),
                  AuthField(
                    controller: _email,
                    label: 'Email',
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: validateRealEmail,
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
                  SizedBox(height: AppSize.s(14)),
                  AuthField(
                    controller: _confirmPassword,
                    label: 'Confirm password',
                    icon: Icons.lock_clock_outlined,
                    obscure: _obscureConfirm,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (v != _password.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    suffix: IconButton(
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(
                        _obscureConfirm
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
                      label: 'Medical council registration no (optional)',
                      icon: Icons.badge_outlined,
                      validator: (v) => null,
                    ),
                  ],
                  if (_error != null) ...[
                    SizedBox(height: AppSize.s(14)),
                    _ErrorBanner(text: _error!),
                  ],
                  SizedBox(height: AppSize.s(20)),
                  TcButton(
                    label: _busy
                        ? 'Submitting…'
                        : (_isAdmin ? 'Submit' : 'Continue to verification'),
                    onPressed: _busy ? null : _handleInitialSubmit,
                  ),
                  SizedBox(height: AppSize.s(18)),
                  PrivacyNote(
                    text: _isPatient
                        ? 'A real 6-digit verification code will be sent to your email.'
                        : 'Doctor registrations are verified via email and approved by administrators.',
                  ),
                ],
              ),
            ),
    );
  }
}

// ============================================================================
// FORGOT PASSWORD SCREEN (With 6-Digit OTP & Create New Password Flow)
// ============================================================================

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.role,
    required this.portal,
    this.roleIcon,
  });

  final String role;
  final String portal;
  final IconData? roleIcon;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  int _step = 1; // 1: Email entry, 2: OTP verification, 3: Create New Password
  String _enteredOtp = '';
  String? _resetToken;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  /// Step 1: Request 6-digit password reset OTP
  Future<void> _requestPasswordResetOtp() async {
    FocusScope.of(context).unfocus();
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final res = await http
          .post(
            Uri.parse(RequestOtpUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _email.text.trim(),
              'role': widget.role.toUpperCase(),
              'purpose': 'PASSWORD_RESET',
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data != null && data['success'] == true) {
        setState(() {
          _busy = false;
          _step = 2; // Move to OTP
          _enteredOtp = '';
        });
        toastification.show(
          type: ToastificationType.info,
          style: ToastificationStyle.flatColored,
          context: context,
          title: const Text('Password reset code sent to your email.'),
          showProgressBar: false,
          autoCloseDuration: const Duration(seconds: 4),
        );
      } else {
        setState(() {
          _busy = false;
          _error = data?['message'] ?? 'Could not send reset code.';
        });
      }
    } catch (_) {
      // Fallback to legacy single-step if server does not have OTP endpoints yet
      await _executeLegacyReset();
    }
  }

  /// Step 2: Verify OTP and receive reset token
  Future<void> _verifyResetOtp() async {
    if (_enteredOtp.length != 6) {
      setState(() => _error = 'Please enter the complete 6-digit code.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final res = await http
          .post(
            Uri.parse(VerifyOtpUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _email.text.trim(),
              'otp': _enteredOtp,
              'role': widget.role.toUpperCase(),
              'purpose': 'PASSWORD_RESET',
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data != null && data['success'] == true) {
        setState(() {
          _busy = false;
          _resetToken = data['reset_token'];
          _step = 3; // Move to Create New Password
          _error = null;
        });
      } else {
        setState(() {
          _busy = false;
          _error = data?['message'] ?? 'Invalid code. Please try again.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not verify code. Check connection.';
      });
    }
  }

  /// Step 3: Set new password
  Future<void> _submitNewPassword() async {
    FocusScope.of(context).unfocus();
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final res = await http
          .post(
            Uri.parse(ResetPasswordOtpUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _email.text.trim(),
              'role': widget.role.toUpperCase(),
              'reset_token': _resetToken,
              'new_password': _newPassword.text,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data != null && data['success'] == true) {
        setState(() => _busy = false);
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          context: context,
          title: const Text('Password reset successful! You can now sign in.'),
          showProgressBar: false,
          autoCloseDuration: const Duration(seconds: 4),
        );
        Navigator.pop(context); // Return to sign in
      } else {
        setState(() {
          _busy = false;
          _error = data?['message'] ?? 'Could not reset password.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not complete password reset. Check connection.';
      });
    }
  }

  /// Fallback to legacy single-step endpoint
  Future<void> _executeLegacyReset() async {
    try {
      final res = await http
          .post(
            Uri.parse(ResetPasswordUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'role': widget.role.toLowerCase(),
              'email': _email.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data != null && data['Status'] == true) {
        setState(() {
          _busy = false;
        });
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          context: context,
          title: Text(data['message'] ?? 'Reset instructions sent to email.'),
          showProgressBar: false,
          autoCloseDuration: const Duration(seconds: 4),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _busy = false;
          _error = data?['message'] ?? 'We could not verify that email address.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not reach server. Check connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String headline;
    String hintText;
    String sheetTitle;

    if (_step == 1) {
      headline = 'Reset password';
      hintText = 'Enter your registered Gmail to receive a 6-digit OTP code.';
      sheetTitle = '${widget.role} password reset';
    } else if (_step == 2) {
      headline = 'Verify OTP';
      hintText = 'Enter the 6-digit code sent to ${_email.text.trim()}.';
      sheetTitle = 'Enter 6-digit code';
    } else {
      headline = 'New password';
      hintText = 'Create a secure new password for your account.';
      sheetTitle = 'Create new password';
    }

    return AuthShell(
      portal: widget.portal,
      headline: headline,
      hint: hintText,
      roleIcon: widget.roleIcon ?? Icons.key_outlined,
      sheetTitle: sheetTitle,
      child: _buildCurrentStep(),
    );
  }

  Widget _buildCurrentStep() {
    if (_step == 1) {
      return Form(
        key: _emailFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthField(
              controller: _email,
              label: 'Registered Gmail',
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _requestPasswordResetOtp(),
              validator: validateRealEmail,
            ),
            if (_error != null) ...[
              SizedBox(height: AppSize.s(14)),
              _ErrorBanner(text: _error!),
            ],
            SizedBox(height: AppSize.s(20)),
            TcButton(
              label: _busy ? 'Sending code…' : 'Send reset code',
              onPressed: _busy ? null : _requestPasswordResetOtp,
            ),
            SizedBox(height: AppSize.s(18)),
            const PrivacyNote(
              text:
                  'A secure 6-digit code will be sent to your registered Gmail.',
            ),
          ],
        ),
      );
    } else if (_step == 2) {
      return OtpVerificationWidget(
        email: _email.text.trim(),
        busy: _busy,
        errorMessage: _error,
        onOtpChanged: (otp) => setState(() => _enteredOtp = otp),
        onVerify: _verifyResetOtp,
        onResend: _requestPasswordResetOtp,
        onChangeEmail: () => setState(() {
          _step = 1;
          _error = null;
        }),
      );
    } else {
      return Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthField(
              controller: _newPassword,
              label: 'New password',
              icon: Icons.lock_outline_rounded,
              obscure: _obscureNew,
              validator: (v) => (v == null || v.length < 8)
                  ? 'Use at least 8 characters'
                  : null,
              suffix: IconButton(
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
                icon: Icon(
                  _obscureNew
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: AppSize.s(20),
                  color: AppColors.inkMuted,
                ),
              ),
            ),
            SizedBox(height: AppSize.s(14)),
            AuthField(
              controller: _confirmPassword,
              label: 'Confirm new password',
              icon: Icons.lock_clock_outlined,
              obscure: _obscureConfirm,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Please confirm your new password';
                }
                if (v != _newPassword.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              suffix: IconButton(
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: AppSize.s(20),
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
              label: _busy ? 'Updating…' : 'Reset password',
              onPressed: _busy ? null : _submitNewPassword,
            ),
          ],
        ),
      );
    }
  }
}

// ============================================================================
// 6-DIGIT OTP INPUT COMPONENT (With Countdown Timer & Resend Restrictions)
// ============================================================================

class OtpVerificationWidget extends StatefulWidget {
  const OtpVerificationWidget({
    super.key,
    required this.email,
    required this.busy,
    required this.onOtpChanged,
    required this.onVerify,
    required this.onResend,
    this.onChangeEmail,
    this.errorMessage,
  });

  final String email;
  final bool busy;
  final ValueChanged<String> onOtpChanged;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback? onChangeEmail;
  final String? errorMessage;

  @override
  State<OtpVerificationWidget> createState() => _OtpVerificationWidgetState();
}

class _OtpVerificationWidgetState extends State<OtpVerificationWidget> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 300; // 5-minute expiry
  int _resendCooldown = 60; // 60-second resend restriction

  @override
  void initState() {
    super.initState();
    _startTimers();
  }

  void _startTimers() {
    _timer?.cancel();
    _secondsRemaining = 300;
    _resendCooldown = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) _secondsRemaining--;
        if (_resendCooldown > 0) _resendCooldown--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Pasted full 6-digit code
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < 6 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      widget.onOtpChanged(_currentOtp);
      if (digits.length >= 6) {
        _focusNodes[5].unfocus();
        widget.onVerify();
      }
      return;
    }

    widget.onOtpChanged(_currentOtp);

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (_currentOtp.length == 6) {
      _focusNodes[5].unfocus();
    }
  }

  String _formatTimer(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isOtpComplete = _currentOtp.length == 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Code sent to',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: AppSize.s(12),
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.email,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: AppSize.s(14),
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.onChangeEmail != null)
              TextButton(
                onPressed: widget.busy ? null : widget.onChangeEmail,
                child: Text(
                  'Change',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSize.s(22)),

        // 6 Digit boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: AppSize.s(45),
              height: AppSize.s(52),
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppSize.s(20),
                  fontWeight: FontWeight.w800,
                  color: AppColors.teal,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.surfaceMuted,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.s(12)),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.s(12)),
                    borderSide: const BorderSide(color: AppColors.teal, width: 2),
                  ),
                ),
                onChanged: (val) => _onDigitChanged(index, val),
              ),
            );
          }),
        ),

        SizedBox(height: AppSize.s(16)),

        // Timer row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.timer_outlined,
                    size: AppSize.s(15), color: AppColors.inkMuted),
                const SizedBox(width: 4),
                Text(
                  _secondsRemaining > 0
                      ? 'Expires in ${_formatTimer(_secondsRemaining)}'
                      : 'Code expired',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: AppSize.s(12),
                    fontWeight: FontWeight.w600,
                    color: _secondsRemaining > 0
                        ? AppColors.inkMuted
                        : AppColors.danger,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: (_resendCooldown > 0 || widget.busy)
                  ? null
                  : () {
                      _startTimers();
                      for (final c in _controllers) {
                        c.clear();
                      }
                      _focusNodes[0].requestFocus();
                      widget.onResend();
                    },
              child: Text(
                _resendCooldown > 0
                    ? 'Resend in ${_resendCooldown}s'
                    : 'Resend code',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppSize.s(12),
                  fontWeight: FontWeight.w700,
                  color: _resendCooldown > 0
                      ? AppColors.inkMuted
                      : AppColors.teal,
                ),
              ),
            ),
          ],
        ),

        if (widget.errorMessage != null) ...[
          SizedBox(height: AppSize.s(12)),
          _ErrorBanner(text: widget.errorMessage!),
        ],

        SizedBox(height: AppSize.s(22)),

        TcButton(
          label: widget.busy ? 'Verifying…' : 'Verify code',
          onPressed: (isOtpComplete && !widget.busy) ? widget.onVerify : null,
        ),
      ],
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
