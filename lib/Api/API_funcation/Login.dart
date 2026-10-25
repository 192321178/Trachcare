import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/Api/DataStore/Datastore.dart';
import "package:http/http.dart" as http;
import 'package:trachcare/Screens/Views/patient/patientScreenmain.dart';
import 'package:trachcare/components/quotes.dart';

import '../../Screens/Views/Admin/Adminmainpage.dart';
import '../../Screens/Views/Doctor/Doctormainscreen.dart';

class LoginClassApi {
  /// A non-200 from the API used to be swallowed, so a dead endpoint looked
  /// like a broken button rather than a server problem.
  void _badResponse(BuildContext context, int status) {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      context: context,
      title:
          Text('Server returned $status — is the API at $apiBase reachable?'),
      icon: const Icon(Icons.cancel_rounded, color: Colors.red),
      showIcon: true,
      showProgressBar: false,
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  void _showSuccess(BuildContext context, String? message) {
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      context: context,
      title: Text('${message ?? 'Welcome back'} 🎉'),
      showProgressBar: false,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.green,
      ),
      showIcon: true,
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  void _showError(BuildContext context, String? message) {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      context: context,
      title: Text(message ?? 'Something went wrong'),
      icon: const Icon(
        Icons.cancel_rounded,
        color: Colors.red,
      ),
      showIcon: true,
      showProgressBar: false,
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  Future<void> DoctorLogin(BuildContext context) async {
    try {
      final response = await http
          .post(Uri.parse(DoctorLoginUrl), body: jsonEncode(LoginData))
          .timeout(const Duration(seconds: 20));
      if (!context.mounted) return;
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["Status"]) {
          // Set session state before navigating — the destination builds
          // immediately and reads these values.
          final user = data['userInfo'];
          Doctor_id = user is Map ? user['doctor_id'] : null;
          LoginData.clear();
          _showSuccess(context, data['message']);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Doctormainpage()),
              (route) => false);
        } else {
          _showError(context, data['message']);
        }
      } else {
        _badResponse(context, response.statusCode);
      }
    } on TimeoutException {
      if (!context.mounted) return;
      _showError(context, 'Server is not responding — check your connection');
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, 'Something went wrong');
    }
  }

// patient Login funcations

  Future<void> Patientlogin(BuildContext context) async {
    try {
      final response = await http
          .post(Uri.parse(PatientLoginurl), body: jsonEncode(LoginData))
          .timeout(const Duration(seconds: 20));
      if (!context.mounted) return;
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["Status"]) {
          // Set session state before navigating — the dashboard builds
          // immediately and needs both IDs for its API calls.
          final user = data['userInfo'];
          patient_id = user is Map ? user['patient_id'] : null;
          // patientprofile names this column doctor_id; reading `doctorid` here
          // left every patient-side call that needs the owning clinician null.
          Doctor_id = user is Map ? user['doctor_id'] : null;
          // Fresh "Thought for today" quote for this session.
          startPatientSession();
          LoginData.clear();
          _showSuccess(context, data['message']);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const PatientMainScreen(promptDailyReport: true)),
              (route) => false);
        } else {
          _showError(context, data['message']);
        }
      } else {
        _badResponse(context, response.statusCode);
      }
    } on TimeoutException {
      if (!context.mounted) return;
      _showError(context, 'Server is not responding — check your connection');
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, 'Something went wrong');
    }
  }

  Future<void> Adminlogin(BuildContext context) async {
    try {
      final response = await http
          .post(Uri.parse(AdminLoginurl), body: jsonEncode(LoginData))
          .timeout(const Duration(seconds: 20));
      if (!context.mounted) return;
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["Status"]) {
          // Set session state before navigating.
          final user = data['userInfo'];
          Doctor_id = user is Map ? user['doctor_id'] : null;
          LoginData.clear();
          _showSuccess(context, data['message']);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Adminmainpage()),
              (route) => false);
        } else {
          _showError(context, data['message']);
        }
      } else {
        _badResponse(context, response.statusCode);
      }
    } on TimeoutException {
      if (!context.mounted) return;
      _showError(context, 'Server is not responding — check your connection');
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, 'Something went wrong');
    }
  }
}
