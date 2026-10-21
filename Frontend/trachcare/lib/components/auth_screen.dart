import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trachcare/Api/DataStore/Datastore.dart';
import 'package:trachcare/components/auth_forms.dart';
import 'package:trachcare/components/auth_shell.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/style/responsive.dart';

/// Shared layout for the three role sign-in screens.
///
/// Mirrors figma-import/png/03..05: teal brand header with the portal eyebrow
/// and role glyph, then a white sheet holding labelled credential fields and
/// the remember-me / reset row.
class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.role,
    required this.portal,
    required this.hint,
    required this.roleIcon,
    required this.actionGradient,
    required this.onSubmit,
    this.idLabel = 'Email',
    this.idIcon = Icons.person_outline_rounded,
    this.validateId = _requiredEmail,
  });

  final String role;
  final String portal;
  final String hint;
  final IconData roleIcon;
  final Gradient actionGradient;
  final VoidCallback onSubmit;
  final String idLabel;
  final IconData idIcon;
  final String? Function(String?) validateId;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const _savedEmailKey = 'trachcare.savedEmail';

  final _formKey = GlobalKey<FormState>();
  final _store = LoginDataStore();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _remember = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _restoreEmail();
  }

  Future<void> _restoreEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_savedEmailKey);
    if (saved == null || !mounted) return;
    setState(() {
      _username.text = saved;
      _remember = true;
    });
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = _username.text.trim();
    _store.Setusername(email);
    _store.SetPassword(_password.text);
    SharedPreferences.getInstance().then((p) => _remember
        ? p.setString(_savedEmailKey, email)
        : p.remove(_savedEmailKey));
    setState(() => _submitting = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      widget.onSubmit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      portal: widget.portal,
      headline: 'Welcome back',
      hint: widget.hint,
      roleIcon: widget.roleIcon,
      sheetTitle: '${widget.role} sign in',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthField(
              controller: _username,
              label: widget.idLabel,
              icon: widget.idIcon,
              keyboardType: TextInputType.emailAddress,
              validator: widget.validateId,
            ),
            SizedBox(height: AppSize.s(14)),
            AuthField(
              controller: _password,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter your password' : null,
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
            SizedBox(height: AppSize.s(12)),
            Row(
              children: [
                AuthCheck(
                  label: 'Keep me signed in',
                  value: _remember,
                  onChanged: (v) => setState(() => _remember = v),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ForgotPasswordScreen(
                        role: widget.role,
                        portal: widget.portal,
                        roleIcon: widget.roleIcon,
                      ),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: AppSize.s(4)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot password?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: AppSize.s(12.5),
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSize.s(20)),
            TcButton(
              label: _submitting ? 'Signing in…' : 'Sign in',
              gradient: widget.actionGradient,
              onPressed: _submitting ? null : _submit,
            ),
            SizedBox(height: AppSize.s(22)),
            const HairlineLabel(label: 'SECURE SIGN-IN'),
            SizedBox(height: AppSize.s(16)),
            const PrivacyNote(),
            SizedBox(height: AppSize.s(18)),
            Center(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: 'New to TrachCare? ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: AppSize.s(12.5),
                      color: AppColors.inkMuted,
                    ),
                  ),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SignupScreen(role: widget.role),
                        ),
                      ),
                      child: Text(
                        'Create an account',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppSize.s(12.5),
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? _requiredEmail(String? v) {
  final text = v?.trim() ?? '';
  if (text.isEmpty) return 'Enter your registered email';
  if (!text.contains('@')) return 'That does not look like an email';
  return null;
}

/// AdminLogin.php keys on `username` while the doctor and patient endpoints key
/// on `email`, so the credential field has to change meaning per role.
String? requiredText(String? v) =>
    (v == null || v.trim().isEmpty) ? 'This field is required' : null;
