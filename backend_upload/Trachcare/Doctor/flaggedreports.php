<?php
// Doctor → recent daily reports for the whole panel, so the roster can flag
// who needs attention in one request. The app calls
//   GET flaggedreports.php?doctor_id=<id>&days=3
// and reads each row's clinical fields (spo2_room_air, respiratory_rate,
// heart_rate, cough_or_breathlessness, secretion_color_consistency,
// daily_dressing_done, tracheostomy_tie_changed, suctioning_done, date,
// patient_id).
//
// Upload to: C:\xampp\htdocs\Trachcare\Doctor\flaggedreports.php
require_once __DIR__ . '/../db.php';

$conn = trachcare_db();

$doctorId = trim((string)($_GET['doctor_id'] ?? ''));
$days     = max(1, min(30, (int)($_GET['days'] ?? 3)));

$data = [];
if ($doctorId !== '') {
    // INTERVAL can't take a bound parameter — $days is clamped to int above.
    $stmt = $conn->prepare(
        "SELECT * FROM daily_report
          WHERE doctor_id = ? AND date >= CURDATE() - INTERVAL $days DAY
          ORDER BY date DESC"
    );
    $stmt->bind_param('s', $doctorId);
    $stmt->execute();
    $result = $stmt->get_result();
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    $stmt->close();
}
$conn->close();

echo json_encode([
    'Status'  => true,
    'message' => 'Data fetched successfully.',
    'data'    => $data,
]);
