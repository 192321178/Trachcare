<?php
// Admin → list all patients.
// Same response shape as before, but the password column is no longer
// included — the old version returned every patient's plaintext password
// to anyone who requested this URL.
//
// Upload to: C:\xampp\htdocs\Trachcare\Admin\patientlist.php
require_once __DIR__ . '/../db.php';

$conn = trachcare_db();
$result = $conn->query('SELECT * FROM addpatients');

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
