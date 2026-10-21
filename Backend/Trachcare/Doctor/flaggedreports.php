<?php
/**
 * Recent daily reports for every patient a doctor follows.
 *
 * The roster screen needs one request to decide who should jump the queue;
 * fetching `dailyreport.php` per patient would cost one call per row and make
 * the list load as slowly as the panel is large.
 *
 * GET flaggedreports.php?doctor_id=…&days=7
 */
include "../config/conn.php";

header('Content-Type: application/json');

$doctorId = isset($_GET['doctor_id']) ? trim($_GET['doctor_id']) : '';
$days     = isset($_GET['days']) ? max(1, min(30, (int) $_GET['days'])) : 7;

if ($doctorId === '') {
    echo json_encode(['Status' => false, 'message' => 'doctor_id is required', 'data' => []]);
    exit;
}

// addpatients is the doctor-to-patient link the rest of the app already writes.
$sql = 'SELECT r.patient_id, r.username, r.date, r.respiratory_rate, r.heart_rate,'
     . '       r.spo2_room_air, r.daily_dressing_done, r.tracheostomy_tie_changed,'
     . '       r.suctioning_done, r.oral_feeds_started, r.changed_to_green_tube,'
     . '       r.able_to_breathe_through_nose, r.secretion_color_consistency,'
     . '       r.cough_or_breathlessness, r.breath_duration'
     . '  FROM daily_report r'
     . '  JOIN addpatients p ON p.patient_id = r.patient_id'
     . ' WHERE p.doctor_id = ?'
     . '   AND r.date >= DATE_SUB(CURDATE(), INTERVAL ? DAY)';

$stmt = $conn->prepare($sql);
$stmt->bind_param('si', $doctorId, $days);
$stmt->execute();
$result = $stmt->get_result();

$rows = [];
while ($row = $result->fetch_assoc()) {
    $rows[] = $row;
}
$stmt->close();

echo json_encode(['Status' => true, 'count' => count($rows), 'data' => $rows]);
