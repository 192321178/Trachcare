<?php
// Doctor self-signup. Verifies the emailed 6-digit code, then creates the
// doctorprofile row with status PENDING — an admin approves it from the
// Doctor Approvals screen before the account can sign in.
//
// App contract: POST {username,email,phone_number,password,otp,doctor_reg_no?}
//            -> {Status:true, message} (app shows the pending dialog itself)
//
// Upload to: C:\xampp\htdocs\Trachcare\auth\DoctorAuth\DoctorSignup.php
require_once __DIR__ . '/../../db.php';

$conn = trachcare_db();
ensure_otp_table($conn);
ensure_approval_columns($conn, 'doctorprofile');

$in       = read_json_input();
$username = trim((string)($in['username'] ?? ''));
$email    = trim((string)($in['email'] ?? ''));
$phone    = trim((string)($in['phone_number'] ?? ''));
$password = (string)($in['password'] ?? '');
$regNo    = trim((string)($in['doctor_reg_no'] ?? ''));
$otp      = preg_replace('/\D/', '', (string)($in['otp'] ?? ''));

if ($username === '' || !filter_var($email, FILTER_VALIDATE_EMAIL) || $password === '') {
    echo json_encode(['Status' => false, 'success' => false,
        'message' => 'Name, valid email and password are required.']);
    exit;
}
if ($regNo === '') {
    // Reg number drives the doctor_id; mint one when the field was skipped.
    $regNo = (string)random_int(100000000, 999999999);
}

// Require the emailed verification code when one was issued to this address.
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
          WHERE email = ? AND role = "DOCTOR" AND purpose = "SIGNUP"
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

$dup = $conn->prepare('SELECT doctor_id FROM doctorprofile WHERE email = ? OR username = ? LIMIT 1');
$dup->bind_param('ss', $email, $username);
$dup->execute();
if ($dup->get_result()->fetch_assoc()) {
    echo json_encode(['Status' => false, 'success' => false,
        'message' => 'An account with that email or name already exists.']);
    exit;
}
$dup->close();

// doctor_id follows the existing scheme: 5 random digits + reg no.
$doctorId  = (string)random_int(10000, 99999) . $regNo;
$imagePath = '../uploads/doctor.png';
$status    = 'PENDING';

$ins = $conn->prepare(
    'INSERT INTO doctorprofile (doctor_id, username, doctor_reg_no, email, phone_number, password, image_path, status)
     VALUES (?,?,?,?,?,?,?,?)'
);
$ins->bind_param('ssssssss',
    $doctorId, $username, $regNo, $email, $phone, $password, $imagePath, $status);

if (!$ins->execute()) {
    echo json_encode(['Status' => false, 'success' => false,
        'message' => 'Registration failed. Please try again.']);
    exit;
}
$ins->close();
$conn->close();

echo json_encode([
    'Status'  => true,
    'success' => true,
    'message' => 'Doctor registration submitted successfully.',
]);
