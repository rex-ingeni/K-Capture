#!/bin/sh
set -eu

cd "$(dirname "$0")/.."
PAGE="docs/index.html"
STORE_PAGE="docs/app-store.html"
PRIVACY_PAGE="docs/privacy.html"
SUPPORT_PAGE="docs/support.html"

check_contains() {
    pattern="$1"
    label="$2"
    grep -Fq "$pattern" "$PAGE" || {
        echo "FAIL: $label"
        exit 1
    }
}

check_absent() {
    pattern="$1"
    label="$2"
    if grep -Fq "$pattern" "$PAGE"; then
        echo "FAIL: $label"
        exit 1
    fi
}

check_file_contains() {
    file="$1"
    pattern="$2"
    label="$3"
    grep -Fq "$pattern" "$file" || {
        echo "FAIL: $label"
        exit 1
    }
}

check_file_absent() {
    file="$1"
    pattern="$2"
    label="$3"
    if grep -Fq "$pattern" "$file"; then
        echo "FAIL: $label"
        exit 1
    fi
}

check_contains 'https://apps.apple.com/app/id6795031618' '공식 Mac App Store 주소'
check_contains 'data-channel-card="app-store"' 'App Store 배포 카드'
check_contains 'data-channel-card="direct"' 'Developer ID 직접 배포 카드'
check_contains 'Developer ID' '직접 배포 서명 설명'
check_contains 'Apple 공증' '직접 배포 공증 설명'
check_contains 'channel=app-store' 'App Store 채널별 소개 상태'
check_contains 'channel=direct' '직접 배포 채널별 소개 상태'
check_absent 'xattr -cr' 'Gatekeeper 우회 명령 제거'
check_absent '미서명 앱' '미서명 앱 안내 제거'

check_file_contains "$STORE_PAGE" 'Mac App Store가 설치와 업데이트를 관리합니다' 'Store 전용 업데이트 안내'
check_file_contains "$STORE_PAGE" 'privacy.html' 'Store 전용 개인정보 링크'
check_file_contains "$STORE_PAGE" 'support.html' 'Store 전용 지원 링크'
check_file_absent "$STORE_PAGE" 'github.com/rex-ingeni/K-Capture/releases' 'Store 페이지의 GitHub 릴리스 링크 제거'
check_file_absent "$STORE_PAGE" 'DMG' 'Store 페이지의 DMG 안내 제거'
check_file_absent "$STORE_PAGE" 'Windows' 'Store 페이지의 타 플랫폼 다운로드 제거'
check_file_absent "$STORE_PAGE" '준비 중' 'Store 페이지의 임시 상태 문구 제거'
check_file_absent "$STORE_PAGE" 'version.json' 'Store 페이지의 직접 업데이트 확인 제거'

check_file_contains "$PRIVACY_PAGE" '개인정보 처리방침' '공개 개인정보 처리방침'
check_file_contains "$PRIVACY_PAGE" 'Privacy Policy' '영문 개인정보 처리방침'
check_file_contains "$PRIVACY_PAGE" 'ingeni@kakao.com' '개인정보 문의 이메일'
check_file_contains "$SUPPORT_PAGE" '고객 지원' '공개 지원 페이지'
check_file_contains "$SUPPORT_PAGE" 'Support' '영문 지원 페이지'
check_file_contains "$SUPPORT_PAGE" 'mailto:ingeni@kakao.com' '로그인 없는 이메일 문의'
check_contains 'macOS 13 이상' '실제 최소 지원 버전'
check_absent 'macOS 12 이상' '잘못된 최소 지원 버전 제거'

echo "PASS: 소개 페이지 배포 채널 구분"
