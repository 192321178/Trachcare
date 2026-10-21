<?php
/**
 * Doctor self-registration, authorised by an administrator.
 *
 * Clinicians set the care plans every patient sees, so an account cannot be
 * opened on trust alone. The applicant supplies an authorising administrator's
 * registration number, which is checked against adminlogin before the row is
 * written. Passwords follow the same plain-column convention as DoctorLogin.php
 * so existing accounts keep working.
 */
include "../../config/conn.php";

header('Content-Type: application/json');

$json = file_get_contents('php://input');
$obj  = json_decode($json, true);

function reply($status, $message) {
    echo json_encode(['Status' => $status, 'message' => $message]);
    exit;
}

foreach (['username', 'email', 'phone_number', 'password', 'doctor_reg_no', 'admin_reg_no'] as $field) {
    if (!isset($obj[$field]) || trim($obj[$field]) === '') {
        reply(false, "Missing required field: $field");
    }
}

$username = trim($obj['username']);
$email    = strtolower(trim($obj['email']));
$phone    = preg_replace('/\D/', '', $obj['phone_number']);
$password = $obj['password'];
$regNo    = trim($obj['doctor_reg_no']);
$adminNo  = trim($obj['admin_reg_no']);

if (strlen($password) < 8) {
    reply(false, 'Password must be at least 8 characters.');
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    reply(false, 'That email address is not valid.');
}

// The authorising administrator must exist.
$stmt = $conn->prepare('SELECT id FROM adminlogin WHERE doctor_reg_no = ? LIMIT 1');
$stmt->bind_param('s', $adminNo);
$stmt->execute();
$admin = $stmt->get_result()->fetch_assoc();
$stmt->close();

if (!$admin) {
    reply(false, 'That authorising registration number is not recognised.');
}

$stmt = $conn->prepare('SELECT doctor_id FROM doctorprofile WHERE email = ? OR doctor_reg_no = ? LIMIT 1');
$stmt->bind_param('ss', $email, $regNo);
$stmt->execute();
$clash = $stmt->get_result()->fetch_assoc();
$stmt->close();

if ($clash) {
    reply(false, 'That email or registration number is already on the roster.');
}

$doctorId = substr(preg_replace('/[^a-z0-9]/i', '', $username), 0, 8) . $regNo;

$stmt = $conn->prepare(
    'INSERT INTO doctorprofile
        (doctor_id, username, doctor_reg_no, email, phone_number, password, image_path)
     VALUES (?, ?, ?, ?, ?, ?, ?)'
);
$image = '../uploads/doctor.png';
$stmt->bind_param(
    'sssssss',
    $doctorId, $username, $regNo, $email, $phone, $password, $image
);

if (!$stmt->execute()) {
    reply(false, 'We could not create that account. Please try again.');
}
$stmt->close();

reply(true, "Dr $username is on the roster. Sign in with $email.");
