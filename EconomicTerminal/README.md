# Economic Terminal (iOS)

기존 웹 대시보드 **'경제현황 터미널'** 을 애플 앱스토어 출시 수준으로 옮긴 네이티브 iOS 앱입니다.
SwiftUI · MVVM · Swift Charts · SwiftData 로 작성했습니다.

> 📌 **비개발자 안내**
> 1. macOS에서 **Xcode 16 이상**을 설치하세요.
> 2. `EconomicTerminal/EconomicTerminal.xcodeproj` 를 더블클릭해 엽니다.
> 3. 상단에서 시뮬레이터(예: iPhone 15)를 고르고 **▶︎ (Run)** 버튼을 누르면 실행됩니다.
> 4. 지금은 화면 확인용 **더미 데이터**가 들어 있어, API 키 없이도 모든 화면이 바로 보입니다.

## 기술 스택
| 항목 | 사용 기술 |
| --- | --- |
| UI | SwiftUI |
| 아키텍처 | MVVM (Model · View · ViewModel) |
| 차트 | Swift Charts (LineMark, SectorMark, RuleMark) |
| 로컬 저장 | SwiftData (포트폴리오 · 알림 규칙) |
| 알림 | UserNotifications (로컬 푸시) + BackgroundTasks |
| 보안 저장 | Keychain (API 키) |

### ⚠️ 최소 지원 버전 안내
요구사항에는 "iOS 16 이상"이라고 적혀 있으나, **SwiftData는 iOS 17부터 제공**되는 프레임워크입니다.
SwiftData를 필수로 사용해야 하므로 이 프로젝트의 최소 타깃은 **iOS 17.0** 으로 설정했습니다.
(Swift Charts 자체는 iOS 16+ 입니다.)

## 폴더 구조
```
EconomicTerminal/
├─ EconomicTerminal.xcodeproj      # Xcode 프로젝트
├─ Info.plist                      # 백그라운드 모드/알림 식별자 등 앱 설정
└─ EconomicTerminal/
   ├─ App/                         # 앱 진입점(@main), 저장소·알림 초기화
   ├─ Models/                      # 데이터 모델 + SwiftData 스키마
   │   ├─ PortfolioItem.swift      # (SwiftData) 보유 종목
   │   └─ AlertRule.swift          # (SwiftData) 알림 규칙
   ├─ Services/                    # 데이터 공급/시스템 연동
   │   ├─ MarketDataService.swift  # 데이터 프로토콜(창구)
   │   ├─ MockMarketDataService.swift  # 더미 데이터 구현
   │   ├─ KeychainService.swift    # API 키 보안 저장
   │   ├─ NotificationService.swift    # 로컬 알림
   │   └─ BackgroundRefreshManager.swift # 백그라운드 알림 점검
   ├─ ViewModels/                  # 탭별 화면 로직(@Observable)
   ├─ Views/                       # 화면(SwiftUI)
   │   ├─ Home/  Indicators/  Portfolio/  RealEstateCalendar/  Settings/
   │   └─ Components/              # 재사용 UI(카드·배지·차트 등)
   ├─ Utilities/                   # 포맷터·테마·기간 정의 등
   └─ Resources/Assets.xcassets    # 앱 아이콘·강조색
```

## 5개 탭 구성
1. **홈** — 오늘의 매크로 3줄 요약, 핵심지표 카드, 글로벌 지수 가로 캐러셀 + 기간별 선차트(1일/1주/1달/1년), 공포·탐욕/VIX/VKOSPI 시장 분위기.
2. **경제 지표** — 외환(USD/KRW 차트 + 52주 최고/최저), 금리(한·미·일·유로존 다중 라인), 채권(10Y/2Y·장단기 스프레드·수익률 곡선), 원자재 시세.
3. **내 포트폴리오** — 종목코드·평단가·수량 입력(로컬 저장), 평가금액/손익/수익률 요약, 자산 비중 도넛 차트, 코스피·S&P500 벤치마크 비교.
4. **부동산 & 캘린더** — 한국 매매/전세지수·미국 Case-Shiller·모기지 금리 추이, 이번 주 주요국 경제 이벤트(중요도 별 1~3개).
5. **알림 및 설정** — 목표가/골든크로스/거래량 폭등 알림 규칙, 로컬 푸시, 라이트/다크 모드, API 키(Keychain) 입력.

## 실데이터 연동(향후)
`MarketDataService` 프로토콜만 구현하는 새 서비스(예: `LiveMarketDataService`)를 만들고,
각 `ViewModel` 생성 시 주입하면 화면 코드를 수정하지 않고 실데이터로 전환할 수 있습니다.
설정 탭에서 입력한 FRED · 공공데이터포털 · 한국은행 ECOS 키는 Keychain에 저장되어 그때 사용됩니다.
