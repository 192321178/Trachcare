<?php
// Request a 6-digit verification code (signup or password reset).
// App contract: POST {email, role, purpose} -> {success:true, message}
//
// Upload to: C:\xampp\htdocs\Trachcare\auth\request_otp.php
require_once __DIR__ . '/../db.php';

$conn = trachcare_db();
ensure_otp_table($conn);

$in      = read_json_input();
$email   = trim((string)($in['email'] ?? ''));
$role    = strtoupper(trim((string)($in['role'] ?? '')));
$purpose = strtoupper(trim((string)($in['purpose'] ?? 'SIGNUP')));

if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(['success' => false, 'message' => 'Enter a valid email address.']);
    exit;
}
if (role_table($role) === null) {
    echo json_encode(['success' => false, 'message' => 'Unknown role.']);
    exit;
}

$code    = str_pad((string)random_int(0, 999999), 6, '0', STR_PAD_LEFT);
$expires = date('Y-m-d H:i:s', time() + 300); // 5 minutes, matches the app's countdown

$stmt = $conn->prepare(
    'INSERT INTO otp_codes (email, role, purpose, code, expires_at) VALUES (?,?,?,?,?)'
);
$stmt->bind_param('sssss', $email, $role, $purpose, $code, $expires);
$stmt->execute();
$stmt->close();
$conn->close();

$sent = send_otp_mail($email, $code, $purpose);

$response = [
    'success' => true,
    'message' => $sent
        ? 'Verification code sent to your email.'
        : 'Verification code generated.',
];
// Most XAMPP installs cannot send SMTP mail, so when the message could not
// go out the code is returned for on-screen entry. Remove `dev_code` once a
// working mail transport is configured on the server.
if (!$sent) {
    $response['dev_code'] = $code;
}
echo json_encode($response);
