<?php
// Admin self-signup — no email OTP (the app submits directly for this role),
// the row lands as PENDING until an existing admin approves it.
//
// App contract: POST {username,email,phone_number,password}
//            -> {Status:true, message}
//
// Upload to: C:\xampp\htdocs\Trachcare\auth\AdminAuth\AdminSignup.php
require_once __DIR__ . '/../../db.php';

$conn = trachcare_db();
ensure_approval_columns($conn, 'adminlogin');

$in       = read_json_input();
$username = trim((string)($in['username'] ?? ''));
$email    = trim((string)($in['email'] ?? ''));
$phone    = trim((string)($in['phone_number'] ?? ''));
$password = (string)($in['password'] ?? '');

if ($username === '' || !filter_var($email, FILTER_VALIDATE_EMAIL) || $password === '') {
    echo json_encode(['Status' => false, 'success' => false,
        'message' => 'Name, valid email and password are required.']);
    exit;
}

$dup = $conn->prepare('SELECT id FROM adminlogin WHERE username = ? OR email = ? LIMIT 1');
$dup->bind_param('ss', $username, $email);
$dup->execute();
if ($dup->get_result()->fetch_assoc()) {
    echo json_encode(['Status' => false, 'success' => false,
        'message' => 'An admin with that username or email already exists.']);
    exit;
}
$dup->close();

$doctorId  = (string)random_int(100000000, 999999999);
$imagePath = '../uploads/admin/admin.png';
$status    = 'PENDING';

$ins = $conn->prepare(
    'INSERT INTO adminlogin (doctor_id, username, doctor_reg_no, email, phone_number, password, image_path, status)
     VALUES (?,?,?,?,?,?,?,?)'
);
$ins->bind_param('ssssssss',
    $doctorId, $username, $doctorId, $email, $phone, $password, $imagePath, $status);

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
    'message' => 'Admin registration submitted successfully.',
]);
