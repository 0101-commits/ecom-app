// swift-tools-version: 5.9

// Package.swift
// 이 파일이 있으면 아이패드의 'Swift Playgrounds' 앱이 이 폴더를 '앱 프로젝트'로 인식해
// 바로 실행/홈 화면 추가가 가능합니다. (Xcode의 .xcodeproj 없이 동작)
// .iOSApplication 으로 앱 이름·번들 ID·지원 기기/방향을 지정하므로 Info.plist가 필요 없습니다.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "EconomicTerminal",
    platforms: [
        .iOS("17.0")   // SwiftData 사용으로 최소 iOS 17
    ],
    products: [
        .iOSApplication(
            name: "Economic Terminal",
            targets: ["AppModule"],
            bundleIdentifier: "com.economicterminal.app",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)
