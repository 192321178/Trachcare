<?php
// Admin → reject a pending doctor. App sends {id: doctor_id, rejection_reason}.
// App contract: POST {id, rejection_reason?} -> {Status:true, message}
//
// Upload to: C:\xampp\htdocs\Trachcare\Admin\reject_doctor.php
require_once __DIR__ . '/../db.php';

$conn = trachcare_db();
ensure_approval_columns($conn, 'doctorprofile');

$in     = read_json_input();
$id     = trim((string)($in['id'] ?? $in['doctor_id'] ?? ''));
$reason = trim((string)($in['rejection_reason'] ?? 'Rejected by administrator.'));

if ($id === '') {
    echo json_encode(['Status' => false, 'message' => 'Missing doctor id.']);
    exit;
}

$stmt = $conn->prepare("UPDATE doctorprofile SET status = 'REJECTED', rejection_reason = ? WHERE doctor_id = ?");
$stmt->bind_param('ss', $reason, $id);
$stmt->execute();
$ok = $stmt->affected_rows >= 0 && $stmt->errno === 0;
$stmt->close();
$conn->close();

echo json_encode($ok
    ? ['Status' => true, 'message' => 'Doctor rejected.']
    : ['Status' => false, 'message' => 'Doctor not found.']);
