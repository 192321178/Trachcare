import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:trachcare/Api/Apiurl.dart';
import 'package:trachcare/components/NAppbar.dart';
import 'package:trachcare/components/ui_kit.dart';
import 'package:trachcare/style/design_system.dart';

class VideoUploadPage extends StatefulWidget {
  const VideoUploadPage({super.key});

  @override
  State<VideoUploadPage> createState() => _VideoUploadPageState();
}

class _VideoUploadPageState extends State<VideoUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _videoPath;
  String? _thumbnailPath;
  bool _uploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Add a title and description before choosing a file')));
      return;
    }
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null) return;
    setState(() => _videoPath = result.files.single.path);
  }

  Future<void> _pickThumbnail() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;
    setState(() => _thumbnailPath = result.files.single.path);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_videoPath == null || _thumbnailPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Both a video file and a thumbnail are required')));
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _uploading = true);
    try {
      final request = http.MultipartRequest('POST', Uri.parse(Addvideos));
      request.fields['title'] = _titleController.text.trim();
      request.fields['description'] = _descriptionController.text.trim();
      request.files.add(await http.MultipartFile.fromPath(
          'videoFile', _videoPath!,
          filename: p.basename(_videoPath!)));
      request.files.add(await http.MultipartFile.fromPath(
          'thumbnailImage', _thumbnailPath!,
          filename: p.basename(_thumbnailPath!)));

      final response = await request.send();
      if (response.statusCode == 200) {
        messenger.showSnackBar(
            const SnackBar(content: Text('Published to the therapy library')));
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _videoPath = null;
          _thumbnailPath = null;
        });
      } else {
        messenger.showSnackBar(
            SnackBar(content: Text('Upload failed (${response.statusCode})')));
      }
    } catch (e) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Could not reach the upload service')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = !_uploading;

    return Scaffold(
      appBar: NormalAppbar(
        Title: 'Publish a video',
        subtitle: 'It appears in WatchZone for every patient',
        height: 92,
        onTap: () => Navigator.maybePop(context),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, AppSpacing.lg, AppSpacing.page, 40),
          children: [
            const TcSectionHeader(
              eyebrow: 'New lesson',
              title: 'Name it, then describe it',
              subtitle: 'Patients see this in the therapy library',
            ),
            const SizedBox(height: AppSpacing.lg),
            TcField(
              label: 'Title',
              controller: _titleController,
              icon: Icons.title_rounded,
              enabled: canSubmit,
              textInputAction: TextInputAction.next,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please enter a title'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TcField(
              label: 'Description',
              controller: _descriptionController,
              icon: Icons.subject_rounded,
              enabled: canSubmit,
              maxLines: 4,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please enter a description'
                  : null,
            ),
            const SizedBox(height: AppSpacing.xl),
            _PickTile(
              label: 'Video file',
              hint: 'MP4 or MOV',
              path: _videoPath,
              icon: Icons.movie_creation_rounded,
              accent: AppColors.violet,
              soft: AppColors.surfaceAlt,
              onTap: canSubmit ? _pickVideo : null,
            ),
            const SizedBox(height: AppSpacing.md),
            _PickTile(
              label: 'Thumbnail image',
              hint: 'A still that shows up in the list',
              path: _thumbnailPath,
              icon: Icons.image_rounded,
              accent: AppColors.teal,
              soft: AppColors.mintSoft,
              preview: _thumbnailPath == null
                  ? null
                  : Image.file(File(_thumbnailPath!),
                      fit: BoxFit.cover, width: 52, height: 52),
              onTap: canSubmit ? _pickThumbnail : null,
            ),
            const SizedBox(height: AppSpacing.xl),
            TcButton(
              label: _uploading ? 'Uploading…' : 'Publish video',
              icon: Icons.cloud_upload_rounded,
              onPressed: canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile({
    required this.label,
    required this.hint,
    required this.icon,
    required this.accent,
    required this.soft,
    required this.onTap,
    this.path,
    this.preview,
  });

  final String label;
  final String hint;
  final String? path;
  final IconData icon;
  final Color accent;
  final Color soft;
  final Widget? preview;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chosen = path != null && path!.isNotEmpty;

    return TcCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      color: chosen ? AppColors.mintSoft : AppColors.surface,
      shadows: const [],
      border: Border.all(
          color: chosen ? AppColors.mint : AppColors.outline,
          width: chosen ? 1.5 : 1),
      child: Row(
        children: [
          preview ??
              Container(
                width: 52,
                height: 52,
                decoration:
                    BoxDecoration(color: soft, borderRadius: AppRadius.thumb),
                child: Icon(icon, color: accent, size: 22),
              ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  chosen ? p.basename(path!) : hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(chosen ? Icons.check_circle_rounded : Icons.add_circle_outline,
              color: chosen ? AppColors.success : accent, size: 22),
        ],
      ),
    );
  }
}
