# TrachCare — Home Tracheostomy Care Companion

## Abstract

TrachCare is a role-based mobile healthcare application designed to support post-operative tracheostomy patients during recovery at home. It connects three roles — Patient, Doctor and Admin — through a single Flutter application backed by a PHP–MySQL REST API. Patients record structured daily health updates (vitals, tube care, oral feeds and spigotting status), watch guided exercise videos and review their report history on a calendar. Doctors register patients, review their daily reports, track spigotting progress and export a complete patient record as a PDF. Administrators manage doctor accounts, the full patient list and the video library.

The project addresses the fragmented, informal follow-up of discharged tracheostomy patients, where daily tube-care progress is typically communicated through phone calls, messaging apps or physical visits with no structured record. Its design combines a structured daily-update questionnaire, a timed spigotting schedule, education videos and a role-separated backend.

The TrachCare workflow is organized as follows:

1. The admin creates the doctor account and uploads exercise videos; the doctor registers a discharged patient with full baseline clinical details.
2. The patient submits a daily update (respiratory rate, heart rate, SpO₂, dressing, tie change, suctioning, oral feeds, tube changes and spigotting breath-hold status) from the home screen.
3. The system records the update, maintains a per-patient spigotting session schedule across the day and attaches the day's report to the patient's history.
4. The doctor reviews each patient's progress through a calendar of daily reports and the patient detail view, and can export the record as a PDF.
5. The admin manages doctors and patients and maintains the video library used by all patients.

The current report documents a Flutter-based, three-role application and its PHP–MySQL backend workflow. Push notifications, automated escalation of abnormal vitals and offline-first sync are proposed future enhancements.

**Keywords:** TrachCare, tracheostomy home care, daily vitals tracking, spigotting schedule, role-based healthcare app, Flutter, Dart, PHP, MySQL

**Developed by:** [Your Name, Reg. No.]

---

## List of Figures

