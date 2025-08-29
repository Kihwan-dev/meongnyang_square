import 'package:flutter/material.dart';
import 'write_widgets/write_widget.dart';

class WritePage extends StatefulWidget {
  const WritePage({super.key});

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController tagController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  static const int maximumLength = 200;

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
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Image.asset('assets/images/icon_back.png',
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          centerTitle: true,
          title: Image.asset('assets/images/logo_s.png', width: 40, height: 20),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Image.asset('assets/images/icon_pencil.png',),
                onPressed: () {},
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Text(
                    'Write',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, .6),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/icon_photo.png',
                            width: 35,
                            height: 35,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
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
}