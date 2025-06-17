# CathyUnitediOSInterview

這是一個使用 Swift 及 UIKit 撰寫的示範專案，主要展示簡易的好友清單與邀請列表功能。

## 專案特色

- **MVVM 架構**：以 `FriendsViewControllerVM` 處理資料與畫面邏輯。
- **Combine**：利用 `@Published` 與 `AnyPublisher` 建立畫面與資料間的資料流。
- **Diffable Data Source**：管理好友與邀請列表的 `UITableView` 資料更新。
- **自訂 UI 元件**：例如 `GradientButtonView`、`PagingHeaderView` 等，提升整體互動性與視覺效果。
- **網路請求**：`APIClient` 從遠端 JSON 取得使用者與好友資料並處理錯誤狀態。

## 執行環境

- Xcode 15 或更新版本（專案設定的 `SWIFT_VERSION` 為 5.0，`IPHONEOS_DEPLOYMENT_TARGET` 為 18.2）。
- iOS 18.2 以上模擬器或真實裝置。

## 如何開始

1. 以 Xcode 開啟 `CathyUnitediOSInterview.xcodeproj`。
2. 在目標裝置上 Build & Run 即可。
3. 首頁 `StartingViewController` 提供三種情境可選擇：無好友、僅好友列表、好友列表含邀請。

## 目錄結構簡介

```
CathyUnitediOSInterview/
├── Application/        # AppDelegate 與 SceneDelegate
├── Model/             # User、Friend 等資料模型
├── Network/           # APIClient 及 API 定義
├── View/              # 各種自訂畫面元件與 view controller
├── ViewModel/         # FriendsViewController 相關的 VM
├── Utils/             # Extension 與共用協定
└── Resource/          # Assets 與 Storyboard
```

## 參考 API

範例 API 由 [dimanyen.github.io](https://dimanyen.github.io/) 提供，包含使用者資料與多種好友清單。相關端點定義於 `APIClient.swift`。

## 授權

此專案僅供面試及學習用途，無特別授權條款。
