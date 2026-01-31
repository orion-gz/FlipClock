# macOS Flip Clock

A sophisticated, highly customizable Flip Clock application for macOS, built with SwiftUI.

---

<details>
<summary><b>🇰🇷 한국어 설명 보기 (Click to see Korean version)</b></summary>

# macOS 플립 시계

SwiftUI로 제작된 정교하고 고도의 커스터마이징이 가능한 macOS용 플립 시계 애플리케이션입니다.

## 🚀 주요 기능

- **영구 설정 및 커스텀 프리셋**: 사용자가 설정한 모든 디자인과 옵션은 자동으로 저장되며, 나만의 테마를 프리셋으로 저장하여 관리할 수 있습니다.
- **다국어 지원**: 영어와 한국어를 완벽하게 지원하며 설정에서 실시간으로 변경 가능합니다.
- **전역 단축키 시스템**: 앱이 백그라운드에 있더라도 Carbon HotKey API를 통해 언제 어디서나 단축키(`Command + Control + S`)로 화면보호기 모드를 실행할 수 있습니다.
- **강력한 시각적 커스터마이징**:
    - **글꼴**: 기본 4종 폰트 외에 Mac 시스템에 설치된 모든 폰트를 선택하여 적용할 수 있습니다.
    - **배경**: 단색, 그라데이션, 애니메이션 그라데이션뿐만 아니라 로컬 이미지, 웹 이미지(WebP 포함), 그리고 특정 웹사이트 URL을 배경으로 사용할 수 있습니다.
    - **특수 효과**: 세련된 '리퀴드 글래스' 유리 질감 효과와 입체적인 그림자 효과를 지원합니다.
- **멀티 모니터 지원**: 주 모니터 혹은 연결된 모든 모니터에 시계를 동시에 띄울 수 있습니다.
- **화면보호기 모드**: 대기 시간에 따른 자동 실행 및 마우스/키보드 활동 시 즉시 종료 기능을 지원합니다.
- **상세 디스플레이 옵션**: 24시간 형식, 날짜 형식 다양화, AM/PM 및 초 단위 크기 개별 조절이 가능합니다.
- **데스크탑 통합**: 메뉴바 아이콘 표시/숨기기 및 독(Dock) 아이콘 숨기기 옵션을 통해 작업 환경에 최적화할 수 있습니다.

## 🛠 기술 스택

- **Swift / SwiftUI**
- **Combine**: 실시간 설정 변경 및 상태 관리
- **Carbon Framework**: 전역 단축키 구현
- **WebKit**: 웹 기반 배경 렌더링
- **ServiceManagement**: 로그인 시 자동 실행 연동

---
</details>

## 🚀 Key Features

- **Persistence & Custom Presets**: All design settings and options are automatically saved. Create and manage your own custom theme presets.
- **Localization**: Full support for English and Korean, switchable in real-time within the settings.
- **Global Shortcut System**: Launch the ScreenSaver mode from anywhere using the Carbon HotKey API (`Command + Control + S`), even when the app is in the background.
- **Powerful Visual Customization**:
    - **Fonts**: Choose from standard fonts or any font family installed on your macOS system.
    - **Backgrounds**: Supports Solid colors, Linear Gradients, Animated Gradients, Local Images, Online Images (including WebP), and even Website URLs as backgrounds.
    - **Special Effects**: High-quality 'Liquid Glass' texture and customizable shadow effects for a premium look.
- **Multi-Monitor Support**: Option to display the clock on the primary screen or all connected displays simultaneously.
- **ScreenSaver Mode**: Auto-trigger based on idle time and instant exit on mouse or keyboard activity.
- **Detailed Display Options**: Toggle 24-hour format, diverse date formats, and independent scale adjustment for AM/PM and Seconds.
- **Desktop Integration**: Highly flexible desktop integration with options to show/hide the Menu Bar icon and the Dock icon.

## 🛠 Tech Stack

- **Swift / SwiftUI**
- **Combine**: For real-time state management and settings observation.
- **Carbon Framework**: To handle global system-wide hotkeys.
- **WebKit**: To render interactive web-based backgrounds.
- **ServiceManagement**: For 'Launch at Login' functionality.

## 📄 License

© 2026 orion-gz. All rights reserved.
