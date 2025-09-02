import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongnyang_square/domain/entities/feed.dart';
import 'package:meongnyang_square/domain/use_cases/feed_params.dart';
import 'package:meongnyang_square/presentation/providers.dart';

class WriteState {
  WriteState({
    // this.imageData,
    this.isLoading = false,
    // this.errorMessage,
    // this.validationErrors = const {},
  });

  // final Uint8List? imageData;
  final bool isLoading;
  // final String? errorMessage;
  // final Map<String, String> validationErrors;

  WriteState copyWith({
    // Uint8List? imageData,
    bool? isLoading,
    // String? errorMessage,
    // Map<String, String>? validationErrors,
  }) {
    return WriteState(
      // imageData: imageData ?? this.imageData,
      isLoading: isLoading ?? this.isLoading,
      // errorMessage: errorMessage ?? this.errorMessage,
      // validationErrors: validationErrors ?? this.validationErrors,
    );
  }
}

class WriteViewModel extends AutoDisposeFamilyNotifier<WriteState, Feed?> {
  @override
  WriteState build(Feed? arg) {
    return WriteState(
      // imageData: null,
      isLoading: false,
      // errorMessage: null,
      // validationErrors: {},
    );
  }

  Future<String> saveFeed({
    required Uint8List? imageData,
    required String tag,
    required String content,
  }) async {
    final validationErrors = _validateInputs(tag: tag, content: content, imageData: imageData);
    if (validationErrors.isNotEmpty) {
      // state = state.copyWith(
      //   validationErrors: validationErrors,
      //   errorMessage: "validationErrors.values.first",
      // );
      return validationErrors.values.first;
    }

    state = state.copyWith(isLoading: true);

    try {
      String imagePath = "";

      if (arg == null) {
        // 새로 작성
        // 1. 이미지 저장
        imagePath = await ref.read(uploadImageUseCaseProvider).execute(imageData!);
      } else {
        // 수정
        // 1. 이미지 수정?
        if (imageData == null) {
          // 이미지 수정 x
          imagePath = arg!.imagePath;
        } else {
          // 이미지 수정 o
          // 1. 기존 이미지 삭제 : how? 이미지 path를 이용해 삭제
          await ref.read(deleteImageUseCaseProvider).execute(arg!.imagePath);
          // 2. 새로운 이미지 저장
          imagePath = await ref.read(uploadImageUseCaseProvider).execute(imageData);
        }
      }

      // 1. feedParams 객체 만들기
      final feedParams = FeedParams(
        tag: tag.trim(),
        content: content.trim(),
        imagePath: imagePath,
      );
      // 2. feedParams를 사용하여 피드 저장
      await ref.read(upsertFeedUseCaseProvider).execute(feedParams);

      state = state.copyWith(isLoading: false);

      return "";
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        //   errorMessage: "피드 저장 실패: $e",
      );
      print("피드 저장 실패 : $e");
      return "피드 저장 실패 : $e";
    }
  }

  Future<bool> deleteFeed() async {
    // id를 가지고 delete
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(deleteFeedUseCaseProvider).execute(arg!.id);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      print(e);
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Map<String, String> _validateInputs({
    required String tag,
    required String content,
    required Uint8List? imageData,
  }) {
    final errors = <String, String>{};

    if (imageData == null) {
      errors["imageData"] = "이미지를 넣어주세요.";
    }

    if (tag.trim().isEmpty) {
      errors['tag'] = '태그를 입력해주세요.';
    }

    if (content.trim().isEmpty) {
      errors['content'] = '내용을 입력해주세요.';
    }

    if (content.trim().length > 200) {
      // 최대 길이 제한
      errors['content'] = '내용은 200자를 초과할 수 없습니다.';
    }

    return errors;
  }

  // path -> Uint8List
  void setImageData(String path) {
    //
  }
}
