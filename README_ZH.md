# Wallhaven Flutter

[English](README.md) | [中文](README_ZH.md)

一个基于 Flutter 构建的跨平台 Wallhaven 客户端，支持 Android、iOS、Windows、Linux 和 Web。

基于 [Wallhaven API](https://wallhaven.cc/help/api) 开发，灵感来源于 [leoFitz1024/wallhaven](https://github.com/leoFitz1024/wallhaven)。

## 功能特性

-   **浏览壁纸**：以瀑布流布局查看最新、热门和榜单壁纸。
-   **搜索与筛选**：
    -   关键词搜索。
    -   **分类筛选**：普通 (General)、动漫 (Anime)、人物 (People)。
    -   **纯净度筛选**：安全 (SFW)、擦边 (Sketchy)、R18 (NSFW)。
    -   **排序方式**：按日期、相关度、浏览量、收藏数、排行榜等排序。
-   **壁纸详情**：查看高清大图及元数据（分辨率、大小、标签）。
-   **下载功能**：保存壁纸到本地设备（移动端保存至相册，桌面端保存至下载文件夹）。
-   **设置**：
    -   **API Key 支持**：登录 Wallhaven API Key 以访问 NSFW 内容和用户设置。
    -   **主题切换**：支持浅色、深色及跟随系统主题。
    -   **多语言支持**：支持英文和中文切换。

## 截图

*(此处添加截图)*

## 快速开始

### 前置要求

-   [Flutter SDK](https://flutter.cn/docs/get-started/install)
-   [Dart SDK](https://dart.cn/get-dart)

### 安装步骤

1.  **克隆仓库**

    ```bash
    git clone https://github.com/candy-blue/wallhaven_flutter.git
    cd wallhaven_flutter
    ```

2.  **安装依赖**

    ```bash
    flutter pub get
    ```

3.  **生成本地化文件**

    ```bash
    flutter gen-l10n
    ```

4.  **运行应用**

    ```bash
    # 在 Windows 上运行
    flutter run -d windows

    # 在 Android 上运行
    flutter run -d android
    ```

## 项目结构

```
lib/
├── api/            # API 客户端 (Dio)
├── l10n/           # 本地化文件 (.arb)
├── models/         # 数据模型
├── providers/      # 状态管理 (Provider)
├── screens/        # UI 页面 (主页, 详情页, 设置页)
├── widgets/        # 可复用组件
└── main.dart       # 程序入口
```

## 主要依赖

-   `dio`: HTTP 网络请求。
-   `provider`: 状态管理。
-   `cached_network_image`: 图片缓存加载。
-   `flutter_staggered_grid_view`: 瀑布流布局。
-   `shared_preferences`: 本地设置存储。
-   `gallery_saver`: 保存图片到相册。
-   `intl`: 国际化支持。

## 许可证

本项目基于 MIT 许可证开源 - 详见 LICENSE 文件。
