# GitHub Users Explorer

[English](#english) | [日本語](#japanese)

<a id="japanese"></a>
# GitHub ユーザーエクスプローラー

## スクリーンショットと動画
<img src="https://github.com/camyoh/Github-User-Search/blob/main/SupportFiles/video-gif.gif" width="300">

<img src="https://raw.githubusercontent.com/camyoh/Github-User-Search/main/SupportFiles/eng2.png" width="300"> <img src="https://raw.githubusercontent.com/camyoh/Github-User-Search/main/SupportFiles/eng1.png" width="300">

### 対応言語：英語・日本語・スペイン語
<img src="https://github.com/camyoh/Github-User-Search/blob/main/SupportFiles/jap4.png" width="300"> <img src="https://github.com/camyoh/Github-User-Search/blob/main/SupportFiles/jap3.png" width="300"> <img src="https://github.com/camyoh/Github-User-Search/blob/main/SupportFiles/jap2.png" width="300"> <img src="https://github.com/camyoh/Github-User-Search/blob/main/SupportFiles/jap1.png" width="300">

## 概要
クリーンアーキテクチャ、プログラマティックUI、包括的なテストカバレッジを備えた、GitHubユーザーを探索するためのモダンなiOSアプリケーションです。このアプリは、保守性、拡張性、信頼性に重点を置いたiOS開発のベストプラクティスを示しています。

## アーキテクチャ
このプロジェクトは、SOLIDの原則に厳密に従いながら、MVVM + Coordinatorパターンを用いたクリーンアーキテクチャアプローチを実装しています：

### コアアーキテクチャコンポーネント

- **MVVM（Model-View-ViewModel）**: UI（View）、ビジネスロジック（ViewModel）、データ（Model）の分離
- **Coordinatorパターン**: ナビゲーションロジックをビューコントローラーから分離
- **Repositoryパターン**: データアクセスのためのクリーンなAPI提供
- **プロトコル指向設計**: 依存性注入とテスト容易性を実現
- **プログラマティックUI**: ストーリーボードなし、すべてのUIはプログラムで構築され、バージョン管理と再利用性が向上

### SOLID原則の実装

1. **単一責任の原則**: 各クラスは一つの責任を持つ（例: ViewModelはビジネスロジックのみを管理）
2. **オープン・クローズドの原則**: コンポーネントは拡張に対してオープンで、修正に対してクローズド
3. **リスコフの置換原則**: プロトコル実装はシステムの動作に影響を与えることなく置き換え可能
4. **インターフェース分離の原則**: クライアントは使用するメソッドのみに依存
5. **依存性逆転の原則**: 高レベルモジュールは抽象に依存し、具体的な実装には依存しない

### プロジェクト構造
```
git-test/
├── Features/                    # ドメインごとに整理されたアプリケーション機能
│   ├── UsersList/               # ユーザーリスト機能
│   │   ├── View/                # UIコンポーネント
│   │   └── ViewModel/           # ビューモデル
│   ├── UserDetail/              # ユーザー詳細機能
│   │   ├── View/                # UIコンポーネント
│   │   └── ViewModel/           # ビューモデル
│   └── WebView/                 # リポジトリ用Webビュー
├── Coordinator/                 # ナビゲーションコーディネーター
│   ├── Coordinator.swift        # 基本コーディネータープロトコル
│   ├── AppCoordinator.swift     # メインアプリコーディネーター
│   ├── UsersListCoordinator.swift # ユーザーリストフロー
│   └── UserDetailCoordinator.swift # ユーザー詳細フロー
├── Common/                      # 共有機能
│   ├── Extensions/              # Swift拡張
│   ├── Models/                  # ドメインモデル
│   ├── Networking/              # ネットワークサービスとリポジトリ
│   └── Localization/            # ローカライゼーションサポート
├── Resources/                   # アプリリソース
│   ├── en.lproj/               # 英語ローカライゼーション
│   ├── es.lproj/               # スペイン語ローカライゼーション
│   └── ja.lproj/               # 日本語ローカライゼーション
└── Application/                 # アプリケーションライフサイクル管理
    ├── AppDelegate.swift
    └── SceneDelegate.swift
```

## 主要機能

### ネットワークレイヤー
- **プロトコルベースの設計**: テストと置き換えが容易
- **ジェネリック関数**: 型安全なAPIリクエスト
- **包括的なエラー処理**: ドメイン固有のエラータイプ
- **非同期/待機**: 最新の並行処理実装

### ビューモデル
- **状態ベースのアーキテクチャ**: 明確な状態遷移
- **単方向データフロー**: 予測可能なUI更新
- **依存性注入**: テスト容易性の向上
- **ページネーションサポート**: 効率的なデータ読み込み

### コーディネーター
- **一元化されたナビゲーション管理**
- **子コーディネーターサポート**: 複雑なフロー向け
- **クリーンなビューコントローラー通信**
- **ディープリンク機能**: 将来の実装のための基盤

### 多言語サポート
- **英語**、**スペイン語**、**日本語**の完全なローカライゼーション
- エクステンションを通じた構造化された文字列管理
- 容易に拡張可能な抽象化されたローカライゼーションレイヤー

### エラー管理
- **ドメイン固有のエラータイプ** (NetworkError, RepositoryError)
- **ユーザーフレンドリーなメッセージによる優雅なエラー回復**
- **技術的エラーからユーザー向けエラーへの一元化されたマッピング**
- **一時的な障害に対するリトライメカニズム**

## テスト戦略

### ユニットテスト
- **すべてのレイヤーにわたる包括的なテストカバレッジ**
- **ネットワークサービスとリポジトリのモック実装**
- **分離テストを可能にするプロトコルベースの依存性注入**
- **ビューモデルの状態検証**

### テストカバレッジ
- **ビューモデル**: 状態遷移、エラー処理、データ変換
- **コーディネーター**: ナビゲーションフローと子コーディネーター管理
- **リポジトリ**: データ取得とエラー伝播
- **ネットワークレイヤー**: リクエスト処理、レスポンス解析、エラーケース

## ドキュメント
- **すべての公開インターフェースに対する包括的なインラインドキュメント**
- **コードナビゲーション向上のためのMARKアノテーション**
- **テスト実装におけるフレームワーク使用例**
- **READMEドキュメント** (このドキュメント)

## はじめ方

### 要件
- iOS 15.0+
- Xcode 14.0+
- Swift 5.5+

### インストール
1. リポジトリをクローン
2. Xcodeで `git-test.xcodeproj` を開く
3. プロジェクトをビルドして実行

### テストの実行
1. Xcodeでテストスキームを選択
2. Command+Uを押して全テストを実行

---

<a id="english"></a>
# GitHub Users Explorer

## Screenshots and videos
<img src="https://github.com/camyoh/Github-User-Search/blob/main/SupportFiles/video-gif.gif" width="300">

<img src="https://raw.githubusercontent.com/camyoh/Github-User-Search/main/SupportFiles/eng2.png" width="300"> <img src="https://raw.githubusercontent.com/camyoh/Github-User-Search/main/SupportFiles/eng1.png" width="300">

### Support for english, japanese, spanish
<img src="https://github.com/camyoh/Github-User-Search/blob/main/SupportFiles/jap4.png" width="300"> <img src="https://github.com/camyoh/Github-User-Search/blob/main/SupportFiles/jap3.png" width="300"> <img src="https://github.com/camyoh/Github-User-Search/blob/main/SupportFiles/jap2.png" width="300"> <img src="https://github.com/camyoh/Github-User-Search/blob/main/SupportFiles/jap1.png" width="300">


## Overview
A modern iOS application for exploring GitHub users, built with clean architecture, programmatic UI, and comprehensive test coverage. The app demonstrates best practices in iOS development with a focus on maintainability, scalability, and reliability.

## Architecture
The project implements a clean architecture approach using MVVM + Coordinator pattern, with strict adherence to SOLID principles:

### Core Architectural Components

- **MVVM (Model-View-ViewModel)**: Separation of UI (View), business logic (ViewModel), and data (Model)
- **Coordinator Pattern**: Decouples navigation logic from view controllers
- **Repository Pattern**: Provides a clean API for data access
- **Protocol-Oriented Design**: Enables dependency injection and testability
- **Programmatic UI**: No storyboards, all UI built programmatically for better version control and reusability

### SOLID Principles Implementation

1. **Single Responsibility Principle**: Each class has one responsibility (e.g., ViewModels manage only business logic)
2. **Open/Closed Principle**: Components are open for extension but closed for modification
3. **Liskov Substitution Principle**: Protocol implementations can be substituted without affecting system behavior
4. **Interface Segregation Principle**: Clients depend only on methods they use
5. **Dependency Inversion Principle**: High-level modules depend on abstractions, not concrete implementations

### Project Structure
```
git-test/
├── Features/                    # Application features organized by domain
│   ├── UsersList/               # User list feature
│   │   ├── View/                # UI components
│   │   └── ViewModel/           # View models
│   ├── UserDetail/              # User detail feature
│   │   ├── View/                # UI components
│   │   └── ViewModel/           # View models
│   └── WebView/                 # Web view for repositories
├── Coordinator/                 # Navigation coordinators
│   ├── Coordinator.swift        # Base coordinator protocol
│   ├── AppCoordinator.swift     # Main app coordinator
│   ├── UsersListCoordinator.swift # Users list flow
│   └── UserDetailCoordinator.swift # User detail flow
├── Common/                      # Shared functionality
│   ├── Extensions/              # Swift extensions
│   ├── Models/                  # Domain models
│   ├── Networking/              # Network services and repositories
│   └── Localization/            # Localization support
├── Resources/                   # App resources
│   ├── en.lproj/               # English localization
│   ├── es.lproj/               # Spanish localization
│   └── ja.lproj/               # Japanese localization
└── Application/                 # App lifecycle management
    ├── AppDelegate.swift
    └── SceneDelegate.swift
```

## Key Features

### Networking Layer
- **Protocol-based design** for easy testing and substitution
- **Generic functions** for type-safe API requests
- **Comprehensive error handling** with domain-specific error types
- **Async/await** implementation for modern concurrency

### View Models
- **State-based architecture** with clear state transitions
- **Unidirectional data flow** for predictable UI updates
- **Dependency injection** for better testability
- **Pagination support** for efficient data loading

### Coordinators
- **Centralized navigation management**
- **Child coordinator support** for complex flows
- **Clean view controller communication**
- **Deep linking capability** (foundation for future implementation)

### Multi-language Support
- Full localization for **English**, **Spanish**, and **Japanese**
- Structured string management through extensions
- Abstracted localization layer for easy expansion

### Error Management
- **Domain-specific error types** (NetworkError, RepositoryError)
- **Graceful error recovery** with user-friendly messages
- **Centralized error mapping** from technical to user-facing errors
- **Retry mechanisms** for transient failures

## Testing Strategy

### Unit Testing
- **Comprehensive test coverage** across all layers
- **Mock implementations** for network services and repositories
- **Protocol-based dependency injection** enabling isolated testing
- **State verification** for view models

### Test Coverage
- **ViewModels**: State transitions, error handling, and data transformation
- **Coordinators**: Navigation flow and child coordinator management
- **Repositories**: Data fetching and error propagation
- **Network Layer**: Request handling, response parsing, and error cases

## Documentation
- **Comprehensive inline documentation** on all public interfaces
- **MARK annotations** for improved code navigation
- **Framework usage examples** in test implementations
- **README documentation** (this document)

## Getting Started

### Requirements
- iOS 15.0+
- Xcode 14.0+
- Swift 5.5+

### Installation
1. Clone the repository
2. Open `git-test.xcodeproj` in Xcode
3. Build and run the project

### Running Tests
1. Select the test scheme in Xcode
2. Press Command+U to run all tests
