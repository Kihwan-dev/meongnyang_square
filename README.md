<h1 align="center"> 🐶 Meongnyang_Square 🐱 </h1> 
<div align="center"> 
<img width="597" height="357" alt="스크린샷 2025-09-05 08 30 29" src="https://github.com/user-attachments/assets/0f7e4668-ecd9-4b57-b369-2c11276980f9" />
</div> 

<br> 

<h3 align="center"> [Flutter 심화] 클린 아키텍처 기반 SNS 앱 </h3> 
<p align="center"> 프로젝트 일정 [ 25/08/28 ~ 25/09/05 ] </p> 
<br> 
<br> 
<br>

## 🚀 Our Crew
| 이름   | 역할                                              | 담당 UI  | 담당 기능      |
|--------|---------------------------------------------------|--------------------|--------------------|
| 임기환 | 팀장, 발표, 테스트 및 버그 수정              | CommentPage       | WritePage 게시글 작성 & 수정  |
| 오재욱 | 시연 영상 제작             | WritePage           | HomePage 피드 가져오기 & 무한스크롤  |
| 윤한조 | ReadMe, 회의록&피드백 작성          | SplashPage          | CommentPage 댓글 작성 & 로컬알림  |
| 문현선 | 발표 자료 제작, UI 디자인   | HomePage          | SplashPage 로그인 & 회원가입  |
| 공통 | SA 작성 , 스크럼 일지 정리 |                    |                        |
<br>

## 📂 프로젝트 바로가기 링크  
👊 Notion :  
https://www.notion.so/teamsparta/S-A-25d2dc3ef5148052a4cac5468c83c000  

👊 Figma :  
https://www.figma.com/design/Ld0i5hplRZlyKig7PyMuKi/Flutter-%EC%8B%AC%ED%99%94-2%EC%A1%B0?node-id=1008-277&p=f&t=C0W9ZVQsgWdiNo5y-0  

👊 GitHub :  
https://github.com/Kihwan-dev/meongnyang_square  

👊 YouTube :  
https://www.youtube.com/watch?v=xhipVlt6SVQ  
<br>


## 🐶 프로젝트 개요 🐱
### 💡 강아지의 "멍", 고양이의 "냥", 사람들이 모여 소통하는 열린 공간 스퀘어
- 혼자 기록하기보다, 같이 기록하는 즐거움을 주며 따뜻한 소통이 이루어지는 공간  
- 원하는 순간에, 원하는 장소에서 누구나 반려동물의 일상을 공유  
- 강아지와 고양이를 키우는 반려인들을 한 곳에 모아주는 커뮤니티  
- 전체 페이지에 Clean Architecture 적용  
- 앱 전역 에러를 에러 페이지에서 핸들링  
- 상태관리는 Riverpod, 라우팅은 GoRouter  
<br>

## 🔑 핵심 기능
- 원하는 순간을 기록하고 자유롭게 공유
- 태그와 내용을 지정해 나만의 글 작성 가능
- 피드 형태로 반려인들의 일상 확인
- 게시물 및 댓글을 통한 소통
- 전역 에러 핸들링으로 안정적인 앱 경험 제공
<br>

## 📁 파일 구조
<pre>
  <code>lib
├── core
│   ├── constants
│   │   └── end_points.dart
│   ├── notifications
│   │   └── notification_helper.dart
│   ├── router
│   │   └── router.dart
│   └── utils
│       └── debouncer.dart
├── data
│   ├── data_sources
│   │   ├── auth_data_source_impl.dart
│   │   ├── auth_data_source.dart
│   │   ├── comment_remote_data_source_impl.dart
│   │   ├── comment_remote_data_source.dart
│   │   ├── feed_remote_data_source_impl.dart
│   │   ├── feed_remote_data_source.dart
│   │   ├── storage_data_source_impl.dart
│   │   └── storage_data_source.dart
│   ├── dtos
│   │   └── feed_dto.dart
│   └── repositories
│       ├── auth_repository_impl.dart
│       ├── comment_repository_impl.dart
│       ├── feed_repository_impl.dart
│       └── storage_repository_impl.dart
├── domain
│   ├── entities
│   │   ├── auth_user.dart
│   │   ├── comment.dart
│   │   └── feed.dart
│   ├── repositories
│   │   ├── auth_repository.dart
│   │   ├── comment_repository.dart
│   │   ├── feed_repository.dart
│   │   └── storage_repository.dart
│   └── use_cases
│       ├── add_comment_use_case.dart
│       ├── delete_feed_use_case.dart
│       ├── delete_image_use_case.dart
│       ├── feed_params.dart
│       ├── fetch_feeds_use_case.dart
│       ├── observe_comments_use_case.dart
│       ├── upload_image_use_case.dart
│       └── upsert_feed_use_case.dart
├── firebase_options.dart
├── main.dart
├── presentation
│   ├── pages
│   │   ├── comment
│   │   ├── error
│   │   ├── home
│   │   ├── splash
│   │   └── write
│   └── providers.dart
└── services
    └── notification_service.dart</code>
</pre>
<br>

## 📱 App Screens & Features
### 1. Splash page  
<div> 
<img width="300" height="600" alt="Simulator Screenshot - iPhone 16 Pro - 2025-08-27 at 11 28 16" src="https://github.com/user-attachments/assets/f846da75-4cce-4c16-a47d-f17b6a5805c5" />
</div> 
<br>

