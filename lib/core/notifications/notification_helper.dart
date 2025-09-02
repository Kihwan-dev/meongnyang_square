import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// 백그라운드에서 호출될 함수
// Dart 컴파일러는 릴리즈 모드에서 AOT 컴파일 시 호출되지 않는 최상위 함수 제거함
// 이 함수는 실제로 백그라운드에서 실행되기 때문에 런타임 코드 내에서는 호출이 안되는것처럼 인식
// @pragma('vm:entry-point') 추가하면 Dart 컴파일러가 이 함수 제거 안함
// https://github.com/dart-lang/sdk/blob/master/runtime/docs/compiler/aot/entry_point_pragma.md
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // 백그라운드에서 푸시알림 클릭했을 때 실행할 로직 작성
}

class NotificationHelper {
  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 안드로이드 초기화 설정
    // @mipmap/ic_launcher => android/src/main/mipmap/ic_launcher.png
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS에서 알림 초기화 설정
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      // 알림 알림 권한을 요청
      requestAlertPermission: true,
      // 배지 권한을 요청
      requestBadgePermission: true,
      // 사운드 권한을 요청
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // 초기화
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (noti) {
        // 포그라운드에서 알림 터치했을 때
        print(noti.payload);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // 안드로이드 33 부터는 권한 요청해줘야함!
    await _requestAndroidPermissionForOver33();
  }

  static Future<bool?> _requestAndroidPermissionForOver33() async {
    final androidNotificationPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await androidNotificationPlugin?.requestNotificationsPermission();
  }

  static Future<void> show(String title, String content) async {
    return flutterLocalNotificationsPlugin.show(
      0, // 알림 ID (중복된 알림을 관리하기 위한 고유 ID)
      title, // 알림 제목
      content, // 알림 내용
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test channel id', // 안드로이드 8.0 이상에서 알림을 그룹화하고 분류하는 용도. 고유한 값으로 설정
          'General Notifications', // 알림 채널 이름. 사용자가 설정에서 채널별로 알림 끄고 킬 수 있슴
          importance: Importance.high, // 알림의 우선순위
          playSound: true, // 알림 소리 재생 여부
        ),
        iOS: DarwinNotificationDetails(
          presentSound: true, // 알림 소리 재생 여부
          presentAlert: true, // 알림 표시 여부
          presentBadge: true, // 배지 표시 여부
        ),
      ),
      // 알림의 부가적인 데이터
      // 포그라운드, 백그라운드에서 알림 터치했을 때 실행될 함수에 전달됨
      payload: 'Open from Local Notification',
    );
  }
}
