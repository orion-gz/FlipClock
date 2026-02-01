#!/bin/bash
# 1. 인자 확인 (예: ./package.sh v1.0.0)
TARGET_FOLDER=$1
if [ -z "$TARGET_FOLDER" ]; then
    echo "Error: 대상 폴더명을 입력하세요 (예: ./package.sh v1.0.0)"
    exit 1
fi
# 2. 경로 설정
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$PROJECT_ROOT/$TARGET_FOLDER"
BG_IMG="$PROJECT_ROOT/Screenshot/screenshot_black.png"
DIST_DIR="$TARGET_DIR/Dist_Temp"
# 3. 대상 폴더 존재 확인
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: $TARGET_FOLDER 폴더를 찾을 수 없습니다."
    exit 1
fi
# 4. 해당 폴더 내 .app 파일 찾기
cd "$TARGET_DIR"
APP_NAME=$(ls -d *.app 2>/dev/null | head -n 1)
if [ -z "$APP_NAME" ]; then
    echo "Error: $TARGET_FOLDER 폴더 안에 .app 파일이 없습니다."
    exit 1
fi
DMG_NAME="${APP_NAME%.app}_${TARGET_FOLDER}.dmg"
echo "Processing $APP_NAME in $TARGET_FOLDER..."
# 5. 빌드 환경 정리
rm -f "$DMG_NAME"
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"
# 6. 파일 준비
cp -R "$APP_NAME" "$DIST_DIR/"
ln -s /Applications "$DIST_DIR/Applications"
# 7. create-dmg 실행
create-dmg \
  --volname "Flip Clock Installer" \
  --background "$BG_IMG" \
  --window-pos 200 120 \
  --window-size 1000 600 \
  --icon-size 160 \
  --text-size 14 \
  --icon "$APP_NAME" 300 300 \
  --icon "Applications" 700 300 \
  --hide-extension "$APP_NAME" \
  "$DMG_NAME" \
  "$DIST_DIR/"
# 8. 임시 폴더 삭제
rm -rf "$DIST_DIR"
echo "--------------------------------------------------"
echo "Success! Created: $TARGET_DIR/$DMG_NAME"
