<?php
/**
 * Patient self-registration.
 *
 * A TrachCare patient account is not free-standing: the row carries the
 * `doctor_id` that owns the chart, and the daily-report and reminder features
 * both resolve the treating clinician through it. Registration is therefore
 * gated on the treating doctor's registration number, which the clinic hands
 * out alongside the account.
 *
 * Passwords are stored the same way the existing login query expects them
 * (plain column comparison in PatientLogin.php). Moving to password_hash
 * requires migrating the existing rows and updating all three login
 * endpoints at once, so it is deliberately out of scope here.
 */
include "../../config/conn.php";

header('Content-Type: application/json');

$json = file_get_contents('php://input');
$obj  = json_decode($json, true);

function reply($status, $message) {
    echo json_encode(['Status' => $status, 'message' => $message]);
    exit;
}

foreach (['username', 'email', 'phone_number', 'password', 'doctor_reg_no'] as $field) {
    if (!isset($obj[$field]) || trim($obj[$field]) === '') {
        reply(false, "Missing required field: $field");
    }
}

$username  = trim($obj['username']);
$email     = strtolower(trim($obj['email']));
$phone     = preg_replace('/\D/', '', $obj['phone_number']);
$password  = $obj['password'];
$regNo     = trim($obj['doctor_reg_no']);

if (strlen($password) < 8) {
    reply(false, 'Password must be at least 8 characters.');
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    reply(false, 'That email address is not valid.');
}
if (strlen($phone) < 10) {
    reply(false, 'Phone number must be at least 10 digits.');
}

// Resolve the treating clinician from their registration number.
$stmt = $conn->prepare('SELECT doctor_id FROM doctorprofile WHERE doctor_reg_no = ? LIMIT 1');
$stmt->bind_param('s', $regNo);
$stmt->execute();
$doctor = $stmt->get_result()->fetch_assoc();
$stmt->close();

if (!$doctor) {
    reply(false, 'No clinician holds that registration number. Check with your care team.');
}
$doctorId = $doctor['doctor_id'];

// One account per email across both patient tables.
$stmt = $conn->prepare('SELECT patient_id FROM patientprofile WHERE email = ? LIMIT 1');
$stmt->bind_param('s', $email);
$stmt->execute();
$clash = $stmt->get_result()->fetch_assoc();
$stmt->close();

if ($clash) {
    reply(false, 'That email is already registered. Use "Forgot password?" instead.');
}

$patientId = substr(preg_replace('/[^a-z0-9]/i', '', $username), 0, 12)
           . substr((string) round(microtime(true) * 1000), -5);

$conn->begin_transaction();
try {
    $stmt = $conn->prepare(
        'INSERT INTO patientprofile
            (doctor_id, patient_id, username, email, phone_number, password, image_path)
         VALUES (?, ?, ?, ?, ?, ?, ?)'
    );
    $image = '../uploads/patient.png';
    $stmt->bind_param(
        'sssssss',
        $doctorId, $patientId, $username, $email, $phone, $password, $image
    );
    $stmt->execute();
    $stmt->close();

    // patientlogin is the credential mirror the login query reads from.
    $stmt = $conn->prepare(
        'INSERT INTO patientlogin (doctor_id, patient_id, username, password)
         VALUES (?, ?, ?, ?)'
    );
    $stmt->bind_param('ssss', $doctorId, $patientId, $email, $password);
    $stmt->execute();
    $stmt->close();

    $conn->commit();
} catch (Exception $e) {
    $conn->rollback();
    reply(false, 'We could not create that account. Please try again.');
}

reply(true, "Account created for $username. Sign in with $email.");
