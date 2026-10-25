<?php
// Doctor → list patients, optionally filtered by ?doctor_id=.
// Same response shape as before, but the password column is no longer
// included — the old version returned every patient's plaintext password
// to anyone who requested this URL.
//
// Upload to: C:\xampp\htdocs\Trachcare\Doctor\Patientslist.php
require_once __DIR__ . '/../db.php';

$conn = trachcare_db();
$doctorId = trim((string)($_GET['doctor_id'] ?? ''));

if ($doctorId !== '') {
    $stmt = $conn->prepare('SELECT * FROM addpatients WHERE doctor_id = ?');
    $stmt->bind_param('s', $doctorId);
    $stmt->execute();
    $result = $stmt->get_result();
} else {
    $result = $conn->query('SELECT * FROM addpatients');
}

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
