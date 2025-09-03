import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meongnyang_square/data/dtos/feed_dto.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({FirebaseFirestore? firestore, bool oldestFirst = false, int limit = 10})
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

  DateTime _normalizeCreatedAtForSort(DateTime? value) {
    return value ?? DateTime.now();
  }

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
    _setupRealtimeForNewAdds(); // 최신 추가만 실시간 구독 (페이징 유지)
  }

  Future<void> _loadInitial() async {
    try {
      final query = _firestore
          .collection('feeds')
          .orderBy('createdAt', descending: true)
          .orderBy('createdAt', descending: true)
          .limit(_limit);

      final snapshot = await query.get();
      final docs = snapshot.docs;
      hasMore = docs.length == _limit; // 첫 페이지 기준으로 더 불러올 수 있는지 판별
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
        final aTime = _normalizeCreatedAtForSort(a.createdAt);
        final bTime = _normalizeCreatedAtForSort(b.createdAt);
        return bTime.compareTo(aTime);
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

    final queryRealtime = _firestore
        .collection('feeds')
        .orderBy('createdAt', descending: true);

    _subscription = queryRealtime.snapshots().listen(
      (snapshot) {
        // 전체 스냅샷을 그대로 반영: 추가/수정/삭제 모두 즉시 반영
        _onSnapshot(snapshot);

        // 페이징 연속성 보조 정보 갱신
        if (snapshot.docs.isNotEmpty) {
          _lastDocument = snapshot.docs.last;
          _seenIds
            ..clear()
            ..addAll(snapshot.docs.map((doc) => doc.id));
        } else {
          _lastDocument = null;
          _seenIds.clear();
        }

        // 여기서는 hasMore를 강제로 false로 만들지 않는다 (페이징 유지)
        _safeNotify();
      },
      onError: _onError,
    );
  }

  void _setupRealtimeForNewAdds() {
    // 기존 구독 정리
    _subscription?.cancel();
    _subscription = null;

    // 1) 초기 로드가 비어있으면(최초 포스트 대기 상태), 최신 1개를 실시간으로 구독해서 첫 글이 올라오자마자 반영
    if (_latestCreatedAt == null) {
      final Query<Map<String, dynamic>> firstRealtime = _firestore
          .collection('feeds')
          .orderBy('createdAt', descending: true)
          .limit(1);

      _subscription = firstRealtime.snapshots().listen(
        (snapshot) {
          try {
            if (snapshot.docChanges.isEmpty) return;
            final appended = <FeedDto>[];
            for (final change in snapshot.docChanges) {
              if (change.type != DocumentChangeType.added) continue;
              final doc = change.doc;
              if (_seenIds.contains(doc.id)) continue;
              final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              final item = FeedDto(
                id: doc.id,
                createdAt: _parseCreatedAt(data['createdAt']) ?? DateTime.now(),
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

            final list = List<FeedDto>.from(feeds)..addAll(appended);
            list.sort((a, b) {
              final aTime = _normalizeCreatedAtForSort(a.createdAt);
              final bTime = _normalizeCreatedAtForSort(b.createdAt);
              return bTime.compareTo(aTime); // 최신 우선
            });
            feeds = List<FeedDto>.unmodifiable(list);

            // 최신 기준 갱신
            final times = feeds.where((e) => e.createdAt != null).map((e) => e.createdAt!).toList()..sort();
            if (times.isNotEmpty) {
              _latestCreatedAt = times.last;
            }

            // 새 문서가 생겼으니 이후 페이지가 존재할 수 있음
            hasMore = true;
            _safeNotify();

            // 첫 글을 받았으면 이후에는 '최신 이후만' 듣도록 재설정
            _setupRealtimeForNewAdds();
          } catch (e) {
            _onError(e);
          }
        },
        onError: _onError,
      );
      return;
    }

    // 2) 최신 이후(더 최신)만 듣기 (리스트가 이미 있을 때)
    Query<Map<String, dynamic>> queryRealtimeAdds = _firestore
        .collection('feeds')
        .orderBy('createdAt', descending: true);

    final latestTimestamp = _toTimestamp(_latestCreatedAt!);
    queryRealtimeAdds = queryRealtimeAdds.endBefore([latestTimestamp]);

    _subscription = queryRealtimeAdds.snapshots().listen(
      (snapshot) {
        try {
          if (snapshot.docChanges.isEmpty) return;
          final appended = <FeedDto>[];
          for (final change in snapshot.docChanges) {
            if (change.type != DocumentChangeType.added) continue;
            final doc = change.doc;
            if (_seenIds.contains(doc.id)) continue;
            final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            final item = FeedDto(
              id: doc.id,
              createdAt: _parseCreatedAt(data['createdAt']) ?? DateTime.now(),
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

          final list = List<FeedDto>.from(feeds)..addAll(appended);
          list.sort((a, b) {
            final aTime = _normalizeCreatedAtForSort(a.createdAt);
            final bTime = _normalizeCreatedAtForSort(b.createdAt);
            return bTime.compareTo(aTime); // 최신 우선
          });
          feeds = List<FeedDto>.unmodifiable(list);

          final times = feeds.where((e) => e.createdAt != null).map((e) => e.createdAt!).toList()..sort();
          if (times.isNotEmpty) {
            _latestCreatedAt = times.last;
          }

          hasMore = true; // 새 문서가 생겼다면 이후 페이지가 다시 생길 수 있음
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
          .orderBy('createdAt', descending: true)
          .limit(_limit)
          .startAfterDocument(_lastDocument!);

      final snapshot = await query.get();
      final docs = snapshot.docs;
      hasMore = docs.length == _limit; // 이번 페이지로 더 있음 여부 갱신
      if (docs.isEmpty) {
        _isLoadingMore = false;
        _safeNotify();
        return;
      }

      _lastDocument = docs.last;

      final newItems = <FeedDto>[];
      for (final doc in docs) {
        if (_seenIds.contains(doc.id)) continue; // 중복 방지
        _seenIds.add(doc.id);
        final Map<String, dynamic> data = doc.data();
        newItems.add(FeedDto(
          id: doc.id,
          createdAt: _parseCreatedAt(data['createdAt']),
          tag: (data['tag'] is String) ? (data['tag'] as String).trim() : null,
          content: (data['content'] is String) ? (data['content'] as String).trim() : null,
          imagePath: (() {
            final raw = data['imagePath'];
            if (raw is String) {
              final value = raw.trim();
              return value.isEmpty ? null : value;
            }
            return null;
          })(),
        ));
      }

      if (newItems.isNotEmpty) {
        final list = List<FeedDto>.from(feeds)..addAll(newItems);
        // 안전 정렬
        list.sort((a, b) {
          final aTime = _normalizeCreatedAtForSort(a.createdAt);
          final bTime = _normalizeCreatedAtForSort(b.createdAt);
          return bTime.compareTo(aTime);
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
    if (raw is int) {
      final bool isSeconds = raw.toString().length == 10;
      return DateTime.fromMillisecondsSinceEpoch(isSeconds ? raw * 1000 : raw);
    }
    if (raw is String && raw.isNotEmpty) {
      final int? asInt = int.tryParse(raw);
      if (asInt != null) {
        final bool isSeconds = raw.length == 10;
        return DateTime.fromMillisecondsSinceEpoch(isSeconds ? asInt * 1000 : asInt);
      }
      return DateTime.tryParse(raw);
    }
    return null;
  }

  Timestamp _toTimestamp(DateTime dt) => Timestamp.fromDate(dt);

  void _onSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    try {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        final createdAt = _parseCreatedAt(data['createdAt']) ?? DateTime.now();
        return FeedDto(
          id: doc.id,
          createdAt: createdAt,
          tag: (data['tag'] is String) ? (data['tag'] as String).trim() : null,
          content: (data['content'] is String) ? (data['content'] as String).trim() : null,
          imagePath: (() {
            final raw = data['imagePath'];
            if (raw is String) {
              final value = raw.trim();
              return value.isEmpty ? null : value;
            }
            return null;
          })(),
        );
      }).toList();

      // 혹시 서버 정렬이 불안정한 경우를 위해 한 번 더 클라이언트 정렬
      list.sort((a, b) {
        final aTime = _normalizeCreatedAtForSort(a.createdAt);
        final bTime = _normalizeCreatedAtForSort(b.createdAt);
        return bTime.compareTo(aTime);
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