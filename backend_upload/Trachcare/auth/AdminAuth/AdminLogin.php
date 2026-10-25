<?php
// Admin login — accepts either the admin's username OR email in the
// "username" field.
//
// Upload to: C:\xampp\htdocs\Trachcare\auth\AdminAuth\AdminLogin.php
require_once __DIR__ . '/../../db.php';

$conn = trachcare_db();
[$login, $password] = read_login_input();

$stmt = $conn->prepare(
    'SELECT * FROM adminlogin WHERE username = ? OR email = ? LIMIT 1'
);
$stmt->bind_param('ss', $login, $login);
$stmt->execute();
$row = $stmt->get_result()->fetch_assoc();
$stmt->close();
$conn->close();

if ($row && passwords_match((string)$row['password'], $password)) {
    // Self-registered admins must be approved before they can sign in.
    if (($block = approval_block($row)) !== null) {
        respond_login_fail($block);
    }
    unset($row['password']);
    respond_login(true, $row);
}
respond_login(false, null);
