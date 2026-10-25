<?php
// Patient self-signup. Verifies the emailed 6-digit code, then creates the
// addpatients row — the existing AFTER INSERT triggers auto-provision the
// patientlogin / patientprofile / daily_stauts / spiotting_status rows.
//
// The patient is created unattached (doctor_id = '') so it shows up in the
// admin's all-patients list; a doctor can take over the chart later.
//
// App contract: POST {username,email,phone_number,password,otp}
//            -> {Status:true, message, userInfo:{patient_id,doctor_id,...}}
//
// Upload to: C:\xampp\htdocs\Trachcare\auth\patientAuth\PatientSignup.php
require_once __DIR__ . '/../../db.php';

$conn = trachcare_db();
ensure_otp_table($conn);

$in       = read_json_input();
$username = trim((string)($in['username'] ?? ''));
$email    = trim((string)($in['email'] ?? ''));
$phone    = trim((string)($in['phone_number'] ?? ''));
$password = (string)($in['password'] ?? '');
$otp      = preg_replace('/\D/', '', (string)($in['otp'] ?? ''));

if ($username === '' || !filter_var($email, FILTER_VALIDATE_EMAIL) || $password === '') {
    echo json_encode(['Status' => false, 'success' => false,
        'message' => 'Name, valid email and password are required.']);
    exit;
}

// Require the emailed verification code when one was issued to this address.
// If the OTP endpoints were never used (older flow), allow signup without it.
$issued = $conn->prepare(
    'SELECT COUNT(*) c FROM otp_codes WHERE email = ? AND purpose = "SIGNUP"'
);
$issued->bind_param('s', $email);
$issued->execute();
$needsOtp = (int)$issued->get_result()->fetch_assoc()['c'] > 0;
$issued->close();

if ($needsOtp) {
    $chk = $conn->prepare(
        'SELECT id, expires_at FROM otp_codes
          WHERE email = ? AND role = "PATIENT" AND purpose = "SIGNUP"
            AND code = ? AND used = 0
          ORDER BY id DESC LIMIT 1'
    );
    $chk->bind_param('ss', $email, $otp);
    $chk->execute();
    $row = $chk->get_result()->fetch_assoc();
    $chk->close();
    if (!$row) {
        echo json_encode(['Status' => false, 'success' => false,
            'message' => 'Invalid verification code.']);
        exit;
    }
    if (strtotime($row['expires_at']) < time()) {
        echo json_encode(['Status' => false, 'success' => false,
            'message' => 'Code expired. Request a new one.']);
        exit;
    }
    $oid = (int)$row['id'];
    $use = $conn->prepare('UPDATE otp_codes SET used = 1 WHERE id = ?');
    $use->bind_param('i', $oid);
    $use->execute();
    $use->close();
}

// Duplicate email / username guard.
$dup = $conn->prepare('SELECT patient_id FROM addpatients WHERE email = ? OR username = ? LIMIT 1');
$dup->bind_param('ss', $email, $username);
$dup->execute();
if ($dup->get_result()->fetch_assoc()) {
    echo json_encode(['Status' => false, 'success' => false,
        'message' => 'An account with that email or name already exists.']);
    exit;
}
$dup->close();

// patient_id follows the existing scheme: 5 random digits + username.
$patientId = (string)random_int(10000, 99999) . $username;
$doctorId  = ''; // unattached until a doctor takes the chart
$imagePath = '../uploads/patient.png';

$ins = $conn->prepare(
    'INSERT INTO addpatients (doctor_id, patient_id, username, email, phone_number, password, image_path)
     VALUES (?,?,?,?,?,?,?)'
);
$ins->bind_param('sssssss', $doctorId, $patientId, $username, $email, $phone, $password, $imagePath);

if (!$ins->execute()) {
    echo json_encode(['Status' => false, 'success' => false,
        'message' => 'Registration failed. Please try again.']);
    exit;
}
$ins->close();
$conn->close();

echo json_encode([
    'Status'   => true,
    'success'  => true,
    'message'  => 'Registration successful. Welcome to TrachCare.',
    'userInfo' => [
        'patient_id' => $patientId,
        'doctor_id'  => $doctorId,
        'username'   => $username,
        'email'      => $email,
    ],
]);
