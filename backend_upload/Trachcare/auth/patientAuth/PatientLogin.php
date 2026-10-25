<?php
// Patient login — accepts either the patient's username OR email in the
// "username" field. Previously this endpoint matched only the email column,
// so typing the actual username always failed.
//
// Upload to: C:\xampp\htdocs\Trachcare\auth\patientAuth\PatientLogin.php
require_once __DIR__ . '/../../db.php';

$conn = trachcare_db();
[$login, $password] = read_login_input();

$stmt = $conn->prepare(
    'SELECT * FROM addpatients WHERE username = ? OR email = ? LIMIT 1'
);
$stmt->bind_param('ss', $login, $login);
$stmt->execute();
$row = $stmt->get_result()->fetch_assoc();
$stmt->close();
$conn->close();

if ($row && passwords_match((string)$row['password'], $password)) {
    unset($row['password']);
    respond_login(true, $row);
}
respond_login(false, null);
