<?php
/**
 * Password recovery for all three roles.
 *
 * Proof of identity is "the email AND the phone number already on the record",
 * which is the only second factor the schema can offer today. The clinic server
 * has no SMTP or SMS gateway configured, so the temporary password is returned
 * to the app and displayed once instead of being mailed. Wire up a mailer and
 * this becomes a one-line change; until then, do not treat it as a channel you
 * can send secrets over in public.
 */
include "../config/conn.php";

header('Content-Type: application/json');

$json = file_get_contents('php://input');
$obj  = json_decode($json, true);

function reply($status, $message, $extra = []) {
    echo json_encode(array_merge(['Status' => $status, 'message' => $message], $extra));
    exit;
}

$role    = strtolower(trim($obj['role'] ?? ''));
$email   = strtolower(trim($obj['email'] ?? ''));
$phone   = preg_replace('/\D/', '', $obj['phone_number'] ?? '');

// Digits only, because the seeded rows carry numbers with stray spaces.
function digits($value) {
    return preg_replace('/\D/', '', (string) $value);
}

$tables = [
    'patient' => ['table' => 'patientprofile', 'phone' => 'phone_number'],
    'doctor'  => ['table' => 'doctorprofile',  'phone' => 'phone_number'],
    'admin'   => ['table' => 'adminlogin',     'phone' => 'phone_number'],
];

if (!isset($tables[$role])) {
    reply(false, 'Unknown role.');
}
if ($email === '' || $phone === '') {
    reply(false, 'Enter both the email and phone number on file.');
}

$table = $tables[$role]['table'];

$stmt = $conn->prepare("SELECT * FROM `$table` WHERE email = ? LIMIT 1");
$stmt->bind_param('s', $email);
$stmt->execute();
$row = $stmt->get_result()->fetch_assoc();
$stmt->close();

if (!$row || digits($row[$tables[$role]['phone']]) !== $phone) {
    reply(false, 'Those details do not match a TrachCare record.');
}

// Ambiguous but typeable: no 0/O, 1/I/l.
$alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
$temp = '';
for ($i = 0; $i < 8; $i++) {
    $temp .= $alphabet[random_int(0, strlen($alphabet) - 1)];
}

$stmt = $conn->prepare("UPDATE `$table` SET password = ? WHERE email = ?");
$stmt->bind_param('ss', $temp, $email);
if (!$stmt->execute()) {
    reply(false, 'We could not reset that password. Try again.');
}
$stmt->close();

// patientlogin mirrors patient credentials and is what the login query reads.
if ($role === 'patient') {
    $stmt = $conn->prepare('UPDATE patientlogin SET password = ? WHERE username = ? OR username = ?');
    $username = $row['username'] ?? '';
    $stmt->bind_param('sss', $temp, $email, $username);
    $stmt->execute();
    $stmt->close();
}

reply(
    true,
    'Identity confirmed. Use this temporary password, then change it from your profile.',
    ['temporary_password' => $temp]
);
