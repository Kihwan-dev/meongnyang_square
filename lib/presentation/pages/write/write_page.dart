import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meongnyang_square/presentation/pages/write/write_widgets/cropper_widget.dart';
import 'write_widgets/write_widget.dart';

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

  @override
  void dispose() {
    tagController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: () {},
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
      print(e);
    }
  }
}
