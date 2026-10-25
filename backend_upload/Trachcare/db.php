<?php
// ─── Shared database + auth helpers ─────────────────────────────────────────
// Upload this file to:  C:\xampp\htdocs\Trachcare\db.php
//
// If your MySQL uses different credentials, change the four lines below.
// Every uploaded endpoint includes this single file.

define('DB_HOST', '127.0.0.1');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'trachcare');

// Never let PHP warnings/notices leak into JSON responses — a stray
// "Undefined array key" notice in front of the JSON breaks the app's
// jsonDecode. Errors still go to the Apache/PHP error log.
ini_set('display_errors', '0');
error_reporting(E_ALL);

header('Content-Type: application/json');

function trachcare_db(): mysqli
{
    $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
    if ($conn->connect_error) {
        http_response_code(500);
        echo json_encode([
            'Status'  => false,
            'message' => 'Database connection failed',
        ]);
        exit;
    }
    $conn->set_charset('utf8mb4');
    return $conn;
}

/**
 * Decode the request body — the Flutter client POSTs raw JSON; fall back to
 * form fields so endpoints can also be tested from a browser/curl.
 */
function read_json_input(): array
{
    $input = json_decode(file_get_contents('php://input'), true);
    return is_array($input) ? $input : $_POST;
}

/**
 * Read the login payload the app sends.
 *
 * The Flutter client POSTs a raw JSON body {"username": ..., "password": ...}.
 * Accept form-encoded bodies too so the endpoint can be tested from a
 * browser/curl, and accept "email" as an alias for "username".
 *
 * @return array{0:string,1:string} [login, password]
 */
function read_login_input(): array
{
    $input = read_json_input();
    $login    = trim((string)($input['username'] ?? $input['email'] ?? ''));
    $password = (string)($input['password'] ?? '');
    return [$login, $password];
}

/**
 * Verify a password against the stored value.
 *
 * Rows in this database currently hold plaintext passwords compared under a
 * case-insensitive collation, so accept exact and case-insensitive matches —
 * and also password_hash() values so hashing can be rolled out later without
 * touching this file again.
 */
function passwords_match(string $stored, string $given): bool
{
    if ($stored === '') {
        return false;
    }
    return hash_equals($stored, $given)
        || strcasecmp($stored, $given) === 0
        || password_verify($given, $stored);
}

/**
 * Emit the standard login response and stop.
 * $user on success is the DB row (password already removed).
 */
function respond_login(bool $ok, ?array $user): void
{
    if ($ok) {
        echo json_encode([
            'Status'   => true,
            'message'  => 'Logined sucessfully.',
            'userInfo' => $user,
        ]);
    } else {
        echo json_encode([
            'Status'   => false,
            'message'  => 'Invalid Login Details',
            'userInfo' => 'null',
        ]);
    }
    exit;
}

/**
 * Emit a failed login response with a specific reason and stop.
 */
function respond_login_fail(string $message): void
{
    echo json_encode([
        'Status'   => false,
        'message'  => $message,
        'userInfo' => 'null',
    ]);
    exit;
}

/**
 * Accounts created through the self-serve signup endpoints land as PENDING
 * until an admin approves them. This returns an error message when the row
 * is blocked, or null when the account may log in.
 *
 * The `status` column is added by the signup endpoints; rows that pre-date it
 * default to APPROVED, so nothing here can lock out existing users.
 */
function approval_block(?array $row): ?string
{
    $status = strtoupper((string)($row['status'] ?? 'APPROVED'));
    if ($status === 'PENDING') {
        return 'Your account is waiting for admin approval.';
    }
    if ($status === 'REJECTED') {
        return 'This account was rejected. Contact the administrator.';
    }
    return null;
}

/**
 * Make sure the approval workflow columns exist on a profile table.
 * Safe to call on every request — ALTER … IF NOT EXISTS is a no-op once the
 * columns are there. Existing rows get APPROVED so nothing is locked out.
 */
function ensure_approval_columns(mysqli $conn, string $table): void
{
    if (!in_array($table, ['doctorprofile', 'adminlogin'], true)) {
        return;
    }
    @$conn->query("ALTER TABLE `$table`
        ADD COLUMN IF NOT EXISTS `status` VARCHAR(20) NOT NULL DEFAULT 'APPROVED',
        ADD COLUMN IF NOT EXISTS `rejection_reason` VARCHAR(500) DEFAULT NULL");
}

/**
 * Table + key columns for each role, used by OTP reset and signup flows.
 */
function role_table(string $role): ?array
{
    switch (strtoupper($role)) {
        case 'PATIENT':
            return ['table' => 'addpatients', 'id' => 'patient_id'];
        case 'DOCTOR':
            return ['table' => 'doctorprofile', 'id' => 'doctor_id'];
        case 'ADMIN':
            return ['table' => 'adminlogin', 'id' => 'doctor_id'];
    }
    return null;
}

/**
 * Create the otp_codes table once; every OTP endpoint calls this first.
 */
function ensure_otp_table(mysqli $conn): void
{
    $conn->query("CREATE TABLE IF NOT EXISTS `otp_codes` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `email` VARCHAR(255) NOT NULL,
        `role` VARCHAR(20) NOT NULL,
        `purpose` VARCHAR(20) NOT NULL,
        `code` VARCHAR(6) NOT NULL,
        `reset_token` VARCHAR(64) DEFAULT NULL,
        `expires_at` DATETIME NOT NULL,
        `used` TINYINT(1) NOT NULL DEFAULT 0,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX (`email`), INDEX (`reset_token`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
}

/**
 * Try to send the code by email. XAMPP boxes rarely have SMTP configured,
 * so this returns false when mail() is unavailable — callers then hand the
 * code back in the response so the flow still works (see request_otp.php).
 */
function send_otp_mail(string $email, string $code, string $purpose): bool
{
    $subject = $purpose === 'PASSWORD_RESET'
        ? 'TrachCare password reset code'
        : 'TrachCare verification code';
    $body = "Your TrachCare verification code is $code.\n\n"
          . "It expires in 5 minutes. If you did not request this, ignore this email.";
    $headers = "From: no-reply@trachcare.local\r\n";
    return @mail($email, $subject, $body, $headers);
}
