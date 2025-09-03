import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meongnyang_square/domain/entities/feed.dart';
import 'package:meongnyang_square/presentation/pages/write/write_widgets/cropper_widget.dart';
import 'package:meongnyang_square/presentation/providers.dart';
import 'write_widgets/write_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WritePage extends ConsumerStatefulWidget {
  WritePage({this.feed});
  final Feed? feed;

  @override
  ConsumerState<WritePage> createState() => _WritePageState();
}

class _WritePageState extends ConsumerState<WritePage> {
  late final TextEditingController tagController;
  late final TextEditingController contentController;

  static const int maximumLength = 200;

  final _picker = ImagePicker();

  Uint8List? _croppedImage;

  @override
  void initState() {
    super.initState();

    tagController = TextEditingController(text: widget.feed?.tag ?? "");
    contentController = TextEditingController(text: widget.feed?.content ?? "");
  }

  @override
  void dispose() {
    tagController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final writeState = ref.watch(writeViewModelProvider(widget.feed));
    final writeViewModel =
        ref.read(writeViewModelProvider(widget.feed).notifier);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          title: Image.asset('assets/images/logo_s.png', width: 40, height: 20),
          actions: [
            GestureDetector(
              onTap: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid == null) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그인이 필요합니다.')),
                  );
                  return;
                }

                String errorMessage = await writeViewModel.saveFeed(
                  imageData: _croppedImage,
                  tag: tagController.text,
                  content: contentController.text,
                  authorId: uid,
                );

                // print(writeState.errorMessage);

                if (!mounted) return;

                if (errorMessage.isEmpty) {
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Container(
                width: 50,
                height: 50,
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 25,
                ),
              ),
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
                              color: Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: _croppedImage != null
                                ? Image.memory(
                                    _croppedImage!,
                                    fit: BoxFit.cover,
                                  )
                                : widget.feed == null
                                    ? Image.asset(
                                        'assets/images/icon_photo.png',
                                        width: 35,
                                        height: 35,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: widget.feed!.imagePath,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
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
            widget.feed == null
                ? Container()
                : Positioned(
                    left: 24,
                    bottom: 24,
                    child: FloatingActionButton(
                      heroTag: 'trashFloatingActionButton',
                      backgroundColor: const Color(0xFF2C2C2C),
                      onPressed: () async {
                        //
                        final isDeleted = await writeViewModel.deleteFeed();
                        if (!mounted) return;
                        if (isDeleted) {
                          context.pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("삭제 실패"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
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
                context.pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("카메라로 촬영"),
              onTap: () {
                context.pop();
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
          ),
        ),
      );

      if (!mounted || croppedImage == null) return;
      setState(() {
        _croppedImage = croppedImage;
      });
    } catch (e) {
      print(e);
    }
  }
}