- 스플래시 애니메이션
- 로그인 회원가입 폼
- Firebase Auth 사용 (이메일 기반)

### 2. Home Page 
<div> 
<img width="300" height="600" alt="Simulator Screenshot - iPhone 16 Pro - 2025-08-27 at 11 28 44" src="https://github.com/user-attachments/assets/0dd20cee-8a61-4d3e-b3b3-1ad0572ffa71" />
</div> 
<br>

- feed 사진, 제목, 내용, 작성시간
- feed는 10개씩 노출되며 추가적으로 무한스크롤
- 게시글 가져오기: Firebase Firestore
- 실시간 업데이트

### 3. Write Page
- 피드 작성 페이지
- 사진 업로드 및 화면 비율에 맞게 편집 가능
- 내가 작성한 피드일 경우 수정, 삭제 가능
- 사진 업로드: Firebase Storage
- 게시글 업로드: Firebase Firestore

### 4. Comment Page
- 댓글확인/작성
- 피드의 사진이 페이지 배경에 보이게 UI설계
- 로컬 알림 구현
- 게시글 가져오기: Firebase Firestore
- 실시간 스트림: QuerySnapshot
<br>


## 🛠 Technologies & 💻 Development Tools
- Flutter 3.32.7
- Dart 3.8.1
- Riverpod – 상태 관리 라이브러리
- Firebase – 인증 / DB / 스토리지 등 백엔드 서비스 연동
- uuid – 사용자 고유 ID 및 데이터 식별자 생성
- google_fonts – 구글 폰트를 통한 UI 타이포그래피 개선
- Android Studio – AVD(에뮬레이터) 관리
- Visual Studio Code – 전체 프로젝트 개발 IDE (플러그인 확장 활용)
- iOS Simulator / Android Emulator – 기능 테스트 및 UI 시뮬레이션
- 기기: Pixel 9
- OS 버전: Android 16 (API 36)
- Figma – UI/UX 화면 설계 및 와이어프레임 제작
- Notion / Zep / Slack – 문서 관리 및 팀 협업 도구
- GitHub – 형상 관리 및 협업
<br>

## 🤝 커밋 컨벤션
- ✨ : 새로운 기능 추가
- 🐛  : 버그 수정
- 📝 : 문서 관련 변경 (예: README, 주석 등)
- 🎨 : UI/스타일 수정
- ♻️ : 기능 변경 없이 코드 구조만 개선
- 🎉 : 프로젝트 시작
<br>

## 🔥 Trouble Shooting
### 1. 페이지 간 데이터 동기화 문제
[문제상황]  
WritePage에서 피드를 수정한 후 HomePage로 돌아갔을 때 변경사항이 반영되지 않는 문제 발생  

[원인분석]  
WritePage에서 수정 후 context.pop()으로 돌아가면 HomePage가 새로고침되지 않음  
HomePage의 피드 목록이 이전 상태 그대로 유지됨  
자동 저장(debouncer)과 수동 저장 모두에서 동일한 문제 발생  

[해결방법]  
WritePage에서 직접 Home을 새로고침  
고라우터에서 ‘onExit’ 을 사용  
<br>

### 2. Riverpod Provider 초기화 오류
[문제상황]  
initState()에서 ref.read() 사용 시 오류 발생  

[원인분석]  
initState()는 위젯이 완전히 초기화되기 전에 호출됨  
Riverpod의 ref는 위젯 트리가 완전히 구성된 후에만 접근 가능  
ConsumerStatefulWidget에서도 initState() 단계에서는 ref 사용 불가  

[해결방법]  
didChangeDependcies를 사용하여 데이터 초기화  
initState(): ref 사용 불가, 기본 초기화만  
didChangeDependencies(): ref 사용 가능, 한 번만 실행되도록 플래그 필요  
<br>

### 3. 좌/우 스와이프 시 현재 인덱스 파악불가
[문제상황]  
WritePage 및 CommentPage로 넘어갈 때 "어느 카드에서 넘어왔는지" 모름   

[원인분석]  
PageView는 스크롤 상태만 관리하고, 인덱스를  추적하지 않음  

[해결방법]  
상태 변수 추가  
PageView 콜백으로 동기화  
세로 PageView에서 현재 인덱스를 추적  
하지 않을 시 어느 카드에서 좌/우 스와이프 했는지 알기 어려움  
<br>

### 4. 스플래시 세션체크 오류
[문제상황]  
스플래시 애니메이션이 한 번 노출이 된 다음 home으로 이동해야 하는데, 바로 home으로 이동을 하는 문제  

[원인분석]  
스플래시 애니메이션 시작 전에 authStateChanges().first 이 실행, 바로 Home으로 라우팅  

[해결방법]  
세션체크(hasSession)와 로딩중(checkingSession)을 체크해서 분기를 나눔
<br>

### 5. 플러그인 버전 불일치 (compileSdk 문제)
[문제상황]  
일부 플러그인이 Android SDK 36 이상을 요구하는데, compileSdk = 35로 설정되어 있어서 충돌  

[원인분석]  
android/app/build.gradle.kts 에서 SDK 버전을 맞춰줌  

[해결방법]  
SDK는 상위 버전으로 맞춰야 하위 버전 앱도 문제 없이 돌아감  
flutter doctor -v와 pubspec.yaml에 있는 패키지 버전을 비교해서 항상 최신 SDK 요구사항을 확인하기  
<br>
<br>
<br>
