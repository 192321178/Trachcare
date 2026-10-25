<?php
// Admin → reject a pending admin account. App sends {id, rejection_reason}.
// App contract: POST {id, rejection_reason?} -> {Status:true, message}
//
// Upload to: C:\xampp\htdocs\Trachcare\Admin\reject_admin.php
require_once __DIR__ . '/../db.php';

$conn = trachcare_db();
ensure_approval_columns($conn, 'adminlogin');

$in     = read_json_input();
$id     = trim((string)($in['id'] ?? $in['doctor_id'] ?? ''));
$reason = trim((string)($in['rejection_reason'] ?? 'Rejected by administrator.'));

if ($id === '') {
    echo json_encode(['Status' => false, 'message' => 'Missing admin id.']);
    exit;
}

$stmt = $conn->prepare("UPDATE adminlogin SET status = 'REJECTED', rejection_reason = ? WHERE doctor_id = ?");
$stmt->bind_param('ss', $reason, $id);
$stmt->execute();
$ok = $stmt->affected_rows >= 0 && $stmt->errno === 0;
$stmt->close();
$conn->close();

echo json_encode($ok
    ? ['Status' => true, 'message' => 'Admin rejected.']
    : ['Status' => false, 'message' => 'Admin not found.']);
