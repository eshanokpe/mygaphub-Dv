import 'dart:io';
import 'package:GapHub/provider/activity_provider.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DocumentUploadField extends StatefulWidget {
  final String? documentPath;
  final ValueChanged<String?> onFileSelected;

  const DocumentUploadField({
    super.key,
    required this.documentPath,
    required this.onFileSelected,
  });

  @override
  State<DocumentUploadField> createState() => DocumentUploadFieldState();
}

class DocumentUploadFieldState extends State<DocumentUploadField> {
  bool _isImageLoading = true;
  String _fileSize = '';

  @override
  void initState() {
    super.initState();
    if (widget.documentPath != null) {
      _computeFileSize(widget.documentPath!);
    }
  }

  @override
  void didUpdateWidget(DocumentUploadField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.documentPath != widget.documentPath &&
        widget.documentPath != null) {
      setState(() {
        _isImageLoading = true;
        _fileSize = '';
      });
      _computeFileSize(widget.documentPath!);
    }
  }

  Future<void> _computeFileSize(String path) async {
    try {
      final file = File(path);
      final bytes = await file.length();
      String size;
      if (bytes < 1024) {
        size = '$bytes B';
      } else if (bytes < 1024 * 1024) {
        size = '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else {
        size = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
      if (mounted) setState(() => _fileSize = size);
    } catch (e) {
      if (mounted) setState(() => _fileSize = 'Unknown size');
    }
  }

  Future<void> _pickFile() async {
    // ✅ Set SYNCHRONOUSLY before anything — this fires before OS pauses app
    ActivityProvider.isFilePickerActive = true;
    debugPrint('📂 File picker OPENED — static flag set to true');

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['doc', 'docx', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        widget.onFileSelected(result.files.single.path);
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    } finally {
      // ✅ Reset after picker closes
      ActivityProvider.isFilePickerActive = false;
      debugPrint('📂 File picker CLOSED — static flag set to false');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: widget.documentPath != null
            ? Row(
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: _isImageLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color.fromARGB(255, 53, 79, 229),
                            ),
                          )
                        : Image(
                            image: const AssetImage('assets/images/pdf1.png'),
                            width: 30.w,
                            height: 30.w,
                          ),
                  ),
                  Builder(
                    builder: (_) {
                      if (_isImageLoading) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Future.delayed(const Duration(milliseconds: 800), () {
                            if (mounted) {
                              setState(() => _isImageLoading = false);
                            }
                          });
                        });
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isImageLoading
                            ? const _ShimmerBox(
                                width: 120,
                                height: 14,
                                radius: 4,
                              )
                            : Text(
                                widget.documentPath!.split('/').last,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                        _isImageLoading
                            ? const _ShimmerBox(
                                width: 40,
                                height: 12,
                                radius: 4,
                              )
                            : Text(
                                _fileSize.isEmpty ? '...' : _fileSize,
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onFileSelected(null),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Center(
                      child: Image.asset(
                        'assets/icons/upload.png',
                        width: 50.w, // Adjust size as needed
                        height: 50.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Text(
                    'Select File',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Only .doc, .docx, and .pdf files are supported.',
                    style: TextStyle(fontSize: 14.sp, color: Colors.black45),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
