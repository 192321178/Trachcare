<?php
// Legacy single-step reset — the app only calls this when the OTP endpoints
// are unreachable. It issues a PASSWORD_RESET code the user can then enter in
// the forgot-password OTP step, so the response stays honest.
//
// App contract: POST {role: lowercase, email} -> {Status:true/false, message}
//
// Upload to: C:\xampp\htdocs\Trachcare\auth\ResetPassword.php
require_once __DIR__ . '/../db.php';

$conn = trachcare_db();
ensure_otp_table($conn);

$in    = read_json_input();
$email = trim((string)($in['email'] ?? ''));
$role  = strtoupper(trim((string)($in['role'] ?? '')));

if ($email === '' || role_table($role) === null) {
    echo json_encode(['Status' => false, 'message' => 'We could not verify that email address.']);
    exit;
}

$code    = str_pad((string)random_int(0, 999999), 6, '0', STR_PAD_LEFT);
$expires = date('Y-m-d H:i:s', time() + 300);
$purpose = 'PASSWORD_RESET';

$stmt = $conn->prepare(
    'INSERT INTO otp_codes (email, role, purpose, code, expires_at) VALUES (?,?,?,?,?)'
);
$stmt->bind_param('sssss', $email, $role, $purpose, $code, $expires);
$stmt->execute();
$stmt->close();
$conn->close();

$sent = send_otp_mail($email, $code, 'PASSWORD_RESET');

$out = [
    'Status'  => true,
    'message' => $sent
        ? 'A 6-digit reset code was sent to your email.'
        : 'A 6-digit reset code was generated — enter it in the reset screen.',
];
if (!$sent) {
    $out['dev_code'] = $code;
}
echo json_encode($out);
