import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:trachcare/Api/API_funcation/json_client.dart';
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/NAppbar.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/Screens/Views/Doctor/doctorscreens/calender%20copy.dart';

/// One row of the patient chart: the JSON key the API uses, the label shown to
/// the clinician, and the group it belongs to. The same table drives both the
/// on-screen card and the exported PDF, so the two can never drift apart.
class _Field {
  const _Field(this.key, this.label);

  final String key;
  final String label;
}

const List<(String, List<_Field>)> _sections = [
  (
    'Identity',
    [
      _Field('username', 'Name'),
      _Field('age', 'Age'),
      _Field('gender', 'Gender'),
      _Field('address', 'Address'),
      _Field('appoinment', 'Next appointment'),
    ]
  ),
  (
    'Airway and surgical plan',
    [
      _Field('bmi', 'BMI'),
      _Field('diagnosis', 'Diagnosis'),
      _Field('surgery_status', 'Surgery status'),
      _Field('post_op_tracheostomy_day', 'Post-op tracheostomy day'),
      _Field('tube_name_size', 'Tube name and size'),
      _Field('indication_of_tracheostomy', 'Indication of tracheostomy'),
      _Field('comorbidities', 'Comorbidities'),
    ]
  ),
  (
    'Baseline vitals',
    [
      _Field('baseline_vitals', 'Baseline vitals'),
      _Field('respiratory_rate', 'Respiratory rate'),
      _Field('heart_rate', 'Heart rate'),
      _Field('spo2_room_air', 'SpO2 @ room air'),
    ]
  ),
  (
    'Blood work',
    [
      _Field('hemoglobin', 'Hemoglobin'),
      _Field('sr_sodium', 'Sodium (Sr.)'),
      _Field('sr_potassium', 'Potassium (Sr.)'),
      _Field('sr_calcium', 'Calcium (Sr.)'),
      _Field('sr_bicarbonate', 'Bicarbonate (Sr.)'),
      _Field('pt', 'PT'),
      _Field('aptt', 'APTT'),
      _Field('inr', 'INR'),
      _Field('platelets', 'Platelets'),
      _Field('liver_function_test', 'Liver function test'),
      _Field('renal_function_test', 'Renal function test'),
    ]
  ),
];

String _value(dynamic data, String key) {
  final raw = data is Map ? data[key] : null;
  final text = raw?.toString().trim() ?? '';
  return text.isEmpty ? 'Not recorded' : text;
}

/// The doctor's read-only view of one patient chart, with PDF export.
///
/// Admin reuses the same screen and only swaps [history] for its own calendar.
class PatientDetails extends StatefulWidget {
  final String patientId;
  final Widget Function(String patientId, String name, String imagePath)?
      history;

  const PatientDetails({super.key, required this.patientId, this.history});

  @override
  State<PatientDetails> createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetails> {
  late Future<dynamic> _chart = _load();
  bool _exporting = false;

  Future<dynamic> _load() =>
      fetchJson('$ViewPatientDetailsUrl?patient_id=${widget.patientId}');

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _chart = next);
    await next;
  }

  Future<void> _confirmDelete() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this patient?'),
        content: const Text(
            'The chart and its daily updates are removed. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final raw = await deleteJson(
          '$UpdatePatientDetailsUrl?patient_id=${widget.patientId}');
      final message = raw is Map ? raw['message']?.toString() : null;
      messenger
          .showSnackBar(SnackBar(content: Text(message ?? 'Patient removed')));
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Could not delete this patient')));
    }
  }

  Future<void> _exportPdf() async {
    final data = await _chart;
    if (data == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nothing to export yet')));
      return;
    }

    setState(() => _exporting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Patient chart — ${_value(data, 'username')}',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('Patient ID ${widget.patientId}',
                  style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 18),
              for (final (title, fields) in _sections) ...[
                pw.Text(title.toUpperCase(),
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Table(
                  border:
                      pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(3),
                  },
                  children: [
                    for (final f in fields)
                      pw.TableRow(children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(f.label,
                                style: const pw.TextStyle(fontSize: 10))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(_value(data, f.key),
                                style: const pw.TextStyle(fontSize: 10))),
                      ]),
                  ],
                ),
                pw.SizedBox(height: 14),
              ],
              pw.Text('Generated ${DateTime.now()}',
                  style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
        ),
      );

      final directory = await FilePicker.platform.getDirectoryPath();
      if (directory == null) return;

      var fileName = 'patient_chart_${widget.patientId}.pdf';
      var file = File('$directory/$fileName');
      for (var n = 1; await file.exists(); n++) {
        fileName = 'patient_chart_${widget.patientId}_$n.pdf';
        file = File('$directory/$fileName');
      }

      await file.writeAsBytes(await pdf.save());
      messenger.showSnackBar(SnackBar(content: Text('Saved ${file.path}')));
      OpenFile.open(file.path);
    } catch (e) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Could not export this chart')));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppbar(
        Title: 'Patient chart',
        subtitle: 'Read-only tracheostomy record',
        height: 92,
        onTap: () => Navigator.maybePop(context),
        export: true,
        onExportPressed: _exporting ? null : _exportPdf,
      ),
      body: FutureBuilder(
        future: _chart,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.page),
              child: Column(
                children: [
                  TcSkeleton(height: 150, radius: 20),
                  SizedBox(height: AppSpacing.xl),
                  TcSkeleton(height: 200, radius: 20),
                  SizedBox(height: AppSpacing.md),
                  TcSkeleton(height: 160, radius: 20),
                ],
              ),
            );
          }
          final data = snapshot.data;
          if (snapshot.hasError || data == null || data is! Map) {
            return TcEmptyState(
              icon: Icons.medical_information_rounded,
              title: 'This chart is unavailable',
              message: 'The patient may have been removed from your list.',
              action: TcButton(
                label: 'Try again',
                icon: Icons.refresh_rounded,
                expand: false,
                onPressed: _refresh,
              ),
            );
          }

          final name = _value(data, 'username');
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page, AppSpacing.lg, AppSpacing.page, 40),
              children: [
                TcPatientHeader(
                  name: name,
                  patientId: 'Patient ID ${widget.patientId}',
                  imagePath: trachcareAsset(data['image_path']?.toString()),
                ),
                const SizedBox(height: AppSpacing.xl),
                for (final (title, fields) in _sections) ...[
                  TcDetailGroup(
                    title: title,
                    children: [
                      for (final f in fields)
                        TcDetailRow(label: f.label, value: _value(data, f.key)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
                TcButton(
                  label: 'Daily query reports',
                  icon: Icons.calendar_month_rounded,
                  gradient: const LinearGradient(
                    colors: [AppColors.amber, Color(0xFFF7C56B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        widget.history?.call(widget.patientId, name,
                            data['image_path']?.toString() ?? '') ??
                        d_CalendarScreen(
                          patientId: widget.patientId,
                          name: name,
                          imagePath: data['image_path']?.toString() ?? '',
                        ),
                  )),
                ),
                const SizedBox(height: AppSpacing.md),
                TcButton(
                  label: 'Delete patient',
                  icon: Icons.delete_outline_rounded,
                  gradient: const LinearGradient(
                    colors: [AppColors.danger, Color(0xFFE97A6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onPressed: _confirmDelete,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
