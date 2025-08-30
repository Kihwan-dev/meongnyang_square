import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class CropperWidget extends StatefulWidget {
  const CropperWidget({
    required this.file,
    this.aspectRatio, // null 이면 화면 비율 사용, 예: 1.0(정사각), 16/9 등
  });

  final File file;
  final double? aspectRatio;

  @override
  State<CropperWidget> createState() => _CropperWidgetState();
}

class _CropperWidgetState extends State<CropperWidget> {
  Uint8List? _bytes;
  late int _srcW, _srcH;
  Rect _painted = Rect.zero; // 화면에 실제로 그려진 이미지 영역
  Rect _crop = Rect.zero; // 고정 크기의 크롭 사각형(이동만)

  Offset? _dragStart;
  Rect? _cropAtDragStart;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final b = await widget.file.readAsBytes();
    final uiImg = await decodeImageFromList(b);
    setState(() {
      _bytes = b;
      _srcW = uiImg.width;
      _srcH = uiImg.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 편집'),
        actions: [
          TextButton(
            onPressed: _onConfirm,
            child: const Text('완료', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          // 1) 이미지가 화면에 contain으로 배치되는 실제 사각형 계산
          final paintedSize = _contain(
            srcW: _srcW.toDouble(),
            srcH: _srcH.toDouble(),
            dstW: c.maxWidth,
            dstH: c.maxHeight,
          );
          _painted = Rect.fromLTWH(
            (c.maxWidth - paintedSize.width) / 2,
            (c.maxHeight - paintedSize.height) / 2,
            paintedSize.width,
            paintedSize.height,
          );

          // 2) 고정 비율의 "최대" 사각형을 최초 1회 계산
          if (_crop == Rect.zero) {
            final ratio = widget.aspectRatio ?? (c.maxWidth / c.maxHeight);
            _crop = _maxRectWithAspect(_painted, ratio);
          }

          return GestureDetector(
            onPanStart: (d) {
              if (_crop.contains(d.localPosition)) {
                _dragStart = d.localPosition;
                _cropAtDragStart = _crop;
              }
            },
            onPanUpdate: (d) {
              if (_dragStart == null) return;
              final delta = d.localPosition - _dragStart!;
              var next = _cropAtDragStart!.shift(delta);
              next = _clampInside(next, _painted);
              setState(() => _crop = next);
            },
            onPanEnd: (_) {
              _dragStart = null;
              _cropAtDragStart = null;
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fromRect(
                  rect: _painted,
                  child: Image.memory(_bytes!, fit: BoxFit.contain),
                ),
                CustomPaint(
                  painter: _OverlayPainter(imageRect: _painted, cropRect: _crop),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 완료: 화면 좌표의 _crop 을 원본 픽셀 좌표로 변환 → 실제 크롭
  Future<void> _onConfirm() async {
    try {
      final scaleX = _srcW / _painted.width;
      final scaleY = _srcH / _painted.height;
      final local = _crop.shift(-_painted.topLeft);

      int x = (local.left * scaleX).round();
      int y = (local.top * scaleY).round();
      int w = (local.width * scaleX).round();
      int h = (local.height * scaleY).round();

      x = x.clamp(0, _srcW - 1);
      y = y.clamp(0, _srcH - 1);
      w = max(1, min(w, _srcW - x));
      h = max(1, min(h, _srcH - y));

      final decoded = img.decodeImage(_bytes!)!;
      final cropped = img.copyCrop(decoded, x: x, y: y, width: w, height: h);
      final out = Uint8List.fromList(img.encodeJpg(cropped, quality: 95));

      if (!mounted) return;
      Navigator.of(context).pop(out); // 크롭 결과 바이트 반환
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('편집 실패: $e')),
      );
    }
  }

  // 이미지 영역 안으로만 이동(크기 고정)
  Rect _clampInside(Rect r, Rect bounds) {
    double dx = 0, dy = 0;
    if (r.left < bounds.left) dx = bounds.left - r.left;
    if (r.right > bounds.right) dx = bounds.right - r.right;
    if (r.top < bounds.top) dy = bounds.top - r.top;
    if (r.bottom > bounds.bottom) dy = bounds.bottom - r.bottom;
    return r.shift(Offset(dx, dy));
  }

  // bounds 안에서 aspect 비율을 만족하는 "최대" 사각형
  Rect _maxRectWithAspect(Rect bounds, double aspect) {
    final bw = bounds.width, bh = bounds.height;
    final hByW = bw / aspect; // 전체 너비 사용 시 높이
    if (hByW <= bh) {
      final w = bw, h = hByW;
      return Rect.fromLTWH(bounds.left, bounds.top + (bh - h) / 2, w, h);
    } else {
      final h = bh, w = bh * aspect;
      return Rect.fromLTWH(bounds.left + (bw - w) / 2, bounds.top, w, h);
    }
  }

  Size _contain({required double srcW, required double srcH, required double dstW, required double dstH}) {
    final srcRatio = srcW / srcH;
    final dstRatio = dstW / dstH;
    if (srcRatio > dstRatio) {
      final w = dstW, h = w / srcRatio;
      return Size(w, h);
    } else {
      final h = dstH, w = h * srcRatio;
      return Size(w, h);
    }
  }
}

class _OverlayPainter extends CustomPainter {
  _OverlayPainter({required this.imageRect, required this.cropRect});
  final Rect imageRect;
  final Rect cropRect;

  @override
  void paint(Canvas canvas, Size size) {
    // 어둡게 → 크롭 영역만 투명
    final dim = Paint()..color = Colors.black.withOpacity(0.5);
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRect(cropRect)
      ..fillType = PathFillType.evenOdd;
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, dim);
    canvas.drawPath(path, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    // 테두리 + 3x3 가이드
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(cropRect, stroke);

    final guide = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1;
    final dx = cropRect.width / 3;
    final dy = cropRect.height / 3;
    for (int i = 1; i <= 2; i++) {
      canvas.drawLine(Offset(cropRect.left + dx * i, cropRect.top), Offset(cropRect.left + dx * i, cropRect.bottom), guide);
      canvas.drawLine(Offset(cropRect.left, cropRect.top + dy * i), Offset(cropRect.right, cropRect.top + dy * i), guide);
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) => old.cropRect != cropRect || old.imageRect != imageRect;
}
