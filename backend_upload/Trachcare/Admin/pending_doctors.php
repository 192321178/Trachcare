<?php
// Admin → doctors waiting for approval.
// App contract: GET -> {Status:true, data:[{id, username, email, phone_number, created_at, ...}]}
// The app keys rows by `id`, so doctor_id is aliased to `id`.
//
// Upload to: C:\xampp\htdocs\Trachcare\Admin\pending_doctors.php
require_once __DIR__ . '/../db.php';

$conn = trachcare_db();
ensure_approval_columns($conn, 'doctorprofile');

$result = $conn->query(
    "SELECT *, doctor_id AS id FROM doctorprofile WHERE status = 'PENDING' ORDER BY created_at DESC"
);

$data = [];
if ($result) {
    while ($row = $result->fetch_assoc()) {
        unset($row['password']);
        $data[] = $row;
    }
}
$conn->close();

echo json_encode([
    'Status'  => true,
    'message' => 'Data fetched successfully.',
    'data'    => $data,
]);
