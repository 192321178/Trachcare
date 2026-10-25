<?php
// Exchange a verified reset_token for a new password.
// App contract: POST {email, role, reset_token, new_password}
//            -> {success:true} or {success:false, message}
//
// Upload to: C:\xampp\htdocs\Trachcare\auth\reset_password_with_otp.php
require_once __DIR__ . '/../db.php';

$conn = trachcare_db();
ensure_otp_table($conn);

$in      = read_json_input();
$email   = trim((string)($in['email'] ?? ''));
$role    = strtoupper(trim((string)($in['role'] ?? '')));
$token   = (string)($in['reset_token'] ?? '');
$newPass = (string)($in['new_password'] ?? '');

if (strlen($newPass) < 8) {
    echo json_encode(['success' => false, 'message' => 'Use at least 8 characters.']);
    exit;
}
$target = role_table($role);
if ($target === null) {
    echo json_encode(['success' => false, 'message' => 'Unknown role.']);
    exit;
}

// The token must belong to a recent, verified PASSWORD_RESET code.
$stmt = $conn->prepare(
    'SELECT id, expires_at FROM otp_codes
      WHERE email = ? AND role = ? AND purpose = "PASSWORD_RESET"
        AND reset_token = ? AND used = 0
      ORDER BY id DESC LIMIT 1'
);
$stmt->bind_param('sss', $email, $role, $token);
$stmt->execute();
$row = $stmt->get_result()->fetch_assoc();
$stmt->close();

if (!$row || strtotime($row['expires_at']) < time()) {
    echo json_encode(['success' => false, 'message' => 'Reset session expired. Start again.']);
    exit;
}

// Burn the token so it cannot be replayed.
$id  = (int)$row['id'];
$upd = $conn->prepare('UPDATE otp_codes SET used = 1 WHERE id = ?');
$upd->bind_param('i', $id);
$upd->execute();
$upd->close();

// Update the credential table for the role.
$upd = $conn->prepare(
    "UPDATE `{$target['table']}` SET password = ? WHERE email = ?"
);
$upd->bind_param('ss', $newPass, $email);
$upd->execute();
$changed = $upd->affected_rows > 0;
$upd->close();

// Keep the auto-provisioned patient copies in step.
if ($target['table'] === 'addpatients') {
    $sync = $conn->prepare('UPDATE patientlogin p
        JOIN addpatients a ON a.patient_id = p.patient_id
        SET p.password = ? WHERE a.email = ?');
    $sync->bind_param('ss', $newPass, $email);
    $sync->execute();
    $sync->close();

    $sync = $conn->prepare('UPDATE patientprofile p
        JOIN addpatients a ON a.patient_id = p.patient_id
        SET p.password = ? WHERE a.email = ?');
    $sync->bind_param('ss', $newPass, $email);
    $sync->execute();
    $sync->close();
}
$conn->close();

echo json_encode($changed
    ? ['success' => true, 'message' => 'Password updated.']
    : ['success' => false, 'message' => 'No account found for that email.']);
