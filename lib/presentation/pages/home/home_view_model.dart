import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meongnyang_square/data/dtos/feed_dto.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({FirebaseFirestore? firestore, bool oldestFirst = true, int limit = 30})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _oldestFirst = oldestFirst,
        _limit = limit;

  final FirebaseFirestore _firestore;
  final bool _oldestFirst;
  final int _limit;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  bool _disposed = false;

  bool isLoading = false;
  String? errorMessage;
  List<FeedDto> feeds = const <FeedDto>[];

  /// Firestore 구독 시작 (보통 Widget의 initState에서 한 번 호출)
  void start() {
    // 중복 구독 방지
    _subscription?.cancel();

    isLoading = true;
    errorMessage = null;
    _safeNotify();

    _subscription = _firestore
        .collection('feeds')
        .orderBy('createdAt', descending: !_oldestFirst) // createdAt 오름차순(오래된 순)=_oldestFirst true, 내림차순(최신 순)=false
        .limit(_limit)
        .snapshots()
        .listen(_onSnapshot, onError: _onError);
  }

  /// 구독 재시작 (수동 새로고침 등에서 사용)
  Future<void> refresh() async {
    stop();
    start();
  }

  /// 구독 중지 (필요 시 수동으로 호출)
  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  DateTime? _parseCreatedAt(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
    return null; // null 허용: 후처리에서 epoch로 대체
  }

  void _onSnapshot(QuerySnapshot<Map<String, dynamic>> snap) {
    try {
      final list = snap.docs.map((doc) {
        final data = doc.data();
        final createdAt = _parseCreatedAt(data['createdAt']);
        return FeedDto(
          id: doc.id,
          createdAt: createdAt,
          tag: (data['tag'] as String?)?.trim(),
          content: (data['content'] as String?)?.trim(),
          imagePath: (() {
            final raw = data['imagePath'];
            if (raw is String) {
              final v = raw.trim();
              return v.isEmpty ? null : v;
            }
            return null;
          })(),
        );
      }).toList();

      // 혹시 서버 정렬이 불안정한 경우를 위해 한 번 더 클라이언트 정렬
      list.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return _oldestFirst ? aTime.compareTo(bTime) : bTime.compareTo(aTime);
      });

      feeds = List<FeedDto>.unmodifiable(list);
      isLoading = false;
      errorMessage = null;
      _safeNotify();
    } catch (e) {
      _onError(e);
    }
  }

  void _onError(Object e) {
    isLoading = false;
    errorMessage = e.toString();
    _safeNotify();
  }

  @override
  void dispose() {
    stop(); // 구독 해제
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  bool get hasSingleItem => feeds.length == 1;
  bool get hasNoItem => feeds.isEmpty;
}