| Figure | Title | Image name | Chapter |
|---|---|---|---|
| 5.1 | System architecture of TrachCare | Fig_5.1_System_Architecture.png | 5 |
| 5.2 | Database tables in phpMyAdmin | Fig_5.2_DB_Overview.png | 5 |
| 5.3 | Structure of the addpatients table | Fig_5.3_addpatients.png | 5 |
| 5.4 | Structure of the daily_report table | Fig_5.4_daily_report.png | 5 |
| 5.5 | Structure of the patientlogin / patientprofile tables | Fig_5.5_patient_profile.png | 5 |
| 5.6 | Structure of the doctorprofile / adminlogin tables | Fig_5.6_doctor_admin.png | 5 |
| 5.7 | Structure of the daily_stauts (spigotting status) table | Fig_5.7_daily_status.png | 5 |
| 5.8 | Structure of the patientvideotable | Fig_5.8_videos.png | 5 |
| 6.1 | Splash screen | Fig_6.1_Splash_Screen.jpg | 6 |
| 6.2 | Role selection (Welcome) screen | Fig_6.2_Welcome.jpg | 6 |
| 6.3 | Patient / Doctor / Admin login screens | Fig_6.3_Logins.jpg | 6 |
| 6.4 | Patient dashboard (spigotting schedule, appointment, videos) | Fig_6.4_Patient_Dashboard.jpg | 6 |
| 6.5 | Patient daily-update form | Fig_6.5_Daily_Update_Form.jpg | 6 |
| 6.6 | Patient calendar and daily report view | Fig_6.6_Calendar_Report.jpg | 6 |
| 6.7 | Patient profile and edit profile | Fig_6.7_Patient_Profile.jpg | 6 |
| 6.8 | Doctor dashboard (today's updates, add patient) | Fig_6.8_Doctor_Dashboard.jpg | 6 |
| 6.9 | Doctor patient list and add-patient form | Fig_6.9_Patient_List_Add.jpg | 6 |
| 6.10 | Doctor patient details with PDF export | Fig_6.10_Patient_Details.jpg | 6 |
| 6.11 | Doctor calendar and daily report detail | Fig_6.11_Doctor_Reports.jpg | 6 |
| 6.12 | Admin dashboard | Fig_6.12_Admin_Home.jpg | 6 |
| 6.13 | Admin doctor list and doctor details | Fig_6.13_Doctor_Management.jpg | 6 |
| 6.14 | Admin patient list and patient details | Fig_6.14_Admin_Patients.jpg | 6 |
| 6.15 | Admin video upload and video library | Fig_6.15_Video_Management.jpg | 6 |
| 6.16 | Video player (patient-facing exercise video) | Fig_6.16_Video_Player.jpg | 6 |
| 6.17 | Design system — teal theme, shared widgets | Fig_6.17_Design_System.jpg | 6 |
| 10.1 | Debug build running on Android device | Fig_10.1_Device_Run.jpg | 10 |
| 10.2 | Windows desktop build | Fig_10.2_Windows_Build.jpg | 10 |

## List of Tables

| Table | Title | Chapter |
|---|---|---|
| 2.1 | Weaknesses of informal home-care follow-up | 2 |
| 2.2 | Users and roles | 2 |
| 2.3 | Comparison of TrachCare with existing alternatives | 2 |
| 3.1 | Functional requirements | 3 |
| 3.2 | Non-functional requirements | 3 |
| 3.3 | Hardware and software requirements | 3 |
| 4.1 | Technology stack | 4 |
| 5.1 | Database tables and key fields | 5 |
| 5.2 | PHP REST API endpoints | 5 |
| 6.1 | UX design process followed | 6 |
| 6.2 | Design review findings and changes | 6 |
| 6.3 | Interview record | 6 |
| 6.4 | Changes made from feedback | 6 |
| 7.1 | Module summary | 7 |
| 8.1 | Project stages | 8 |
| 8.2 | Team roles and responsibilities | 8 |
| 8.3 | Project management tools | 8 |
| 9.1 | Test strategy | 9 |
| 9.2 | Functional test cases | 9 |
| 9.3 | Defects found | 9 |
| 9.4 | Usability test results | 9 |
| 11.1 | Security threats and controls | 11 |
| 12.1 | Future enhancements | 12 |

---

## Chapter 1 – Introduction

### 1.1 Background

A tracheostomy — a surgical opening created in the neck to provide an airway — is performed for respiratory failure, prolonged intubation, trauma or head-and-neck conditions. After discharge, patients and their caregivers must perform demanding daily care: cleaning the inner tube, changing tracheostomy ties, suctioning secretions, monitoring vital signs and gradually weaning the airway through spigotting (capping) trials. Complications after discharge are frequently detected late because follow-up depends on phone calls, personal messaging or the next physical appointment.

TrachCare proposes a structured mobile workflow in which the patient's daily care activities become a recorded clinical history. The app pairs a patient-facing daily-update form and exercise-video library with a doctor-facing review calendar and an admin-facing account and content management console.

**Problem Statement:** Existing follow-up for home tracheostomy patients is informal and unrecorded. There is no shared, structured record of daily tube care, vitals and spigotting progress, so deteriorations are noticed late and there is no audit trail of the patient's home care.

**Objectives** include developing a three-role mobile workflow for post-operative tracheostomy care; capturing structured daily vitals and care-task reports; tracking scheduled spigotting sessions through the day; delivering guided exercise videos; and giving doctors a calendar-based review with PDF export.

### 1.2 Problem Statement

- Post-operative tracheostomy patients recover at home but still require meticulous daily care, which caregivers typically report informally over calls or chat.
- Informal reporting loses clinical detail: vitals, secretion character, tube changes and breath-hold durations are described from memory or not at all.
- Doctors cannot see a day-by-day history; a missed dressing change or a failed spigotting attempt surfaces only at the next visit.
- TrachCare is proposed as a mobile-first application that turns daily tracheostomy care into structured daily updates, keeps a timed spigotting session schedule, and gives the treating doctor a calendar of daily reports plus a printable patient record.

### 1.3 Objectives

1. Provide role-based access for Patient, Doctor and Admin from a single Flutter application.
2. Capture a structured daily update — vitals, dressing, tie change, suctioning, oral feeds, tube change and spigotting/breath-hold status.
3. Track the six scheduled spigotting sessions (10 AM, 12 PM, 2 PM, 4 PM, 6 PM) with per-session completion states.
4. Deliver admin-managed exercise videos with thumbnails to patients for guided home care.
5. Give doctors a patient list, full patient record, calendar of daily reports and a PDF export of patient details.
6. Provide an admin console for doctor and patient management and video-library maintenance.

### 1.4 Scope

- Scope includes authentication for three roles, patient registration by doctors, daily-update submission, spigotting status tracking, video playback, calendar-based report review, profile management and PDF export.
- The application targets Android phones; the same codebase also builds for Windows desktop and web.
- Out of scope for this version: push notifications, automated clinical alerts on abnormal vitals, offline mode and multi-language support.

---

## Chapter 2 – Gap Analysis, Product Description, Comparison and Uniqueness (GPCU)

### 2.1 Gap Analysis

Home tracheostomy follow-up today happens through phone calls, WhatsApp messages, photographs forwarded to the treating team, or scheduled physical reviews. These methods are usable but leave no structured record and depend heavily on availability and memory.

#### 2.1.1 Existing Home-Care Follow-up Workflow

Caregivers note tube-care progress informally, send occasional photos or call the hospital when a problem appears. The doctor has no daily record between visits, and a worsening trend in vitals or spigotting tolerance is invisible until it becomes urgent.

#### 2.1.2 Weaknesses of Existing Workflow

**Table 2.1: Weaknesses of informal home-care follow-up**

| Weakness | Consequence |
|---|---|
| No structured daily record | Vitals, dressing and tube-care details are lost between visits |
| Verbal/photo-based updates | No comparable day-by-day history; easy evidence like secretion color is not recorded consistently |
| Spigotting attempts untracked | Weaning progress cannot be reviewed or timed |
| No shared record between roles | Doctor, patient and admin each keep partial information |
| No audit trail | No record of what was reported, when, or by whom |
| Depends on personal contact | A patient without a direct hospital contact has no guided follow-up |

### 2.2 Product Description

**Core Workflow:** The admin creates a doctor account; the doctor registers a discharged patient with baseline clinical details (diagnosis, surgery status, post-op tracheostomy day, tube size, baseline vitals and lab values). Each day the patient submits a structured update; the app maintains the patient's spigotting schedule and the day's report. The doctor reviews reports on a calendar and can export the record as a PDF. The admin maintains the video library and account management.

#### 2.2.1 Users and Roles

**Table 2.2: Users and roles**

| Role | Who | What they do in the app |
|---|---|---|
| Patient | Discharged tracheostomy patient or caregiver | Submits daily updates; follows the spigotting schedule; watches exercise videos; views report history on a calendar; manages profile |
| Doctor | Treating clinician at the hospital | Registers patients with full clinical baseline; views the patient list and full records; reviews daily reports by date; tracks spigotting completion; exports the patient record as a PDF; deletes records when discharged from follow-up |
| Admin | Hospital or app administrator | Creates and manages doctor accounts; views all doctors and all patients; uploads and removes exercise videos; manages their own profile |

#### 2.2.2 Core Workflow

1. Admin registers a doctor (`adminlogin`/`doctorprofile`); doctor registers a patient (`addpatients`, which also seeds the patient's login, profile and spigotting status rows via database triggers).
2. Patient submits `adddailyupdates` each day; the record lands in `daily_report` and feeds the per-day history.
3. Spigotting sessions are tracked in `daily_stauts` (status_10 … status_6) and shown as session chips on the patient dashboard.
4. Doctor opens `viewpatientdetails`, browses `Dailyupdates.php` by date, and exports the record via `export.php`-style PDF generation in-app.
5. Admin uploads videos (`addvideos.php`) into `patientvideotable`; patients stream them in the video library.

### 2.3 Comparison

#### 2.3.1 Existing Alternatives

General telehealth apps offer messaging and appointments but no structured tracheostomy care form or spigotting tracking. Personal messaging is free but unrecorded. Hospital review is thorough but infrequent.

#### 2.3.2 Comparison with Existing Alternatives

**Table 2.3: Comparison of TrachCare with existing alternatives**

| Criterion | TrachCare | Generic telehealth apps | WhatsApp / phone follow-up | Physical review only |
|---|---|---|---|---|
| Purpose-built for tracheostomy home care | Yes | No | No | Partial |
| Structured daily vitals and care-task form | Yes | No | No | At visit only |
| Spigotting session schedule | Yes | No | No | No |
| Guided exercise videos in-app | Yes | Rarely | Ad hoc links/files | Verbal instructions |
| Calendar of daily reports | Yes | Partial | No | No |
| PDF export of patient record | Yes | Partial | No | File copies |
| Cost to patient | Free | Paid / subscription | Free | Travel + visit cost |

### 2.4 Uniqueness

The proposed workflow combines a tracheostomy-specific daily questionnaire, a timed spigotting schedule, an admin-managed education video library and a doctor-facing calendar of reports with PDF export — in one mobile app. It aims to replace informal, unrecorded follow-up without removing clinical oversight.

---

## Chapter 3 – Requirements

Functional requirements describe the behavior expected from the application, including role-based login, patient registration, daily-update submission, spigotting status tracking, video playback and upload, calendar-based report review, profile management and PDF export.

### 3.1 Functional Requirements

**Table 3.1: Functional requirements**

| ID | Requirement | Role |
|---|---|---|
| FR-1 | Log in with username and password against the role-specific endpoint | All |
| FR-2 | Create a doctor account with name, registration number, email, phone, password and photo | Admin |
| FR-3 | View, edit and delete doctors; list all doctors with search | Admin |
| FR-4 | View all patients or patients filtered by doctor | Admin |
| FR-5 | Register a patient with full clinical baseline (diagnosis, tube details, vitals, labs) and photo | Doctor |
| FR-6 | View the assigned patient list with search | Doctor |
| FR-7 | View a patient's full record; export it as a PDF; delete the patient | Doctor |
| FR-8 | Review a patient's daily report by selecting a date on the calendar | Doctor, Admin |
| FR-9 | Submit a daily update: vitals + Yes/No care tasks + spigotting breath-hold details | Patient |
| FR-10 | Show the day's spigotting session chips (10 AM–6 PM) with done/pending/locked states | Patient |
| FR-11 | Browse and play exercise videos with thumbnails | Patient, Doctor |
| FR-12 | Upload a video with title, description and thumbnail | Admin |
| FR-13 | View own dashboard: greeting, next appointment, session status, video carousel | Patient |
| FR-14 | Doctor dashboard: today's patient updates (story ring), quick actions, video carousel | Doctor |
| FR-15 | View and edit profile (name, contact, password, photo) | All |
| FR-16 | Upload progress indication and success/failure toasts on submissions | System |

### 3.2 Non-Functional Requirements

**Table 3.2: Non-functional requirements**

| Area | Requirement | Target |
|---|---|---|
| Performance | Submit a daily update over 4G | ≤ 5 s |
| Performance | Video list and thumbnails load | ≤ 3 s on broadband |
| Availability | PHP API uptime | 99%+ during review hours |
| Security | HTTPS endpoints; password-protected role logins; role-separated APIs | Mandatory |
| Privacy | Patient data visible only to their doctor and admin; separate logins per role | Mandatory |
| Usability | A patient can submit a daily update in ≤ 3 screens from the dashboard | Mandatory |
| Usability | Readable on a 5-inch phone; large touch targets; Yes/No chips for care tasks | Mandatory |
| Portability | One Flutter codebase for Android, Windows desktop and web | Mandatory |
| Maintainability | Shared design system (colors, typography, widgets); one file per screen | Mandatory |

### 3.3 Hardware and Software Requirements

**Table 3.3: Hardware and software requirements**

| Item | Specification |
|---|---|
| Client devices | Android smartphone (tested on Android 13, Vivo V2058); Windows desktop for review builds |
| Development | Flutter 3.x (Dart 3.x), Android Studio / VS Code, Devin/Windsurf agent environment |
| Server | Apache + PHP on host `180.235.121.245`; REST endpoints under `/Trachcare/` |
| Database | MySQL / MariaDB database `trachcare` administered through phpMyAdmin |
| Media | Video and thumbnail files uploaded through `addvideos.php` to server storage |

---

## Chapter 4 – Technology Stack

The technology stack is selected to support a responsive, mobile-first application and a maintainable component-based interface shared by all three roles.

**Table 4.1: Technology stack**

| Layer | Technology | Role in TrachCare | Why chosen |
|---|---|---|---|
| Frontend | Flutter 3.x + Dart | All screens for the three roles; camera/gallery upload; video player; dashboards | One codebase for Android, desktop and web; Material widgets; fast iteration with hot reload |
| Layout & typography | sizer, google_fonts (IBM Plex Sans) | Percentage-based sizing and a consistent type scale | Predictable responsive layout across phone sizes |
| UI polish | animate_do, gap, modal_bottom_sheet, pull_down_button | Staggered screen entrances, spacing, sheets and menus | Polished motion and layout with little code |
| Video | media_kit, media_kit_video, video_player | Exercise video playback in patient, doctor and admin players | Reliable streaming playback on Android and desktop |
| Forms & input | image_picker, file_picker, multi_select_flutter | Profile photos, video + thumbnail upload, multi-value fields | Native pickers wrapped in one package set |
| Calendar | table_calendar | Doctor/admin daily-report calendar; patient report history | Proven calendar widget with day-selection callbacks |
| Backend | PHP REST API on Apache | Authentication, patient/doctor/admin CRUD, daily updates, status, videos | Simple JSON REST endpoints on an existing LAMP server |
| Database | MySQL (InnoDB) | `addpatients`, `daily_report`, `daily_stauts`, `patientvideotable`, profile/login tables | Relational integrity between patients, reports and sessions |
| Data & export | http, json; pdf, excel, open_file, path_provider, permission_handler | REST calls; PDF generation of the patient record; file save/open | Offline-free simple HTTP; on-device PDF built without a server round-trip |
| Feedback | toastification | Success/error toasts after submissions | Consistent unobtrusive feedback |
| Design | Custom design system (AppColors, AppText, AppTheme, app_widgets) | Teal healthcare theme, shared cards/buttons/app bars/nav | One visual language across ~40 screens |

### 4.1 Frontend: Flutter and Dart

The interface is organized by role (`patient`, `Doctor`, `Admin` view trees) over shared components (`app_widgets.dart`: `AppCard`, `PrimaryButton`, `PatientNameCard`, `VideoCard`, `YesNoSelector`, `GradientHeader`, `ModernNavBar`, etc.). A central `AppTheme` supplies the teal palette, rounded inputs and consistent shadows.

### 4.2 Application Logic and Processing

The PHP API exposes role-separated endpoints (`auth/PatientAuth`, `auth/DoctorAuth`, `auth/AdminAuth`, `Patient/*`, `Doctor/*`, `Admin/*`). Database triggers auto-provision related rows when a doctor registers a patient: `patientlogin` credentials, `patientprofile` copy, `daily_stauts` spigotting row and `spiotting_status` row are created automatically from `addpatients`.

### 4.3 Media and Project Data

Patient and staff photos live under `uploads/` on the server and are referenced by relative `image_path`. Videos and thumbnails are uploaded as multipart (`videoFile`, `thumbnailImage`) and streamed by URL. The daily report stores typed clinical fields including Yes/No enums for each care task.

### 4.4 Analysis and Review Pipeline

The doctor workflow is a read-optimized pipeline: today's updating patients surface as story rings on the dashboard; the calendar lists per-day reports; the detail view groups the record into Basic Information, Medical Details, Baseline Vitals and Lab Values; a PDF of the same record is generated in-app.

### 4.5 Deployment

The app builds for Android (`flutter run` / APK), Windows desktop (`windows/` runner) and web. The Android build used Gradle 8.14, AGP 8.11.1, Kotlin 2.2.20 and `compileSdk`/`targetSdk` 36.

---

## Chapter 5 – System Architecture and Design

**System Architecture:** TrachCare follows a classic three-tier design. The Flutter client renders role-based screens and calls JSON REST endpoints; the PHP layer authenticates and reads/writes; the MySQL database stores patients, daily reports, spigotting status, profiles, logins and the video catalogue. Database triggers provision patient-related rows at registration.

[IMAGE PLACEHOLDER — replace with TrachCare architecture figure]

*Figure 5.1: System architecture of TrachCare*

### 5.1 System Components and Data Flow

- **Client layer:** role screens + shared design system; HTTP via the `http` package; session state kept in `Datastore.dart` globals (`patient_id`, `Doctor_id`, `username`).
- **API layer:** PHP endpoints under `/Trachcare/…`; multipart uploads for images and videos.
- **Data layer:** MySQL tables plus `AFTER INSERT` triggers on `addpatients` that create `patientlogin`, `patientprofile`, `daily_stauts` and `spiotting_status` rows.

**Table 5.1: Database tables and key fields**

| Table | Key fields | Purpose |
|---|---|---|
| addpatients | doctor_id, patient_id, username, email, phone_number, password, age, address, bmi, diagnosis, surgery_status, post_op_tracheostomy_day, tube_name_size, baseline_vitals, respiratory_rate, heart_rate, spo2_room_air, indication_of_tracheostomy, comorbidities, hemoglobin, sr_sodium, sr_potassium, sr_calcium, sr_bicarbonate, pt, aptt, inr, platelets, liver_function_test, renal_function_test, image_path | Master patient record written by the doctor at registration |
| patientlogin | doctor_id, patient_id, username, password | Patient credentials (auto-created by trigger) |
| patientprofile | doctor_id, patient_id, username, email, phone_number, password, image_path | Editable patient profile copy (auto-created by trigger) |
| doctorprofile | doctor_id, username, doctor_reg_no, email, phone_number, password, image_path | Doctor account and credentials |
| adminlogin | doctor_id, username, doctor_reg_no, email, phone_number, password, image_path | Admin account (admin reuses the doctor id field) |
| daily_report | doctor_id, patient_id, username, date, respiratory_rate, heart_rate, spo2_room_air, daily_dressing_done, tracheostomy_tie_changed, suctioning_done, oral_feeds_started, changed_to_green_tube, able_to_breathe_through_nose, secretion_color_consistency, cough_or_breathlessness, breath_duration, image_path | One row per patient per day of reported care |
| daily_stauts | doctorid, patient_id, username, status_10, status_12, status_2, status_4, status_6, issues | Per-session spigotting completion flags for the day's sessions |
| spiotting_status | doctorid, patient_id, cough_or_breathlessness, breath_duration | Latest spigotting outcome for the patient |
| appoinment_table | doctorid, patient_id, date | Next appointment shown on the patient dashboard |
| medication_schedule | (schedule fields) | Medication reminders (reserved for expansion) |
| patientvideotable | s.no, title, description, Video_url, Thumbnail_url | Admin-managed exercise video catalogue |

[IMAGE PLACEHOLDER — phpMyAdmin screenshot] *Figure 5.2: Database tables*
[IMAGE PLACEHOLDER] *Figure 5.3: addpatients table structure*
[IMAGE PLACEHOLDER] *Figure 5.4: daily_report table structure*
[IMAGE PLACEHOLDER] *Figure 5.5: patientlogin / patientprofile structures*
[IMAGE PLACEHOLDER] *Figure 5.6: doctorprofile / adminlogin structures*
[IMAGE PLACEHOLDER] *Figure 5.7: daily_stauts structure*
[IMAGE PLACEHOLDER] *Figure 5.8: patientvideotable structure*

### 5.2 API Endpoints

**Table 5.2: PHP REST API endpoints**

| Method | Endpoint | Purpose | Allowed roles |
|---|---|---|---|
| POST | auth/patientAuth/PatientLogin.php | Patient login | Patient |
| POST | auth/DoctorAuth/DoctorLogin.php | Doctor login | Doctor |
| POST | auth/AdminAuth/AdminLogin.php | Admin login | Admin |
| POST | Doctor/Addpatients.php | Register a patient (multipart: photo + clinical fields) | Doctor |
| GET | Doctor/Patientslist.php | List patients for a doctor; `?doctor_id=` filter for admin view | Doctor, Admin |
| GET | Doctor/viewpatientdetails.php | Full patient record by `patient_id` | Doctor, Admin |
| GET | Doctor/Dailyupdates.php | One day's report for a patient (`patient_id`, `date`) | Doctor, Admin |
| GET | Doctor/viewstory.php | Patients who submitted updates today (dashboard stories) | Doctor |
| GET | Doctor/status.php, Doctor/updatestatus.php, Doctor/spogoting_status.php | Read/update spigotting session flags | Doctor |
| POST | Patient/adddailyupdates.php | Submit the daily update form | Patient |
| GET | Patient/getdetials.php | Patient dashboard data (name, image, appointment, session states) | Patient |
| GET | Patient/dailyreport.php | Patient's own report history by date | Patient |
| GET | Patient/status.php | Patient's spigotting session states | Patient |
| POST | Patient/editpatientprofile.php | Update patient profile (multipart) | Patient |
| POST | Admin/Adddoctordetails.php | Create a doctor account (multipart) | Admin |
| GET | Admin/Doctorlist.php | List all doctors | Admin |
| GET | Admin/doctordetails.php | Read/update a doctor's record | Admin |
| GET | Admin/admindetails.php | Admin's own record | Admin |
| GET | Admin/patientlist.php | All patients (admin view) | Admin |
| POST | Admin/addvideos.php | Upload video + thumbnail (multipart) | Admin |
| GET | Admin/export.php | Export records | Admin |

### 5.3 Daily-Care and Review Flow

1. Doctor registers the patient → triggers create login, profile, status rows automatically.
2. Patient submits the daily update → `daily_report` row + session flags in `daily_stauts`.
3. Doctor dashboard queries `viewstory.php` → shows who submitted today; doctor opens the calendar → `Dailyupdates.php` → reads that day's structured record.
4. Doctor exports the complete record to PDF in-app (`pdf` package, table format) and may delete the patient when follow-up ends.

[IMAGE PLACEHOLDER — sequence/flow figure]

---

## Chapter 6 – UX Design

**UX Process Followed:** The interface was organized around the daily-care journey for each role — patient submits a day's care in a few taps, doctor reviews by date, admin manages accounts and videos. The final design uses a modern teal healthcare theme with white cards, rounded inputs, gradient headers and a consistent bottom navigation bar.

### 6.1 UX Process Followed

**Table 6.1: UX design process followed**

| Stage | UX activity | Output |
|---|---|---|
| 1. Research | Review of existing informal follow-up; review of healthcare app patterns | Roles, workflows, comparison (Ch. 2) |
| 2. Define | Personas and task flows per role; information architecture | Three role trees and navigation |
| 3. Low fidelity | Paper wireframes of key screens | Paper UI sheets |
| 4. High fidelity | Redesigned screens with a shared teal design system | This document's screenshots |
| 5. Evaluate | Internal review of old green/peach UI → redesign to teal; usability walkthrough | Findings log (Table 6.2) |
| 6. Build | Flutter implementation; desktop + Android builds | Running app on Windows and Vivo V2058 |
| 7. Field feedback | Pilot review with the care team | Revision list |

#### 6.1.1 User Research Evidence

The principal user groups are discharged patients and caregivers (who need a simple daily form and guidance), treating doctors (who need fast per-day review) and an admin maintaining accounts and videos.

**Table 6.3: Interview record**

| ID | Interviewee role | Organisation | Date | Key quote | Design change it led to |
|---|---|---|---|---|---|
| P1 | [Caregiver of post-op patient] | [ ] | [dd/mm/2026] | ["…"] | [ ] |
| P2 | [Treating surgeon / ENT consultant] | [Saveetha Hospital] | [ ] | ["…"] | [ ] |
| P3 | [Ward nurse / tracheostomy care] | [ ] | [ ] | ["…"] | [ ] |
| P4 | [Hospital administrator] | [ ] | [ ] | ["…"] | [ ] |

### 6.2 Personas

- **Patient/caregiver:** needs large, obvious controls; the daily form uses Yes/No chips instead of typed answers where possible.
- **Doctor:** needs to scan many patients quickly — list search, status rings, calendar dates.
- **Admin:** needs management speed — grid dashboard, list/detail flows, upload form.

### 6.3 Design Principles Applied

1. One shared design system (`colors.dart`, `Tropography.dart`, `app_theme.dart`, `app_widgets.dart`) — teal healthcare palette, IBM Plex Sans, 14–22px radii, soft shadows.
2. Gradient headers and greeting banners give each role a welcoming identity.
3. Repeating patterns are shared: `AppCard`, `PatientNameCard`, `VideoCard`, `YesNoSelector`, `DetailRow`, `ModernNavBar`.
4. Statuses are color-coded — completed spigotting sessions green, current window amber, locked grey.
5. Feedback on every action — toasts, dialogs and empty states.
6. Desktop presentation uses a phone-frame so the layout always looks like the target mobile UI.

### 6.4 Screens

The prototype covers authentication (splash, welcome, three logins), patient flow (dashboard, diagnostics hub, daily-update form, calendar + report, videos, player, profile, edit profile), doctor flow (dashboard, patient list, add patient, patient details, calendar + report detail, videos, player, profile, edit profile) and admin flow (dashboard, doctor list/details/edit, add doctor, patient list/details, video upload, video library, player, profile, edit profile).

[IMAGE PLACEHOLDER] *Figure 6.1–6.6: Splash, welcome, logins, patient dashboard, daily-update form, calendar*
[IMAGE PLACEHOLDER] *Figure 6.7–6.11: Patient profile; doctor dashboard; patient list/add; patient details; doctor reports*
[IMAGE PLACEHOLDER] *Figure 6.12–6.16: Admin dashboard; doctor management; patient management; video management; video player*

### 6.5 Interface Design Screens (Labelled)

[PLACEHOLDER — insert labelled TrachCare interface screenshots here]

### 6.6 Design Review Findings and Changes

**Table 6.2: Design review findings and changes**

| # | Finding | Why it matters | Change and status |
|---|---|---|---|
| 1 | Original UI used a washed-out pastel green/peach palette with heavy shadows | Looked dated and inconsistent across roles | Replaced with a teal healthcare palette and one theme file — **Fixed** |
| 2 | Four duplicated `Namecard` widgets and three duplicated video lists/players | Inconsistent look and hard maintenance | Shared `PatientNameCard`/`VideoCard` in `app_widgets.dart` — **Fixed** |
| 3 | App stretched full-width on desktop — flat and unattractive | Desktop demo looked broken | `ResponsiveFrame` renders a rounded 430 px phone frame on wide screens — **Fixed** |
| 4 | Login/welcome images floated at fixed height without filling the hero | Looked unfinished | Full-bleed illustrations with teal scrim and overlay titles — **Fixed** |
| 5 | Daily-update form was a long flat column | Hard to scan 30+ fields | Grouped into Vitals / Daily care / Spigotting cards with Yes/No chips — **Fixed** |
| 6 | `font_awesome_flutter` v10 broke on Flutter 3.44 (`IconData` final) | Build failure | Dependency removed (unused) — **Fixed** |
| 7 | Pre-existing compile errors (`adminId`, `Admindetailsurl`, arg-count) | App could not build | Corrected to `Doctor_id` / `admindetailsUrl` — **Fixed** |

#### 6.6.1 Changes Made from Feedback (Before / After)

**Table 6.4: Changes made from feedback**

| # | Change | Feedback source | Before | After | Date released |
|---|---|---|---|---|---|
| 1 | Full-bleed hero images on welcome/login | Reviewer | Floating small image | Edge-to-edge image + scrim | [ ] |
| 2 | Phone-frame on desktop | Reviewer | Stretched UI | 430 px framed app | [ ] |
| 3 | Colour-coded admin management tiles | Reviewer | Uniform grey | Teal/violet/blue tiles | [ ] |

### 6.7 Accessibility and Platform Guidelines

Readable contrast, ≥48 dp touch targets, clear labels and visible status feedback are applied throughout. Screen-reader support and full accessibility compliance remain areas for further implementation.

---

## Chapter 7 – Implementation

**Implementation Overview:** The application is organized into role-based screen trees over a shared widget library. Dart provides the UI and state; PHP endpoints provide JSON REST services; MySQL triggers provision related rows on patient registration.

### 7.1 Project Structure

```
lib/
  Api/            Apiurl.dart (endpoint constants), Datastore.dart (session globals), API_funcation/
  components/     Appbar, NAppbar, Navbardrawer, Loginform, bottom_nav, app_widgets, sheets…
  Screens/
    AuthScreens/  Splash, Patient/Doctor/Admin logins
    started/      WelcomePage (role selection)
    Views/patient/   dashboard, videos, player, medication hub, patientscreens/ (calendar, daily updates, reports, profile, edit)
    Views/Doctor/    main screen, Bottomnavigator/ (dashboard, patients, add patient), doctorscreens/ (details, calendars, reports, videos, player, profiles)
    Views/Admin/     main page, Bottomnavigator/ (dashboard, add doctor, videos), Adminscreens/ (lists, details, edit, upload, profile)
  style/          colors.dart (AppColors + legacy aliases), Tropography.dart (AppText), app_theme.dart (AppTheme), Dimention.dart
```

### 7.2 Module Summary

**Table 7.1: Module summary**

| Module | Frontend (Flutter) | Backend (PHP/MySQL) | Key rule enforced |
|---|---|---|---|
| Authentication | `loginForm` + three login screens; session globals | `PatientLogin.php`, `DoctorLogin.php`, `AdminLogin.php` | Role-specific login endpoints |
| Patient registration | `Addpatients` grouped form (4 sections, ~30 fields, photo) | `Doctor/Addpatients.php` + triggers | Triggers create login/profile/status rows |
| Daily updates | `dailyupdates` form (vitals + Yes/No chips + spigotting) | `Patient/adddailyupdates.php` → `daily_report` | Required vitals; structured Yes/No enums |
| Spigotting schedule | Dashboard session chips + `Spigottingsheet` modal | `status.php`, `updatestatus.php`, `spogoting_status.php` → `daily_stauts` | Sessions unlocked in time order |
| Report review | `table_calendar` calendars + `dailyupdatedetails` views | `Doctor/Dailyupdates.php`, `Patient/dailyreport.php` | Read by patient_id + date |
| Patient record | `Patientsdetails` grouped detail cards | `viewpatientdetails.php` | PDF export in-app via `pdf` package |
| Video library | `VideoCard` list + media-kit player screens | `addvideos.php`, `patientvideotable` | Multipart upload; thumbnail required |
| Admin management | Doctor/patient lists, details, edit screens | `Doctorlist.php`, `doctordetails.php`, `patientlist.php`, `admindetails.php` | Delete on detail screens |

### 7.3 Navigation and Workflow State

Each role uses a `ModernNavBar` bottom navigation shell (Dashboard / Videos / Patients-or-Profile tabs). Pushed detail screens use `NormalAppbar`/`TitleAppbar` with explicit back navigation. Session state is held in `Datastore.dart` globals set at login.

### 7.4 Daily Update and Spigotting Pipeline

The patient form posts vitals and enum flags to `adddailyupdates.php`; the `daily_stauts` row carries per-session spigotting completion (`status_10` … `status_6`); the doctor's `viewstory.php` feed powers the "today's updates" rings.

### 7.5 Video and Media Handling

`media_kit` players stream MP4s served by the server; thumbnails come from `patientvideotable`. Patient/staff photos use `image_picker` + multipart POST; the PDF export composes the patient record table with the `pdf` package and saves it via `file_picker`/`open_file`.

---

## Chapter 8 – Project Management and Teamwork

### 8.1 Project Stages

**Table 8.1: Project stages**

| Stage | Weeks | Deliverable |
|---|---|---|
| 1 | [1–2] | Gap analysis, product description, comparison, uniqueness |
| 2 | [2–3] | Wireframes and draft report |
| 3 | [3–4] | High-fidelity UI design; design-system files |
| 4 | 4–8 | Working Flutter UI for all three roles |
| 5 | [8–12] | Backend integration: PHP API, MySQL, media handling |
| 6 | [13] | UI modernization pass (teal theme, phone-frame, hero images) |
| 7 | [14] | Device testing on Android; report completion |
| 8 | [15] | Presentation / demo |

### 8.2 Team Roles

**Table 8.2: Team roles and responsibilities**

| Role | Member | Responsibilities |
|---|---|---|
| Product owner | [Member, Reg. no.] | Requirements and priorities; liaison with the care team |
| Project lead | [Member, Reg. no.] | Planning, stand-ups, retrospectives |
| UX lead | [Member, Reg. no.] | Personas, wireframes, the teal design system, usability |
| Backend and integration lead | [Member, Reg. no.] | PHP API, MySQL schema and triggers, media storage |
| Mobile and release lead | [Member, Reg. no.] | Flutter build, device testing, demo data |

### 8.3 Tools

**Table 8.3: Project management tools**

| Purpose | Tool |
|---|---|
| Task board | [Trello / GitHub Projects] |
| Version control | Git |
| Design | [Figma] |
| IDE | Android Studio / VS Code / Devin |
| CI builds | `flutter build` local |

### 8.4 Team Practices

Stand-ups, sprint board updates, code review of UI refactor pull requests and shared design-system ownership.

### 8.5 Individual Accountability

Each member owned a role module (patient / doctor / admin) plus one cross-cutting area (design system, API, media).

### 8.6 A Coordination Problem and How the Team Fixed It

The original UI grew duplicated widgets and mixed palettes across roles. The fix was a shared `app_widgets.dart` + theme package and a single teal palette, applied across all ~40 screens in one pass.

### 8.7 Professional Dispositions Observed

Consistency, responsiveness to feedback, attention to clinical detail in field naming and care-task wording.

### 8.8 Team Evidence

Commit excerpts, stand-up notes and design-change log are maintained in the project repository and report tables.

### 8.9 Individual Contribution Statements

[To be filled per member]

### 8.10 Guide and Stakeholder Record

[Guide name, stage-gate sign-offs, stakeholder (hospital) feedback record]

---

## Chapter 9 – Testing and Validation

### 9.1 Test Strategy

**Table 9.1: Test strategy**

| Level | Approach |
|---|---|
| Static analysis | `flutter analyze` on every UI pass — currently 0 errors |
| Build verification | Android `assembleDebug` and Windows desktop builds |
| Device runs | Android 13 (Vivo V2058), Windows desktop |
| Workflow tests | Manual scripted walkthrough per role (Table 9.2) |
| Usability | Task-based walkthrough with the care team (Table 9.4) |

### 9.2 Functional Test Cases

**Table 9.2: Functional test cases**

| ID | Test | Expected | Result |
|---|---|---|---|
| TC-1 | Patient login (ragul / 12345678) | Lands on patient dashboard | [Pass] |
| TC-2 | Submit daily update with vitals + care tasks | Toast + entry in today's report | [ ] |
| TC-3 | Spigotting session chips | Done/pending/locked states by time | [ ] |
| TC-4 | Doctor login (varsha / 12345678) | Lands on doctor dashboard | [ ] |
| TC-5 | Doctor opens patient → PDF export | PDF saved and opened | [ ] |
| TC-6 | Doctor calendar → pick date → report | That day's fields shown | [ ] |
| TC-7 | Admin login (admin / 12345) | Admin dashboard | [ ] |
| TC-8 | Admin adds a doctor (multipart) | Doctor appears in list | [ ] |
| TC-9 | Admin uploads video + thumbnail | Video listed to all roles | [ ] |
| TC-10 | Admin deletes doctor/patient | Record removed; dialog confirms | [ ] |

### 9.3 Defects Found

**Table 9.3: Defects found**

| ID | Defect | Severity | Status |
|---|---|---|---|
| D-1 | `font_awesome_flutter` 10.x incompatible with Flutter 3.44 (`IconData` final) | Build-blocker | Fixed (dependency removed) |
| D-2 | Undefined `adminId`/`Admindetailsurl`; wrong `Doctordetails` param | Build-blocker | Fixed |
| D-3 | Pre-8.6 AGP and Gradle 8.9 too old for media_kit AGP 8.13 | Build-blocker | Fixed (AGP 8.11.1, Gradle 8.14, Kotlin 2.2.20) |
| D-4 | C: disk full blocked Dart compile | Environment | Fixed (Gradle cache + build dir on E:) |
| D-5 | `editdoctordetails` showed success dialog before async save returned | Logic | Open — dialog should await result |

### 9.4 Usability Test Results

**Table 9.4: Usability test results**

| Task | Participant | Completed | Errors | Notes |
|---|---|---|---|---|
| Submit a daily update | [ ] | [ ] | [ ] | [ ] |
| Find yesterday's report | [ ] | [ ] | [ ] | [ ] |
| Play an exercise video | [ ] | [ ] | [ ] | [ ] |

### 9.5 Performance

- Cold start → splash → welcome: ~3 s (splash timer)
- Login → dashboard: [measured] s
- Daily-update submit over Wi-Fi/4G: [measured] s
- `flutter analyze`: 0 errors; warnings are `withOpacity`/`WillPopScope` deprecations scheduled for cleanup

---

## Chapter 10 – Deployment

### 10.1 Prototype Build and Environment

Debug builds run via `flutter run`. The Android toolchain was upgraded during device deployment: Gradle 8.14, AGP 8.11.1, Kotlin 2.2.20, `compileSdk`/`targetSdk` 36.

### 10.2 Android Packaging and Testing

The app was installed and verified on a physical Android device (Vivo V2058, Android 13) over USB debugging. A Windows desktop build (`windows/` runner created with `flutter create --platforms=windows`) is used for review demos inside the 430 px phone frame.

**Table 10.1–10.2: Builds and testing tracks**

| Build | Platform | Track | Status |
|---|---|---|---|
| Debug APK | Android 13 (V2058) | Internal device test | Running |
| Debug EXE | Windows 11 | Desktop review | Running |
| Release AAB | Google Play | [To do] | Planned |

[IMAGE PLACEHOLDER] *Figure 10.1: App running on the Android device*
[IMAGE PLACEHOLDER] *Figure 10.2: Windows desktop build*

### 10.3 Release Plan

Internal device testing → closed testing → production release on Google Play with store listing and screenshots.

### 10.4 Public Launch

[To be completed with store listing and launch evidence]

---

## Chapter 11 – Security, Privacy and Responsible Use

### 11.1 Security Controls

**Table 11.1: Security threats and controls**

| Threat | Control | Status |
|---|---|---|
| Unauthorized access | Separate login endpoints per role; server checks credentials | Implemented |
| Plain-text transport | API served over HTTPS (`https://180.235.121.245/…`) | Implemented |
| Password storage | Stored in DB — **plain text in current seed data** | Open — migrate to hashing (bcrypt/Argon2) |
| File upload abuse | Multipart MIME expectations on image/video upload | Partial — add server-side type/size checks |
| Role data leakage | Role-separated endpoints; patient data under doctor_id scope | Partial — add server-side authorization checks |
| Session | Client holds id globals; no token yet | Open — move to token sessions |

### 11.2 Privacy and User Consent

Patient clinical data (vitals, photos) is stored server-side and is visible to the treating doctor and admin only. A consent step should be added to patient registration for image and data storage, noting the Digital Personal Data Protection Act, 2023.

### 11.3 Responsible Use

The app supports, not replaces, clinical judgment. Daily reports and spigotting progress inform the treating team; emergency symptoms still require direct medical contact. An "emergency contact" prompt is proposed for the patient dashboard.

---

## Chapter 12 – Conclusion

### 12.1 Limitations

- No push notifications; the doctor sees updates only on opening the dashboard.
- No automated alerts on abnormal vitals.
- Passwords are stored in plain text in the current schema — must be hashed before production.
- Offline submission is not supported; a connection is required for daily updates and video streaming.
- The `daily_stauts`/`spiotting_status` table names carry typos inherited from the existing schema.

### 12.2 Future Enhancements

**Table 12.1: Future enhancements**

| Enhancement | Value |
|---|---|
| Firebase push notifications on report submit/review | Faster doctor response |
| Abnormal-vitals flagging and escalation rules | Earlier detection of deterioration |
| Hashed passwords + token auth + consent record | Production-grade security/privacy |
| Offline-first daily form with sync | Usable on poor connectivity |
| Medication schedule module (table exists) | Complete home-care coverage |
| Multi-language UI (Tamil/English) | Accessibility for caregivers |
| Play Store / App Store release | Public availability |

### 12.3 Conclusion

TrachCare turns informal home-tracheostomy follow-up into a structured, reviewable daily record. A single Flutter codebase serves patients, doctors and administrators over a simple PHP–MySQL API, with an upgraded modern UI and verified Android and Windows builds. With authentication hardening and notification support, the same workflow can move from prototype to clinical pilot.
