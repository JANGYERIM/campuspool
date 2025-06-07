# 풀스택 서비스 프로그래밍 프로젝트: CampusPool (카풀 매칭 커뮤니티 앱)

대학교 캠퍼스 구성원들을 위한 카풀 매칭 커뮤니티 모바일 애플리케이션입니다.

## 📝 목차

- [1. 프로젝트 개요](#1-프로젝트-개요)
- [2. 추진 목적](#2-추진-목적)
- [3. 주요 기능](#3-주요-기능)
- [4. 창작/Clone 여부](#4-창작clone-여부)
- [5. 클라이언트 타입](#5-클라이언트-타입)
- [6. 기술 스택](#6-기술-스택)
- [7. 시스템 아키텍처](#7-시스템-아키텍처)
- [8. 애플리케이션 설치 및 실행](#8-애플리케이션-설치-및-실행)
  - [8.1. 서버 실행](#81-서버-실행)
  - [8.2. 클라이언트 (Flutter 앱) 실행](#82-클라이언트-flutter-앱-실행)
  - [8.3. Android 앱 직접 설치 (APK)](#83-android-앱-직접-설치-apk)
- [9. API 주요 엔드포인트](#9-api-주요-엔드포인트)
- [10. 폴더 구조](#10-폴더-구조)
- [11. 애플리케이션 미리보기 (UX/UI 스크린샷)](#11-애플리케이션미리보기). 
- [12. 개발자](#12-개발자)

## 1. 프로젝트 개요

**CampusPool (캠퍼스풀)**은 교내 구성원들의 편리하고 효율적인 이동을 지원하기 위해 개발된 실시간 카풀 매칭 모바일 애플리케이션입니다. 본 서비스는 운전자와 탑승 희망자를 연결하여 이동 시간을 단축시키고, 교내 커뮤니티 활성화에 기여하는 것을 목표로 합니다.

## 2. 추진 목적

본 프로젝트는 특정 시간대(예: 1, 2교시 수업 전, 점심시간 등)에 대중교통 이용 대기 시간이 길어져 불편함을 겪는 경희대학교 국제캠퍼스 학생들의 이동 편의성 개선을 목표로 합니다.

이를 위해, 운전자와 탑승자를 효율적으로 매칭하는 시스템을 구현하여 다음과 같은 가치를 제공하고자 합니다:

-   **이동 효율성 증대:** 대중교통 대기 시간을 단축시키고, 보다 빠르고 직접적인 이동 경로를 제공합니다.
-   **시간적 부담 감소:** 불필요한 대기 및 이동 시간을 줄여 학생들의 학업 및 개인 활동 시간을 확보합니다.
-   **교내 커뮤니티 활성화:** 카풀을 통한 자연스러운 만남과 교류의 기회를 제공하여 캠퍼스 내 유대감을 강화합니다.
-   **편리한 사용자 경험:** 사용자 간 원활한 소통 기능(실시간 채팅)과 직관적인 매칭 및 예약 과정을 통해 편리하고 신속한 이동 서비스를 제공합니다.

궁극적으로 CampusPool은 교내 이동의 새로운 대안을 제시하여 학생들의 캠퍼스 생활 만족도를 높이는 데 기여하고자 합니다.



## 3. 주요 기능

-   👤 **사용자 등록 및 로그인:** 안전한 서비스 이용을 위한 이메일 기반 회원가입 및 로그인 기능을 제공하며, JWT를 활용한 인증 시스템을 구축하였습니다.
-   📝 **카풀 게시물 등록 및 목록 조회:**
    -   운전자와 탑승 희망자 모두 자신의 조건(출발지, 도착지, 시간, 요금 등)에 맞는 카풀 게시물을 손쉽게 등록할 수 있습니다.
    -   역할(운전자/탑승자)에 따른 맞춤형 게시물 필터링 기능을 제공하여 사용자가 원하는 정보를 빠르게 찾을 수 있도록 지원합니다. (서버 API: `GET /api/posts/by-role`)
    -   키워드(출발지, 도착지, 닉네임) 기반의 유연한 검색 기능을 제공합니다. (서버 API: `GET /api/posts/search`)
-   🤝 **예약 및 예약 확인:**
    -   탑승 희망자는 관심 있는 카풀 게시물에 대해 예약 요청을 보낼 수 있습니다. (서버 API: `POST /api/reservations`)
    -   게시물 작성자(운전자)는 수신한 예약 요청을 확인하고 수락 또는 거절할 수 있습니다. (서버 API: `PUT /api/reservations/{id}/accept`, `PUT /api/reservations/{id}/reject`)
    -   예약 상태(요청됨, 수락됨, 거절됨, 취소됨)는 관련 사용자들에게 명확하게 안내됩니다. (서버 API: `GET /api/reservations/status`)
-   💬 **실시간 채팅:**
    -   카풀 매칭 전후, 사용자들이 서로 세부 사항을 조율하거나 문의할 수 있도록 STOMP 프로토콜 기반의 WebSocket을 활용한 1:1 실시간 채팅 기능을 제공합니다. (서버 Endpoint: `/ws-chat`, 메시지 핸들링: `/app/chat.send`, 구독: `/topic/chat.{roomId}`)
    -   채팅방 목록에서는 각 대화와 연관된 카풀 게시물의 예약 상태를 아이콘으로 표시하여 사용자가 중요한 정보를 한눈에 파악할 수 있도록 합니다. (서버 API: `GET /api/chat/rooms/{userId}`)
    -   채팅 상세 화면 내에서도 관련 카풀 정보를 확인하고 예약 관련 액션(요청, 수락 등)을 바로 수행할 수 있습니다.
-   ⚙️ **프로필 관리:**
    -   사용자는 자신의 닉네임 등 개인 정보를 수정할 수 있습니다. (서버 API: `PUT /api/auth/update`)
    -   자신의 프로필 정보를 조회할 수 있습니다. (서버 API: `GET /api/auth/profile`)
-   📧 **건의사항 제출:** 앱 사용 중 발생하는 문제점이나 개선 아이디어를 관리자에게 편리하게 전달할 수 있는 기능을 제공합니다. (서버 API: `POST /api/suggestions`)

## 4. 창작/Clone 여부

본 프로젝트는 아이디어 구상부터 설계, 개발까지 모든 과정을 자체적으로 진행한 **창작 프로젝트**입니다.

## 5. 클라이언트 타입

**모바일 앱 (Flutter 프레임워크 기반)**

## 6. 기술 스택

### 서버 (Backend) - `campuspoolspring` 디렉토리
-   **Language:** Java 17
-   **Framework:** Spring Boot 3.x
-   **Data Access:** Spring Data JPA, Hibernate
-   **Security:** Spring Security, JWT (JSON Web Token) - `io.jsonwebtoken` 라이브러리 사용
-   **Real-time Communication:** Spring WebSocket, STOMP
-   **Database:** H2 (개발용), MySQL (운영 환경 구성 예정)
-   **Build Tool:** Gradle
-   **Email:** Spring Boot Mail (JavaMailSender)
-   **Lombok:** Boilerplate 코드 감소

### 클라이언트 (Client - Mobile App) - `campuspool_app` 디렉토리
-   **Framework:** Flutter 3.x
-   **Language:** Dart
-   **State Management:** `setState` 및 `FutureBuilder` (주요 비동기 처리)`
-   **HTTP Client:** `http` 패키지
-   **Real-time Communication:** `stomp_dart_client` 패키지
-   **Local Storage:** `shared_preferences` (로그인 토큰, 사용자 정보 등 저장)
-   **UI:** Material Design Widgets
-   **Date/Time Formatting:** `intl` 패키지

### 버전 관리 및 협업
-   **Version Control:** Git
-   **Repository Hosting:** GitHub (`https://github.com/JANGYERIM/campuspool`)

## 7. 시스템 아키텍처

본 시스템은 모바일 클라이언트와 Spring Boot 기반의 백엔드 서버로 구성된 전형적인 클라이언트-서버 아키텍처를 따릅니다.

-   **클라이언트 (Flutter App):** 사용자 인터페이스(UI) 및 사용자 경험(UX) 제공, 사용자 입력 처리, 서버로의 RESTful API 요청 및 응답 처리, WebSocket을 통한 실시간 채팅 메시지 송수신.
-   **서버 (Spring Boot):** RESTful API 엔드포인트 제공, 비즈니스 로직(카풀 매칭, 예약, 채팅 등) 처리, JPA를 통한 데이터베이스 연동, JWT 기반의 사용자 인증 및 인가 처리, WebSocket 연결 관리 및 메시지 브로커 역할 수행.
-   **데이터베이스 (H2):** 사용자 정보, 카풀 게시물, 예약 정보, 채팅 메시지, 채팅방 메타데이터 등 서비스 운영에 필요한 모든 영속적 데이터를 저장하고 관리합니다.

## 8. 애플리케이션 설치 및 실행

### 8.1. 서버 실행

1.  **사전 요구사항:**
    -   Java Development Kit (JDK) 17 이상 설치
    -   Gradle (프로젝트 내 포함된 Wrapper 사용 가능)
    -   (선택) IntelliJ IDEA 또는 Eclipse와 같은 Java IDE
2.  **저장소 클론:**
    ```bash
    git clone https://github.com/JANGYERIM/campuspool.git
    cd campuspool/campuspoolspring
    ```
3.  **환경 설정:**
    -   `src/main/resources/application.yml` 파일을 열어 다음 항목들을 환경에 맞게 설정합니다.
        -   `spring.datasource.url`: H2 데이터베이스 파일 경로 (기본값: `./data/campuspool`)
        -   `spring.mail.username`: 네이버 메일 발신 계정 (건의사항 발송용)
        -   `spring.mail.password`: 해당 네이버 계정의 앱 비밀번호 (환경 변수 `${NAVER_PASSWORD}` 또는 직접 입력)
        -   `jwt.secret`: JWT 서명에 사용될 시크릿 키 
4.  **빌드 및 실행:**
    -   **IDE 사용:** `com.campuspoolspring.ServerApplication.java` 파일을 찾아 실행합니다.
    -   **터미널 사용:**
        ```bash
        ./gradlew bootRun
        ```
5.  **서버 확인:**
    -   애플리케이션이 정상적으로 실행되면, 기본적으로 `http://localhost:8080` 에서 서버가 시작됩니다.
    -   H2 데이터베이스 콘솔은 `http://localhost:8080/h2-console` 로 접속 가능합니다. (JDBC URL: `jdbc:h2:file:./data/campuspool`, User Name: `sa`, Password: 공백)

### 8.2. 클라이언트 (Flutter 앱) 실행

1.  **사전 요구사항:**
    -   Flutter SDK 설치 (공식 홈페이지 가이드 참고: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install))
    -   Android Studio (Android Emulator 또는 실제 기기 연결) 또는 Xcode (iOS Simulator 또는 실제 기기 연결)
    -   VS Code 또는 Android Studio 등의 IDE 와 Flutter/Dart 확장 프로그램 설치
2.  **프로젝트 디렉토리 이동 및 패키지 설치:**
    ```bash
    cd campuspool/campuspool_app
    flutter pub get
    ```
3.  **API 서버 주소 확인:**
    -   클라이언트 코드 내의 API 서비스 파일들 (예: `lib/services/api/post_service.dart`, `chat_service.dart` 등)에 정의된 `baseUrl` 또는 WebSocket URL이 실행 환경에 맞게 설정되어 있는지 확인합니다.
        -   Android Emulator: `http://10.0.2.2:8080` (HTTP), `ws://10.0.2.2:8080/ws-chat` (WebSocket)
        -   iOS Simulator 또는 로컬 웹: `http://localhost:8080` (HTTP), `ws://localhost:8080/ws-chat` (WebSocket)
        -   실제 기기 (같은 네트워크): PC의 로컬 IP 주소 (예: `http://192.168.0.10:8080`)
4.  **앱 실행:**
    -   연결된 디바이스 또는 에뮬레이터/시뮬레이터를 선택합니다.
    -   터미널에서 다음 명령어를 실행하거나, IDE의 실행(Run) 버튼을 사용합니다.
        ```bash
        flutter run
        ```

### 8.3. Android 앱 직접 설치 (APK)

평가 또는 테스트 목적으로 Android 기기에 직접 앱을 설치할 수 있습니다.

1.  **APK 파일 다운로드:**
    *   [**CampusPool 앱 최신 릴리스 다운로드 페이지 바로가기**](https://github.com/JANGYERIM/campuspool/releases/latest)
    *   위 링크로 접속하여 최신 릴리스 항목에서 `app-release.apk` 파일을 찾아 안드로이드 기기로 다운로드합니다.

2.  **"알 수 없는 출처의 앱 설치" 허용:**
    *   Android 기기에서 `.apk` 파일을 직접 설치하려면, 보안 설정에서 "출처를 알 수 없는 앱" 또는 "알 수 없는 앱 설치"를 허용해야 합니다. 이 설정은 기기 제조사 및 Android 버전에 따라 경로가 다를 수 있습니다. (보통 `설정 > 보안` 또는 `설정 > 애플리케이션 > 특별한 접근`)
    *   파일 관리자 앱을 선택하고 "이 출처 허용"을 활성화합니다.

3.  **APK 파일 설치:**
    *   다운로드한 `app-release.apk` 파일을 파일 관리자 앱을 통해 실행(탭)하고, 안내에 따라 설치를 진행합니다.

4.  **앱 실행:**
    *   설치가 완료되면 앱 서랍에서 "CampusPool" (또는 실제 앱 이름) 아이콘을 찾아 실행합니다.

## 9. API 주요 엔드포인트

| HTTP Method | Endpoint                       | 설명                        | 인증 필요 |
| :---------- | :----------------------------- | :-------------------------- | :-------: |
| POST        | `/api/auth/register`             | 회원가입                    |    X      |
| POST        | `/api/auth/login`                | 로그인 (JWT 토큰 발급)        |    X      |
| GET         | `/api/auth/profile`              | 사용자 프로필 조회            |    O      |
| PUT         | `/api/auth/update`               | 사용자 닉네임 수정            |    O      |
| GET         | `/api/auth/check-email`          | 이메일 중복 확인              |    X      |
| POST        | `/api/posts`                     | 새 게시물 등록                |    O      |
| GET         | `/api/posts/api/posts`           | 전체 게시물 목록 조회 | X      |
| GET         | `/api/posts/{id}`                | 특정 게시물 상세 조회         |    X      |
| GET         | `/api/posts/by-role`             | 역할 기반 게시물 필터링 조회  |    X      |
| GET         | `/api/posts/search`              | 키워드 기반 게시물 검색       |    X      |
| POST        | `/api/reservations`              | 예약 요청                   |    O      |
| PUT         | `/api/reservations/{id}/accept`  | 예약 수락                   |    O      |
| PUT         | `/api/reservations/{id}/reject`  | 예약 거절                   |    O      |
| PUT         | `/api/reservations/{id}/cancel`  | 예약 취소                   |    O      |
| GET         | `/api/reservations/status`       | 특정 게시물 예약 상태 조회    |    O      |
| GET         | `/api/chat/rooms/{userId}`       | 특정 사용자의 채팅방 목록 조회|    X      |
| GET         | `/api/chat/room/{roomId}`        | 특정 채팅방의 메시지 내역 조회|    X      |
| (WebSocket) | `/ws-chat`                       | WebSocket 연결 엔드포인트     |    -      |
| (WebSocket) | `/app/chat.send`                 | 메시지 발송 (서버 수신)       |    -      |
| (WebSocket) | `/topic/chat.{roomId}`           | 메시지 구독 (클라이언트 수신) |    -      |
| POST        | `/api/suggestions`               | 건의사항 제출                |    O      |

## 10. 폴더 구조

### 10. 폴더 구조

```text
campuspool/
├── campuspool_app/ # Flutter 클라이언트 앱 소스 코드
│   ├── lib/
│   │   ├── main.dart # 앱 시작점
│   │   ├── models/       # 데이터 모델 클래스 (PostSummary, ChatRoom, Message, Reservation 등)
│   │   ├── screens/      # 주요 UI 화면 (PostListScreen, ChatDetailScreen, SuggestionScreen 등)
│   │   ├── services/     # API 서비스 로직, 상태 관리 (ChatService, PostService, ReservationService 등)
│   │   ├── utils/        # 유틸리티 함수 (user_util.dart 등)
│   │   └── widgets/      # 재사용 가능한 공통 UI 위젯
│   ├── android/        # Android 플랫폼 관련 설정 및 코드
│   ├── ios/            # iOS 플랫폼 관련 설정 및 코드
│   └── pubspec.yaml    # 프로젝트 의존성 및 메타데이터 관리
│
├── campuspoolspring/ # Spring Boot 서버 소스 코드
│   ├── src/main/java/com/campuspoolspring/
│   │   ├── config/       # Spring 설정 (SecurityConfig, WebSocketConfig, WebConfig)
│   │   ├── controller/   # API 요청을 처리하는 컨트롤러
│   │   ├── dto/          # 데이터 전송 객체 (Data Transfer Object)
│   │   ├── model/        # JPA 엔티티 및 도메인 모델 (User, Post, Reservation 등)
│   │   ├── repository/   # Spring Data JPA 리포지토리 인터페이스
│   │   ├── security/     # JWT 인증/인가 관련 클래스 (JwtUtil, JwtAuthenticationFilter)
│   │   └── service/      # 비즈니스 로직을 처리하는 서비스 계층
│   ├── src/main/resources/ # 설정 파일 (application.yml, static/templates 등)
│   └── build.gradle    # Gradle 빌드 스크립트
│
└── README.md         # 본 프로젝트 설명 파일
 
## 11. 애플리케이션 스크린샷 (UI/UX 미리보기)

CampusPool 앱의 주요 화면과 사용자 인터페이스는 다음과 같습니다.

| **로그인 화면**                                  | **게시물 목록(검색)**                            | **게시물 등록 화면**                            |
| :----------------------------------------------: | :----------------------------------------------: | :---------------------------------------------: |
| <img src="https://github.com/user-attachments/assets/db34857c-7f5e-432d-ab20-f6d238ba1379" alt="로그인 화면" width="250"> | <img src="https://github.com/user-attachments/assets/73b72462-18d0-4716-98f9-1035a35f5dc8" alt="게시물 목록" width="250"> | <img src="https://github.com/user-attachments/assets/ada4ce69-41d2-4e13-8a8b-44fe6bb3c4d4" alt="게시물 등록" width="250"> |


| **채팅 목록 (예약 상태 아이콘)**                 | **채팅 상세 (예약 버튼)**                        | **건의사항 작성**                               |
| :----------------------------------------------: | :----------------------------------------------: | :---------------------------------------------: |
| <img src="https://github.com/user-attachments/assets/78765ba3-967e-4e9f-845d-e198fe9d9e4a" alt="채팅 목록" width="250"> | <img src="https://github.com/user-attachments/assets/f4c15486-c28d-4850-9669-e47aae97d0d5" alt="채팅 상세" width="250"> | <img src="https://github.com/user-attachments/assets/fa3470e6-5efd-4782-8ba0-61abba0dcf9e" alt="건의사항" width="250"> |

## 12. 개발자

-   **장예림**
    -   GitHub: [https://github.com/JANGYERIM](https://github.com/JANGYERIM)
    -   Email: [wkddpfla3@gmail.com]
    -   역할: 프로젝트 기획, 풀스택 개발 (서버 API, 데이터베이스 설계, 클라이언트 UI/UX, 실시간 채팅 및 예약 기능 구현 등 전반적인 개발 담당)

