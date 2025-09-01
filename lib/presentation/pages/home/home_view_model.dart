import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meongnyang_square/data/dtos/feed_dto.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({FirebaseFirestore? firestore, bool oldestFirst = false, int limit = 2})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _oldestFirst = oldestFirst,
        _limit = limit;

  final FirebaseFirestore _firestore;
  final bool _oldestFirst;
  final int _limit;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  bool _disposed = false;

  // Paging state
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  bool _isLoadingMore = false;
  bool hasMore = true; // 더 가져올 데이터가 있는지
  final Set<String> _seenIds = <String>{}; // 중복 방지

  // Realtime for newly added documents
  DateTime? _latestCreatedAt; // 가장 최근 createdAt (oldestFirst=true면 마지막 아이템 기준)

  bool isLoading = false;
  String? errorMessage;
  List<FeedDto> feeds = const <FeedDto>[];

  /// 첫 페이지 로드 (구독 대신 페이지네이션)
  Future<void> start() async {
    // 기존 구독 해제
    _subscription?.cancel();
    _subscription = null;

    isLoading = true;
    errorMessage = null;
    hasMore = true;
    _lastDocument = null;
    _seenIds.clear();
    feeds = const <FeedDto>[];
    _safeNotify();

    await _loadInitial();
    _subscribeAllRealtime();
    // _setupRealtimeForNewAdds();
  }

  Future<void> _loadInitial() async {
    try {
      final query = _firestore
          .collection('feeds')
          .orderBy('createdAt', descending: true)
          .limit(_limit);

      final snapshot = await query.get();
      final docs = snapshot.docs;
      if (docs.isEmpty) {
        feeds = const <FeedDto>[];
        isLoading = false;
        _safeNotify();
        return;
      }

      _lastDocument = docs.last;
      final list = docs.map((doc) {
        final data = doc.data();
        _seenIds.add(doc.id);
        return FeedDto(
          id: doc.id,
          createdAt: _parseCreatedAt(data['createdAt']),
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

      // 안전을 위해 한 번 더 정렬
      list.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime); // 최신 우선
      });

      feeds = List<FeedDto>.unmodifiable(list);

      // 최신 createdAt 기준값 저장 (oldestFirst=true면 리스트의 마지막이 최신)
      if (feeds.isNotEmpty) {
        final times = feeds
            .where((e) => e.createdAt != null)
            .map((e) => e.createdAt!)
            .toList();
        if (times.isNotEmpty) {
          // newest
          times.sort();
          _latestCreatedAt = times.last;
        }
      } else {
        _latestCreatedAt = null;
      }

      isLoading = false;
      errorMessage = null;
      _safeNotify();
    } catch (e) {
      _onError(e);
    }
  }

  void _subscribeAllRealtime() {
    // 기존 구독 정리
    _subscription?.cancel();
    _subscription = null;

    final q = _firestore
        .collection('feeds')
        .orderBy('createdAt', descending: true);

    _subscription = q.snapshots().listen(
      (snap) {
        // 전체 스냅샷을 그대로 반영: 추가/수정/삭제 모두 즉시 반영
        _onSnapshot(snap);

        // 페이징 연속성 보조 정보 갱신
        if (snap.docs.isNotEmpty) {
          _lastDocument = snap.docs.last;
          _seenIds
            ..clear()
            ..addAll(snap.docs.map((d) => d.id));
        } else {
          _lastDocument = null;
          _seenIds.clear();
        }

        // 전체 구독을 쓰므로 현재 뷰에는 '추가 로드 필요 없음'
        hasMore = false;
        _safeNotify();
      },
      onError: _onError,
    );
  }

  void _setupRealtimeForNewAdds() {
    // 기존 구독 정리
    _subscription?.cancel();
    _subscription = null;

    // 기준점이 없으면 전체 구독은 부담되므로 스킵 (초기 로드가 비어있을 때는 refresh로 로드)
    if (_latestCreatedAt == null) return;

    Query<Map<String, dynamic>> q = _firestore
        .collection('feeds')
        .orderBy('createdAt', descending: true);

    // 최신 이후(더 최신)만 듣기 위해 endBefore 사용 (descending: true)
    final ts = _toTimestamp(_latestCreatedAt!);
    q = q.endBefore([ts]);

    _subscription = q.snapshots().listen(
      (snap) {
        try {
          if (snap.docChanges.isEmpty) return;
          final appended = <FeedDto>[];
          for (final change in snap.docChanges) {
            if (change.type != DocumentChangeType.added) continue;
            final doc = change.doc;
            if (_seenIds.contains(doc.id)) continue;
            final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            final item = FeedDto(
              id: doc.id,
              createdAt: _parseCreatedAt(data['createdAt']),
              tag: (data['tag'] is String) ? (data['tag'] as String).trim() : null,
              content: (data['content'] is String) ? (data['content'] as String).trim() : null,
              imagePath: (() {
                final raw = data['imagePath'];
                if (raw is String) {
                  final v = raw.trim();
                  return v.isEmpty ? null : v;
                }
                return null;
              })(),
            );
            _seenIds.add(doc.id);
            appended.add(item);
          }

          if (appended.isEmpty) return;

          // 현재 feeds에 합치고 정렬 유지
          final list = List<FeedDto>.from(feeds)..addAll(appended);
          list.sort((a, b) {
            final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime); // 최신 우선
          });
          feeds = List<FeedDto>.unmodifiable(list);

          // 최신 기준 갱신
          final times = feeds
              .where((e) => e.createdAt != null)
              .map((e) => e.createdAt!)
              .toList();
          if (times.isNotEmpty) {
            times.sort();
            _latestCreatedAt = times.last;
          }

          // 마지막 문서 갱신 (페이징 연속성 유지)
          if (feeds.isNotEmpty) {
            // 새로 들어온 것 중 가장 끝쪽 문서 스냅샷을 찾을 수 없으므로, 다음 loadMore에서 서버 기준으로 갱신됨.
            hasMore = true; // 새 문서가 생겼다면 이후 페이지가 다시 생길 수 있음
          }

          _safeNotify();
        } catch (e) {
          _onError(e);
        }
      },
      onError: _onError,
    );
  }

  /// 다음 페이지 로드 (마지막 문서 이후부터)
  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) return;
    if (_lastDocument == null) return; // 초기 데이터가 없음

    _isLoadingMore = true;
    _safeNotify();
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('feeds')
          .orderBy('createdAt', descending: true)
          .limit(_limit)
          .startAfterDocument(_lastDocument!);

      final snapshot = await query.get();
      final docs = snapshot.docs;
      if (docs.isEmpty) {
        hasMore = false;
        _isLoadingMore = false;
        _safeNotify();
        return;
      }

      _lastDocument = docs.last;

      final newItems = <FeedDto>[];
      for (final doc in docs) {
        if (_seenIds.contains(doc.id)) continue; // 중복 방지
        _seenIds.add(doc.id);
        final data = doc.data();
        newItems.add(FeedDto(
          id: doc.id,
          createdAt: _parseCreatedAt(data['createdAt']),
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
        ));
      }

      if (newItems.isNotEmpty) {
        final list = List<FeedDto>.from(feeds)..addAll(newItems);
        // 안전 정렬
        list.sort((a, b) {
          final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime); // 최신 우선
        });
        feeds = List<FeedDto>.unmodifiable(list);
        _safeNotify();
      }
    } catch (e) {
      _onError(e);
    } finally {
      _isLoadingMore = false;
      _safeNotify();
    }
  }

  /// 구독 재시작 (수동 새로고침 등에서 사용)
  Future<void> refresh() async {
    stop();
    await start();
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

  Timestamp _toTimestamp(DateTime dt) => Timestamp.fromDate(dt);

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
        return bTime.compareTo(aTime); // 최신 우선
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
  bool get isLoadingMore => _isLoadingMore;
}