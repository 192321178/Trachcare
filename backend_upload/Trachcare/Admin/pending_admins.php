<?php
// Admin → admin accounts waiting for approval.
// App contract: GET -> {Status:true, data:[{id, username, email, ...}]}
//
// Upload to: C:\xampp\htdocs\Trachcare\Admin\pending_admins.php
require_once __DIR__ . '/../db.php';

$conn = trachcare_db();
ensure_approval_columns($conn, 'adminlogin');

$result = $conn->query(
    "SELECT *, doctor_id AS id FROM adminlogin WHERE status = 'PENDING' ORDER BY id DESC"
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
