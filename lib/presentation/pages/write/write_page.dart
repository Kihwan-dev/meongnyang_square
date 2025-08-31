import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meongnyang_square/presentation/pages/write/write_widgets/cropper_widget.dart';
import 'write_widgets/write_widget.dart';

import 'package:meongnyang_square/data/dtos/feed_dto.dart';
import 'package:meongnyang_square/data/data_sources/feed_remote_data_source_impl.dart';

class WritePage extends StatefulWidget {
  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController tagController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  static const int maximumLength = 200;

  final _picker = ImagePicker();

  Uint8List? _croppedImage;
  bool _isSubmitting = false;

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    tagController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          title: Image.asset('assets/images/logo_s.png', width: 40, height: 20),
          actions: [
            IconButton(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.edit, color: Colors.white, size: 24),
              tooltip: '등록',
              splashRadius: 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Text(
                    'Write',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, .6),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            _showImagePickerSheet(context);
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: _croppedImage == null
                                ? Image.asset(
                                    'assets/images/icon_photo.png',
                                    width: 35,
                                    height: 35,
                                  )
                                : Image.memory(
                                    _croppedImage!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: TagAndContentCard(
                          tagController: tagController,
                          contentController: contentController,
                          maximumLength: maximumLength,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 24,
              bottom: 24,
              child: FloatingActionButton(
                heroTag: 'trashFloatingActionButton',
                backgroundColor: const Color(0xFF2C2C2C),
                onPressed: () {},
                shape: const CircleBorder(),
                child: const ImageIcon(
                  AssetImage('assets/images/icon_trash.png'),
                  size: 25,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_isSubmitting) return; // 중복 제출 방지

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 0) 입력 검증
      final String tag = tagController.text.trim();
      final String content = contentController.text.trim();

      if (content.isEmpty) {
        _showSnack('내용을 입력해 주세요.');
        if (mounted) {
          setState(() => _isSubmitting = false);
        } else {
          _isSubmitting = false;
        }
        return;
      }
      if (content.length > maximumLength) {
        _showSnack('내용은 최대 $maximumLength자까지 입력할 수 있습니다.');
        if (mounted) {
          setState(() => _isSubmitting = false);
        } else {
          _isSubmitting = false;
        }
        return;
      }

      // 1) 이미지가 있다면 임시 파일로 저장해 업로드 경로를 확보 (DataSource가 업로드 후 URL로 치환)
      String? imagePath;
      if (_croppedImage != null) {
        final dir = await Directory.systemTemp.createTemp('mn_feed_');
        final file = File('${dir.path}/feed_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(_croppedImage!, flush: true);
        imagePath = file.path; // 로컬 경로 전달 → DataSource에서 Storage 업로드
      }

      // 2) DTO 구성
      final dto = FeedDto(
        id: null,              // 새 문서 → DataSource에서 id 세팅
        createdAt: null,       // 서버 타임스탬프 사용
        tag: tag,
        content: content,
        imagePath: imagePath,  // 없으면 null 저장
      );

      // 3) 저장 실행 (타임아웃 방지)
      final feedRemoteDataSource = FeedRemoteDataSourceImpl();
      final bool isSaved = await feedRemoteDataSource
          .upsertFeed(dto)
          .timeout(const Duration(seconds: 20), onTimeout: () => false);

      if (!isSaved) {
        throw Exception('업로드 또는 저장에 실패했습니다.');
      }

      if (!mounted) return;
      // 4) 성공 처리: 현재 페이지에서 안내 후 닫기
      _showSnack('게시글이 저장되었습니다.');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _showSnack('등록 실패: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      } else {
        _isSubmitting = false;
      }
    }
  }

  Future<dynamic> _showImagePickerSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo),
              title: Text("갤러리"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("카메라로 촬영"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? xFile = await _picker.pickImage(source: source);
      if (xFile == null) return;

      if (!mounted) return;

      // 이미지 크롭
      final croppedImage = await Navigator.of(context).push<Uint8List?>(
        MaterialPageRoute(
          builder: (context) => CropperWidget(
            file: File(xFile.path),
            aspectRatio: null,
          ),
        ),
      );

      if (!mounted || croppedImage == null) return;
      setState(() {
        _croppedImage = croppedImage;
      });
    } catch (e) {
      debugPrint('pickImage error: $e');
    }
  }
}
