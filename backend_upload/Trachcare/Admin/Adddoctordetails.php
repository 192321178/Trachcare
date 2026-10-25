<?php
// Admin → create a doctor account (multipart form + image upload).
// App contract: POST multipart {username, email, phone_number, password,
//   doctor_reg_no} + file image_data
//   -> {"Status":true,"msg":"New user created successfully."}
//
// Fixes over the previous version: validates required fields (blank requests
// were inserting empty doctor rows), rejects duplicate emails, uses a
// prepared statement, and stores the image under uploads/doctorimages/.
//
// Upload to: C:\xampp\htdocs\Trachcare\Admin\Adddoctordetails.php
require_once __DIR__ . '/../db.php';

$conn = trachcare_db();
ensure_approval_columns($conn, 'doctorprofile');

// Multipart request — fields arrive in $_POST, the photo in $_FILES.
$username      = trim((string)($_POST['username'] ?? ''));
$email         = trim((string)($_POST['email'] ?? ''));
$phone         = trim((string)($_POST['phone_number'] ?? ''));
$password      = (string)($_POST['password'] ?? '');
$doctorRegNo   = trim((string)($_POST['doctor_reg_no'] ?? ''));

$fail = function (string $message) {
    echo json_encode(['Status' => false, 'message' => $message]);
    exit;
};

if ($username === '' || $email === '' || $phone === ''
    || $password === '' || $doctorRegNo === '') {
    $fail('Required fields are missing.');
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $fail('Invalid email address.');
}
if (strlen($password) < 6) {
    $fail('Password must be at least 6 characters.');
}
if (!isset($_FILES['image_data']) || $_FILES['image_data']['error'] !== UPLOAD_ERR_OK) {
    $fail('Doctor photo is required.');
}

// Reject duplicate emails — a second account for the same address would
// make every login endpoint pick an arbitrary row.
$stmt = $conn->prepare('SELECT doctor_id FROM doctorprofile WHERE email = ? LIMIT 1');
$stmt->bind_param('s', $email);
$stmt->execute();
$stmt->store_result();
if ($stmt->num_rows > 0) {
    $stmt->close();
    $fail('A doctor with this email already exists.');
}
$stmt->close();

// Store the photo alongside the existing convention:
// DB keeps "../uploads/doctorimages/<file>", disk keeps it under
// Trachcare/uploads/doctorimages/.
$allowed = ['jpg' => 'jpg', 'jpeg' => 'jpg', 'png' => 'png', 'gif' => 'gif'];
$ext = strtolower(pathinfo((string)$_FILES['image_data']['name'], PATHINFO_EXTENSION));
if (!isset($allowed[$ext])) {
    $fail('Unsupported image format — use jpg, png or gif.');
}
$uploadDir = __DIR__ . '/../uploads/doctorimages/';
if (!is_dir($uploadDir) && !mkdir($uploadDir, 0775, true)) {
    $fail('Could not create the image upload folder.');
}
$filename  = uniqid() . '.' . $allowed[$ext];
$imagePath = '../uploads/doctorimages/' . $filename;
if (!move_uploaded_file($_FILES['image_data']['tmp_name'], $uploadDir . $filename)) {
    $fail('Could not save the uploaded photo.');
}

// doctor_id matches the existing digit-string style (timestamp + random tail).
$doctorId = sprintf('%d%d', (int)(microtime(true) * 1000), mt_rand(10, 99));

$stmt = $conn->prepare(
    'INSERT INTO doctorprofile
        (doctor_id, username, doctor_reg_no, email, phone_number, password, image_path, status)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
);
$status = 'APPROVED'; // admin-created doctors skip the self-serve approval queue
$stmt->bind_param(
    'ssssssss',
    $doctorId, $username, $doctorRegNo, $email, $phone, $password, $imagePath, $status
);
$ok = $stmt->execute();
$err = $stmt->error;
$stmt->close();
$conn->close();

if (!$ok) {
    @unlink($uploadDir . $filename);
    $fail('Could not create the doctor: ' . $err);
}

echo json_encode(['Status' => true, 'msg' => 'New user created successfully.']);
