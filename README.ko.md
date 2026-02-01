# macOS 플립 시계

SwiftUI 기반의 macOS용 고도화된 커스텀 플립 시계 애플리케이션

[English Version](./README.md)

## 주요 기능

- **전역 단축키**: 앱 비활성 상태에서도 `Cmd + Ctrl + S`로 화면보호기 모드 즉시 실행 (Carbon API)
- **극대화된 커스터마이징**: 시계, 날짜, 초, AM/PM 크기를 0.05 단위로 정밀하게 개별 조절 가능
- **자유로운 서체 설정**: 기본 서체 외에 시스템에 설치된 모든 폰트를 시계와 날짜에 각각 적용 가능
- **시각 효과**: 리퀴드 글래스 질감, 그림자 강도, 모서리 곡률 등 세부 설정 지원
- **다양한 배경 모드**: 단색, 그라데이션, 로컬/온라인 이미지(WebP/HEIC), 실시간 웹사이트 URL 배경 지원
- **고급 프리셋 관리**: 각 테마별로 서체와 스타일을 개별 저장하고 불러오기 가능
- **스마트 멀티 모니터**: 작업 시 주 모니터 유지, 화면보호기 진입 시 모든 모니터 전체화면 자동 전환
- **업데이트 엔진**: GitHub API 기반 자동 업데이트 체크, 알림바 및 릴리스 노트 팝업 지원
- **시스템 연동**: 영어/한국어 공식 지원, 로그인 시 자동 실행, 독/메뉴바 아이콘 숨기기 옵션 제공

## 이미지 및 영상

<details>
<summary><b>📷 스크린샷 (클릭하여 확장)</b></summary>

### 메인 화면
![Main](./Screenshots/main.png)

### 설정 - 일반
![Settings 1](./Screenshots/setting_panel_1.png)

### 설정 - 외형
![Settings 2](./Screenshots/setting_panel_2.png)

### 설정 - 시간 및 날짜
![Settings 3](./Screenshots/setting_panel_3.png)

### 설정 - 화면보호기
![Settings 4](./Screenshots/setting_panel_4.png)

</details>

<details>
<summary><b>🎥 영상 (클릭하여 확장)</b></summary>

### 플립 애니메이션
[영상 보기](./Videos/flip_animation.mov)

### 테마 커스터마이징
[영상 보기](./Videos/customize_theme.mov)

### 시간 및 날짜 설정
[영상 보기](./Videos/customize_time_date.mov)

</details>

## 기술 스택

- Swift / SwiftUI
- Combine (상태 및 설정 관리)
- Carbon Framework (시스템 전역 핫키)
- WebKit (웹 기반 배경 렌더링)
- ServiceManagement (로그인 항목 등록)

## 저작권

© 2026 orion-gz. All rights reserved.
