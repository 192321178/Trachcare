<?php
// Admin → approve a pending admin account. App sends {id: doctor_id}.
// App contract: POST {id} -> {Status:true, message}
//
// Upload to: C:\xampp\htdocs\Trachcare\Admin\approve_admin.php
require_once __DIR__ . '/../db.php';

$conn = trachcare_db();
ensure_approval_columns($conn, 'adminlogin');

$in = read_json_input();
$id = trim((string)($in['id'] ?? $in['doctor_id'] ?? ''));

if ($id === '') {
    echo json_encode(['Status' => false, 'message' => 'Missing admin id.']);
    exit;
}

$stmt = $conn->prepare("UPDATE adminlogin SET status = 'APPROVED', rejection_reason = NULL WHERE doctor_id = ?");
$stmt->bind_param('s', $id);
$stmt->execute();
$ok = $stmt->affected_rows >= 0 && $stmt->errno === 0;
$stmt->close();
$conn->close();

echo json_encode($ok
    ? ['Status' => true, 'message' => 'Admin approved.']
    : ['Status' => false, 'message' => 'Admin not found.']);
