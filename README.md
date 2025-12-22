# 🚀 Daily Word Admin Panel

Flutter 기반의 **오늘의 단어(Daily Word)** 서비스 관리용 Admin Panel입니다.  
Supabase를 기반으로 단어 업로드, 이미지 업로드, 푸시 알림 전송, 로그 관리 기능을 제공합니다.

---

## 📌 주요 기능

### ✅ 1. 단어 업로드
- 날짜별 단어 데이터 입력
- 이미지 파일 업로드 (Supabase Storage)
- 자동 미리보기 기능 지원

### ✅ 2. 푸시 알림 전송
- 전체 사용자 대상 Push 발송
- 발송 성공/실패 카운트 자동 기록

### ✅ 3. 로그 페이지
- 발송 이력 확인
- 상세 로그 조회
- **전체 로그 삭제 기능 지원**

### ✅ 4. 히스토리 페이지
- 업로드된 단어 목록 조회
- 단어 상세 정보 확인

---

## 📁 프로젝트 구조

lib/
├─ app/ # 앱 부트스트랩 및 테마 설정
├─ models/ # 데이터 모델
├─ pages/ # 화면 UI
├─ services/ # Supabase + Storage + Push 서비스
├─ supabase/ # Supabase 초기화 및 설정
├─ utils/ # 날짜 포맷 등 유틸
├─ widgets/ # 공용 위젯
├─ env.dart # 프로젝트 환경 변수 (Supabase URL/Key)
└─ main.dart # 앱 시작점

yaml
코드 복사

---

## 🔧 실행 방법

### 1) 패키지 설치
```bash
flutter pub get
2) 웹 실행
bash
코드 복사
flutter run -d chrome
또는

bash
코드 복사
flutter run -d edge