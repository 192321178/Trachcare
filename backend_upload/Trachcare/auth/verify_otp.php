<?php
// Verify a 6-digit code. For PASSWORD_RESET this returns a one-time
// reset_token the app then exchanges via reset_password_with_otp.php.
// App contract: POST {email, otp, role, purpose}
//            -> {success:true, reset_token:"..."} or {success:false, message}
//
// Upload to: C:\xampp\htdocs\Trachcare\auth\verify_otp.php
require_once __DIR__ . '/../db.php';

$conn = trachcare_db();
ensure_otp_table($conn);

$in      = read_json_input();
$email   = trim((string)($in['email'] ?? ''));
$otp     = preg_replace('/\D/', '', (string)($in['otp'] ?? ''));
$role    = strtoupper(trim((string)($in['role'] ?? '')));
$purpose = strtoupper(trim((string)($in['purpose'] ?? 'PASSWORD_RESET')));

$stmt = $conn->prepare(
    'SELECT id, expires_at FROM otp_codes
      WHERE email = ? AND role = ? AND purpose = ? AND code = ? AND used = 0
      ORDER BY id DESC LIMIT 1'
);
$stmt->bind_param('ssss', $email, $role, $purpose, $otp);
$stmt->execute();
$row = $stmt->get_result()->fetch_assoc();

if (!$row) {
    echo json_encode(['success' => false, 'message' => 'Invalid code. Please try again.']);
    exit;
}
if (strtotime($row['expires_at']) < time()) {
    echo json_encode(['success' => false, 'message' => 'Code expired. Request a new one.']);
    exit;
}

$token = bin2hex(random_bytes(24));
$id    = (int)$row['id'];
$upd   = $conn->prepare('UPDATE otp_codes SET reset_token = ? WHERE id = ?');
$upd->bind_param('si', $token, $id);
$upd->execute();
$upd->close();
$conn->close();

echo json_encode([
    'success'     => true,
    'message'     => 'Code verified.',
    'reset_token' => $token,
]);
