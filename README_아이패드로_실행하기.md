# 아이패드에서 Mac 없이 실행하기 (Swift Playgrounds)

`EconomicTerminalPlayground.swiftpm` 는 **Mac/Xcode 없이 아이패드에서 바로 열어 실행**할 수 있는
Swift Playgrounds용 앱 프로젝트입니다. (Xcode용 버전은 `EconomicTerminal/` 폴더에 그대로 있습니다.)

> ℹ️ 아이폰 단독으로는 앱을 "빌드"할 수 없습니다. 빌드/실행은 **아이패드 + Swift Playgrounds**에서 합니다.
> 아이패드에서 실행한 뒤 홈 화면에 추가하거나, 같은 Apple ID의 아이폰으로 보낼 수 있습니다.

## 준비물
- iPadOS 16 이상 아이패드
- 무료 앱 **Swift Playgrounds** (App Store에서 설치) — 가능하면 최신 버전으로 업데이트
- ⚠️ 이 앱은 **SwiftData** 때문에 **iPadOS 17 이상**에서 실제로 동작합니다.

## 가장 쉬운 방법 — GitHub에서 ZIP 받기
1. 아이패드 **Safari**로 이 저장소의 브랜치 페이지를 엽니다.
2. 초록색 **Code ▾ → Download ZIP** 을 눌러 압축 파일을 받습니다.
3. **파일(Files)** 앱에서 받은 ZIP을 한 번 탭하면 압축이 풀립니다.
4. 풀린 폴더 안의 **`EconomicTerminalPlayground.swiftpm`** 를 탭하세요.
   - 이 항목은 Swift Playgrounds 문서로 인식되어, 탭하면 Swift Playgrounds가 열립니다.
5. 우측 상단 **▶︎ (실행)** 버튼을 누르면 앱이 전체 화면으로 실행됩니다.

## 홈 화면에 앱으로 추가 / 아이폰으로 보내기
- Swift Playgrounds에서 프로젝트를 연 뒤, 프로젝트 설정에서 **"앱으로 빌드"** 또는
  화면 공유/실행 기능을 통해 홈 화면에 추가할 수 있습니다.
- 무료 Apple ID로 서명하면 보통 약 7일간 사용할 수 있고, 이후에는 다시 빌드하면 됩니다.
- 앱스토어에 정식 출시하려면 Swift Playgrounds의 **App Store Connect 업로드** 기능 또는
  Mac의 Xcode가 필요하며, 유료 Apple Developer 계정($99/년)이 있어야 합니다.

## Xcode 버전과 무엇이 다른가요?
거의 동일하지만, 아이패드 제약상 아래 한 가지만 빠져 있습니다.
| 기능 | Xcode 버전(`EconomicTerminal/`) | 아이패드 버전(`.swiftpm`) |
| --- | --- | --- |
| 5개 탭 전체 화면/차트 | ✅ | ✅ |
| 포트폴리오 로컬 저장(SwiftData) | ✅ | ✅ |
| 목표가/골든크로스 알림 + 테스트 알림 | ✅ | ✅ (앱이 켜져 있을 때 즉시 평가) |
| **백그라운드 자동 알림 점검** | ✅ | ⛔️ 제외 (Info.plist 백그라운드 설정 필요) |
| 라이트/다크 모드, API 키(Keychain) | ✅ | ✅ |

백그라운드 점검은 아이패드 Swift Playgrounds 환경에서 설정할 수 없어 제외했고,
대신 설정 탭의 **"지금 조건 평가하기"** 버튼으로 알림 동작을 바로 확인할 수 있습니다.

## 잘 안 될 때
- "열 수 없음" → Swift Playgrounds를 최신 버전으로 업데이트하세요(폴더 구조 지원 필요).
- 차트/데이터가 안 보임 → 화면을 아래로 당겨 새로고침하거나 앱을 다시 실행하세요(더미 데이터는 항상 표시됩니다).
- 빌드 오류 메시지가 보이면 그 내용을 알려주세요. 바로 수정해 드리겠습니다.
