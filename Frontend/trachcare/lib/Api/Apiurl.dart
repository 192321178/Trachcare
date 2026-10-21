// ─── Environment switch ───────────────────────────────────────────────────────
// The backend is plain HTTP on the XAMPP box; its HTTPS vhost has a different
// document root, so every `https://…/*.php` request 404s while `http://` serves.
//
// Point the app somewhere else at build time without editing this file:
//   flutter run   --dart-define=API_BASE=http://192.168.1.20/Trachcare
//   flutter build --dart-define=API_BASE=https://api.example.com/Trachcare
const apiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://180.235.121.245/Trachcare',
);

/// Authentication endpoints for Patient, Doctor, and Admin login.
String PatientLoginurl = "$apiBase/auth/patientAuth/PatientLogin.php";
String DoctorLoginUrl = "$apiBase/auth/DoctorAuth/DoctorLogin.php";
String AdminLoginurl = "$apiBase/auth/AdminAuth/AdminLogin.php";

/// Self-service auth: patient/doctor registration and password recovery.
/// These endpoints ship in Backend/Trachcare but only answer once that folder
/// has been uploaded to the server — until then they 404.
String PatientSignupUrl = "$apiBase/auth/patientAuth/PatientSignup.php";
String DoctorSignupUrl = "$apiBase/auth/DoctorAuth/DoctorSignup.php";
String ResetPasswordUrl = "$apiBase/auth/ResetPassword.php";

/// Submit / add endpoints — create records on the server.
String PatientDetailsSubmitUrl = "$apiBase/Doctor/Addpatients.php";
String SubmitVitalsUrl = "$apiBase/Patient/adddailyupdates.php";
String UpdatePatientDetailsUrl = "$apiBase/Patient/editpatientprofile.php";
String AdddoctordetailsUrl = "$apiBase/Admin/Adddoctordetails.php";

/// View / read endpoints — fetch record details from the server.
String viewstory = "$apiBase/Doctor/viewstory.php";
String dailyreport = "$apiBase/Patient/dailyreport.php";
String ViewPatientDetailsUrl = "$apiBase/Doctor/viewpatientdetails.php";
String doctordetailsUrl = "$apiBase/Admin/doctordetails.php";
String admindetailsUrl = "$apiBase/Admin/admindetails.php";
String ViewDailyVitalsUrl = "$apiBase/Doctor/Dailyupdates.php";
String getpatientdetialsurl = "$apiBase/Patient/getdetials.php";

/// Recent reports for a whole panel, so the roster can flag who needs a look
/// in one request instead of one per patient.
String flaggedReportsUrl = "$apiBase/Doctor/flaggedreports.php";

/// List endpoints — return paginated or full lists of records.
String DoctorslistUrl = "$apiBase/Admin/Doctorlist.php";
String PatientslistUrl = "$apiBase/Doctor/Patientslist.php";
String allpatientslistUrl = "$apiBase/Admin/patientlist.php";

/// Update endpoint — modify an existing doctor record.
String UpdateDoctorDetailsUrl = "$apiBase/Doctor/Addpatients.php";

/// Video and status endpoints.
String Addvideos = "$apiBase/Admin/addvideos.php";
String exporturl = "$apiBase/Admin/export.php";
String statusurl = "$apiBase/Doctor/status.php";
String statusurlpatient = "$apiBase/Patient/status.php";
String updatestatusurl = "$apiBase/Doctor/updatestatus.php";
String updatestatusspogotingurl = "$apiBase/Doctor/spogoting_status.php";

/// Absolute URL for a server-stored image or video.
///
/// The backend returns paths prefixed with `../` — sometimes two levels deep —
/// so the leading segments are stripped in a loop instead of blind-sliced.
/// This is what fixed the class of bug where one screen used `substring(1)`
/// and another used `substring(2)` for the same field.
///
/// Every image/video loader must go through this so the host, scheme and
/// `/Trachcare` prefix stay defined in exactly one place.
String trachcareAsset(String? relative) {
  if (relative == null || relative.isEmpty) return '';
  if (relative.startsWith('http')) return relative;
  var path = relative;
  // `../../uploads/x.png` leaves a leading slash between the two segments, so
  // both prefixes have to be peeled in one pass rather than two.
  while (path.startsWith('..') || path.startsWith('/')) {
    if (path.startsWith('..')) {
      path = path.substring(2);
    } else {
      path = path.substring(1);
    }
  }
  return '$apiBase/$path';
}
