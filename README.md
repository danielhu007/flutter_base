# Flutter 基础模板 🚀

[English](README.en.md) | 简体中文

[//]: # "INTRO (这是一个注释)"
一个极具创新力的 Flutter 混合应用开发模板，专为“既懂 Web，又会原生”的开发者打造！

> 你可以像写 HTML/JS 一样开发移动应用，也能用 Flutter 原生能力打造高性能体验。无论你是 Web 前端高手，还是 Flutter 原生开发者，都能轻松上手，快速实现 uniapp 式 JS 调用原生能力。
>
> 本项目设计理念参考了 **uniapp** 的混合开发思路，JSBridge 机制借鉴了 **html5+** 标准。只需一套代码，即可覆盖 Android、iOS、Web、Windows 多端，助力你的产品极速上线！

## 为什么选择本模板？🌟

- **会写 HTML/JS 就能做 App**：Web 页面可直接调用原生 API，前端开发者零门槛上手。
- **原生 Flutter 能力全开放**：支持所有 Flutter 原生组件和生态，性能与体验兼得。
- **JSBridge 极速集成**：参考 html5+ 标准，JS 直接调用 plus.* 原生模块，像 uniapp 一样开发。
- **多端统一架构**：一套代码，覆盖 Android、iOS、Web、Windows，极大提升开发效率。
- **丰富示例与文档**：内置大量演示页面和详细开发指南，快速上手无压力。
- **适合个人与团队**：无论是个人项目还是企业级应用，都能轻松驾驭。

## 典型场景

- 想用 Web 技术快速开发 App？直接写 HTML/JS，调用 plus.device、plus.networkinfo 等原生能力。
- 需要高性能原生体验？用 Flutter 组件和生态，享受极致流畅。
- 混合开发、渐进式迁移、Web 资源复用、跨端统一体验，一站式解决！

## 功能概览 📋

*   [x] **优化的文件夹结构** 📁
*   [x] **可自定义的日志系统** 📝
*   [x] **带覆盖率的测试** 🧪
*   [x] **WebView Bridge 混合应用系统** - 核心功能 🌉
*   [x] **文件上传功能** - 支持断点续传、并发、暂停/恢复、进度通知等 📤
*   [x] **状态管理升级到Riverpod** 💧
*   [x] **网络层重构** - 基于Dio 🌐
*   [x] **路由系统优化** 🛣️
*   [x] **Microsoft Clarity 集成** 📊
*   [x] **多媒体功能** - 音频播放、图片选择、相机功能 🎵📷
*   [x] **设备功能** - 震动、地理位置、设备信息 📱📍
*   [x] **文件操作** - 压缩解压、文件读写、SQLite 📦🗄️
*   [ ] **保持用户参与度的视觉效果** 🎨

## 目录 📑

*   [这是什么？](#这是什么)
*   [什么时候使用这个？](#什么时候使用这个)
*   [开始使用](#开始使用)
    *   [要求](#要求)
    *   [安装](#安装)
    *   [使用方法](#使用方法)
    *   [工作流程](#工作流程)
*   [详细信息](#详细信息)
    * [文件夹结构](#文件夹结构)
    * [日志系统](#日志系统)
    * [WebView Bridge 系统](#webview-bridge-系统)
    * [架构优化](#架构优化)
* [测试](#测试)
    * [静态测试（代码检查）](#静态测试代码检查)
    * [动态测试（单元、组件、集成）](#动态测试单元组件集成)
    * [模拟对象](#模拟对象)
*   [贡献](#贡献)
*   [许可证](#许可证)
*   [参考资料](#参考资料)
*   [总结](#总结)

## 这是什么？ 🤔

这个项目是一个功能丰富的 Flutter 基础模板，专注于混合应用开发，特别是 WebView Bridge 系统。它提供了一个完整的基础架构，你可以根据需要进行自定义和扩展。🛠️

## 为什么要使用这个？ 🤔

这个模板提供了一个经过实战检验的 Flutter 应用架构，特别适合需要集成 WebView 内容的混合应用。它包含了：

- **完整的 WebView Bridge 系统**：实现 Flutter 与 Web 内容的双向通信 🌉
- **模块化设计**：清晰的代码组织结构，易于维护和扩展 🧩
- **现代状态管理**：使用 Riverpod 进行高效的状态管理 💧
- **丰富的设备功能集成**：地理位置、相机、文件操作等 📱📷🗄️
- **优化的网络层**：基于 Dio 的网络请求处理，支持缓存和离线模式 🌐

不要再在 Google 上搜索架构问题了。我已经为你做了这些工作，提供了一个可以直接开始开发的坚实基础。🏗️

## 开始使用 🚀

开始使用这个项目的最佳方式是使用 AndroidStudio IDE。由于这是一个
Flutter/Dart 项目，请按照 [Flutter 文档](https://flutter.dev/docs) 设置你的开发环境。💻

### 要求 ⚠️

* 准备一个可以添加 README 的项目
* 基本的 [Markdown][about-markdown] 知识（这里是 [速查表][markdown-cheatsheet]）

### 安装 💿

使用 git 将此仓库克隆到你的计算机中。

```
git clone https://your-repository-url/flutter-base
```

### 使用方法 📖

1. 创建构建应用所需的配置文件 `/assets/cfg/config.json`：

```json
 {
    "appName": "我的应用",

    "logLevel": "debug",
    "logColor": true,
    "logEmoji": false,

    "devicePreview": false
}
```

2. 创建环境变量文件 `/assets/cfg/.env`：

```env
# 应用配置
APP_NAME=我的应用
DEVICE_PREVIEW=false
PRODUCTION_ERROR_WIDGET=true

# Microsoft Clarity 配置
CLARITY_PROJECT_ID=your_clarity_project_id
```

### 工作流程 🔄

如果你想向代码中添加内容，请遵循此检查清单：

**创建新分支** 🌿
- 从 `dev` 分支派生
- 描述性功能名称

**添加提交** ✅
- 每个提交必须专注于一种类型的变化
- 在提交消息中描述提交意图并添加链接
- `flutter test` 和 `flutter analyze` 必须通过
- 重新考虑你的更改，如果可能的话进行重构

**合并请求** 📤
- 分支完成后填写合并请求


## 详细信息 ℹ️

项目源代码的更详细描述

### 文件夹结构 📁

Flutter 项目包含多个主要文件夹，让我们分解这个文件夹：

- `app/` - 应用程序入口点、主题和路由 🏠
  - `router/` - 路由配置和生成器 🛣️
  - `theme/` - 应用主题和颜色方案 🎨
  - `services/` - 应用级服务（如Clarity分析） 🔧
- `features/` - 基于功能的模块 🧩
  - `counter/` - 计数器功能示例（使用Riverpod状态管理）🔢
  - `home/` - 主页面，包含所有功能演示入口 🏠
  - `posts/` - 文章相关功能（模型和仓库）📝
- `models/` - 应用中使用的实体，通常实现 JSON 和对象之间的转换 📊
- `network/` - 网络层实现，基于Dio 🌐
- `repositories/` - 数据访问层，使用基础控制器模式 🗃️
- `state/` - 使用 Riverpod 的全局状态管理 💧
- `utils/` - 包括自定义日志记录器的实用工具 🛠️
- `webview_bridge/` - 用于混合应用功能的自定义 WebView Bridge 模块 🌉
  - `plus_*.dart` - 各种Plus模块实现 ⚡
- `widgets/` - 可重用的 UI 组件 🧩

### 日志系统 📝

对于日志事件，我们使用 [logger 包](https://pub.dev/packages/logger)。我们通过编辑 [SimplePrinter](https://github.com/leisim/logger/blob/master/lib/src/printers/simple_printer.dart) 来自定义日志的外观。
这是我们使用不同日志级别的方式：

- **verbose** - 最详细的细节，数据处理（请求、json 解析等），在 Streams 中使用 🔍
- **debug** - 关于可能帮助定位某些错误的进程的更详细信息 🐛
- **info** - 捕获用户交互和应用流程中的一般进度 ℹ️
- **warning** - 潜在有害的情况，表明潜在问题 ⚠️
- **error** - 可能仍允许应用继续运行的错误情况 ❌
- **wtf** - 可能导致应用程序终止的致命故障 💥

### WebView Bridge 系统 🌉

这是一个强大的混合应用开发系统，允许 Flutter 应用与 Web 内容进行深度集成。系统提供了完整的双向通信机制，使 Web 内容能够调用原生功能，同时 Flutter 也能向 Web 内容发送事件和数据。🔄

> #### 设计理念
>
> WebView Bridge 的 JSBridge 机制参考了 **html5+**，并结合 uniapp 的模块化调用方式。你可以在 Web 页面中通过 JS 直接调用 Flutter 提供的 plus 对象和原生 API，体验与 uniapp 类似的开发模式，降低迁移和学习成本。

#### 系统架构 🏗️

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter App   │◄──►│  WebView Bridge  │◄──►│   Web Content   │
│                 │    │                  │    │                 │
│  - UI Widgets   │    │  - JS Injection  │    │  - HTML/CSS/JS  │
│  - Native APIs  │    │  - Event System  │    │  - Plus Objects │
│  - State Mgmt   │    │  - Module Router │    │  - Bridge Calls │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

#### 核心组件 ⚙️

**1. WebViewBridge Widget (`lib/widgets/webview_bridge.dart`)**
- 统一的 WebView 组件，支持 asset 和 http(s) 页面加载 📱
- 自动注入 JS Bridge 和 plus 对象 💉
- 处理 WebView 生命周期事件 ⏱️
- 支持模块化加载，可选择性加载特定PlusModule 🧩

**2. Plus Bridge 模块系统 (`lib/webview_bridge/`)**
- `plus_bridge_base.dart` - 基础模块接口 📋
- `plus_module_registry.dart` - 模块注册和路由 🗺️
- `plus_device.dart` - 设备信息模块 📱
- `plus_events.dart` - 事件系统模块 📡
- `plus_runtime.dart` - 运行时信息模块 ⏱️
- `plus_webview_events.dart` - WebView 事件管理 🌐
- `plus_audio.dart` - 音频播放模块 🎵
- `plus_camera.dart` - 相机功能模块 📷
- `plus_gallery.dart` - 图库功能模块 🖼️
- `plus_geolocation.dart` - 地理位置模块 📍
- `plus_nativeObj.dart` - 原生对象模块 🔧
- `plus_nativeUI.dart` - 原生UI模块 🎨
- `plus_navigator.dart` - 导航模块 🧭
- `plus_share.dart` - 分享功能模块 📤
- `plus_sqlite.dart` - SQLite数据库模块 🗄️
- `plus_zip.dart` - 压缩解压模块 📦
- `plus_io.dart` - 文件IO模块 📁
- `plus_android.dart` - Android特定功能 🤖
- `plus_os.dart` - 操作系统信息 💻
- `plus_networkinfo.dart` - 网络信息 📶
- `plus_downloader.dart` - 下载功能 ⬇️
- `plus_uploader.dart` - 文件上传功能 ⬆️

#### 支持的 Plus 模块 📚

**Device 模块 (`plus.device`) 📱**
```javascript
// 获取设备信息
plus.device.model      // 设备型号
plus.device.vendor     // 设备厂商
plus.device.uuid       // 设备唯一标识
plus.device.imei       // IMEI（Android 10+ 不可用）
plus.device.imsi       // IMSI（Android 10+ 不可用）

// 设备功能
plus.device.beep(times)           // 蜂鸣 🔔
plus.device.dial(number, confirm) // 拨号 📞
plus.device.vibrate(milliseconds) // 震动 📳
```

**Runtime 模块 (`plus.runtime`) ⏱️**
```javascript
// 应用信息
plus.runtime.appid    // 应用包名
plus.runtime.version  // 应用版本
plus.runtime.channel  // 发布渠道
plus.runtime.launcher // 启动器类型
plus.runtime.origin   // 应用来源

// 应用控制
plus.runtime.quit()   // 退出应用 🚪
```

**Events 模块 (`plus.events`) 📡**
```javascript
// 事件监听
const callbackId = plus.events.addEventListener('eventName', callback);
plus.events.removeEventListener('eventName', callbackId);

// 事件触发
plus.events.fireEvent('eventName', data);
```

**Audio 模块 (`plus.audio`) 🎵**
```javascript
// 音频播放
plus.audio.play(url, options);      // 播放音频 ▶️
plus.audio.pause();                 // 暂停播放 ⏸️
plus.audio.resume();                // 恢复播放 ▶️
plus.audio.stop();                  // 停止播放 ⏹️
plus.audio.setVolume(volume);       // 设置音量 🔊
```

**Camera 模块 (`plus.camera`) 📷**
```javascript
// 相机功能
plus.camera.captureImage(successCallback, errorCallback);   // 拍照 📸
plus.camera.captureVideo(successCallback, errorCallback);   // 录像 🎥
```

**Gallery 模块 (`plus.gallery`) 🖼️**
```javascript
// 图库功能
plus.gallery.pick(successCallback, errorCallback, options);  // 选择图片/视频 📂
plus.gallery.save(path, successCallback, errorCallback);      // 保存到图库 💾
```

**Geolocation 模块 (`plus.geolocation`) 📍**
```javascript
// 地理位置功能
plus.geolocation.getCurrentPosition(successCallback, errorCallback);  // 获取当前位置 🗺️
plus.geolocation.watchPosition(successCallback, errorCallback);       // 监听位置变化 🔄
plus.geolocation.clearWatch(watchId);                                // 停止监听 ⏹️
```

**SQLite 模块 (`plus.sqlite`) 🗄️**
```javascript
// 数据库操作
plus.sqlite.openDatabase(name, successCallback, errorCallback);       // 打开数据库 🔓
plus.sqlite.executeSql(sql, successCallback, errorCallback);          // 执行SQL ⚙️
plus.sqlite.transaction(callbacks);                                   // 事务操作 🔄
```

**Zip 模块 (`plus.zip`) 📦**
```javascript
// 压缩解压
plus.zip.compress(source, target, successCallback, errorCallback);     // 压缩 🗜️
plus.zip.decompress(source, target, successCallback, errorCallback);   // 解压 📂
```

**Share 模块 (`plus.share`) 📤**
```javascript
// 分享功能
plus.share.shareWithSystem(message, subject, url);    // 系统分享 🔄
```

**IO 模块 (`plus.io`) 📁**
```javascript
// 文件操作
plus.io.readFile(path, successCallback, errorCallback);     // 读取文件 📖
plus.io.writeFile(path, data, successCallback, errorCallback); // 写入文件 ✍️
plus.io.deleteFile(path, successCallback, errorCallback);   // 删除文件 🗑️
```

**Uploader 模块 (`plus.uploader`) ⬆️**
```javascript
// 创建上传任务
var task = plus.uploader.createUpload(url, options, completedCB);

// 添加文件
task.addFile(path, {key: 'file', name: 'filename.jpg', mime: 'image/jpeg'});

// 添加表单数据
task.addData('key', 'value');

// 设置请求头
task.setRequestHeader('Authorization', 'Bearer token');

// 控制上传
task.start();      // 开始上传 ▶️
task.pause();      // 暂停上传 ⏸️
task.resume();     // 恢复上传 ▶️
task.abort();      // 取消上传 ⏹️

// 监听状态变化
task.addEventListener('statechanged', function(upload, state) {
  console.log('上传状态:', state, '进度:', upload.uploadedSize + '/' + upload.totalSize);
});

// 枚举上传任务
plus.uploader.enumerate(state, function(tasks) {
  console.log('上传任务列表:', tasks);
});

// 清除上传任务
plus.uploader.clear(state);
```

**NativeUI 模块 (`plus.nativeUI`) 🎨**
```javascript
// 原生UI
plus.nativeUI.alert(message, alertCallback, title, buttonName);  // 弹出提示 ⚠️
plus.nativeUI.confirm(message, confirmCallback, title, buttons); // 确认对话框 ❓
plus.nativeUI.toast(message, options);                           // Toast提示 🍞
```

**Navigator 模块 (`plus.navigator`) 🧭**
```javascript
// 导航功能
plus.navigator.createWebView(url, options);    // 创建WebView 🌐
plus.navigator.closeWebView();                 // 关闭WebView 🔙
```

#### 使用方法 🛠️

**1. 直接使用 WebViewBridge** 📱
```dart
// 加载 asset 页面
WebViewBridge(url: 'assets/web/example/webview_events_demo.html')

// 加载网络页面
WebViewBridge(url: 'https://example.com')
```

**2. 通过 plus_webview 模块管理** 🧩
```dart
// 创建 WebView
final result = await webviewModule.handle('create', {
  'url': 'assets/web/example/webview_events_demo.html',
  'id': 'events_demo'
}, context);

// 显示 WebView
await webviewModule.handle('show', {
  'id': result['id']
}, context);
```

**3. 前端 JavaScript 调用** 💻
```javascript
// 调用设备功能
plus.device.vibrate(500);

// 获取应用信息
console.log(plus.runtime.version);

// 监听事件
plus.events.addEventListener('customEvent', function(data) {
  console.log('收到事件:', data);
});
```

#### 示例页面 📄

项目包含多个示例页面（`assets/web/example/`）：
- `webview_events_demo.html` - 完整的事件演示 🎭
- `device.html` - 设备功能演示 📱
- `events.html` - 事件系统演示 📡
- `simple_test.html` - 简单测试页面 🧪
- `index.html` - 主页 🏠
- `audio.html` - 音频播放演示 🎵
- `camera.html` - 相机功能演示 📷
- `gallery.html` - 图库功能演示 🖼️
- `geolocation.html` - 地理位置演示 📍
- `sqlite.html` - SQLite数据库演示 🗄️
- `zip.html` - 压缩解压演示 📦
- `share.html` - 分享功能演示 📤
- `nativeui.html` - 原生UI演示 🎨
- `navigator.html` - 导航功能演示 🧭
- `io.html` - 文件IO演示 📁
- `android.html` - Android特定功能演示 🤖
- `uploader.html` - 文件上传功能演示 ⬆️
- `networkinfo_ping.html` - 实时 Ping 某 URL，显示延迟和状态颜色，兼容手机端，适合网络质量测试。

#### 技术特性 ⚙️

- **统一加载**：asset 和 http(s) 页面统一处理 🔄
- **模块化设计**：可扩展的 plus 模块系统 🧩
- **事件驱动**：完整的事件监听和触发机制 📡
- **类型安全**：TypeScript 风格的 JavaScript 接口 🔒
- **错误处理**：完善的错误处理和日志记录 🚨

### 架构优化 🚀

项目已经进行了多项架构优化，以提高代码质量、可维护性和开发效率。📈

#### 状态管理升级到Riverpod 💧

我们将状态管理从Provider升级到了Riverpod，这是一个更现代、更强大的状态管理解决方案。⚡

**主要改进：**
- **编译时安全**：Riverpod提供编译时错误检查，减少运行时错误 🔒
- **更好的测试支持**：更容易进行单元测试和模拟 🧪
- **更灵活的组合**：可以轻松组合多个Provider 🧩
- **自动处理依赖**：自动管理Provider之间的依赖关系 🔄

**实现文件：**
- `lib/state/riverpod_providers.dart` - Riverpod Provider定义 📋
- `lib/state/provider_initializer.dart` - Provider初始化逻辑 ⚙️
- `lib/features/counter/providers/counter_provider.dart` - Counter状态管理示例 🔢
- `lib/repositories/providers/repos_provider.dart` - 仓库模式Provider 🗃️

#### Microsoft Clarity 集成 📊

项目集成了Microsoft Clarity分析工具，帮助开发者了解用户行为和应用使用情况。📈

**主要功能：**
- **用户行为记录**：记录用户在应用中的操作路径 👣
- **热图分析**：显示用户最常点击和交互的区域 🔥
- **性能监控**：监控应用加载时间和性能指标 ⏱️
- **错误追踪**：自动记录和报告应用中的错误 🐛

**配置方法：**
1. 在`/assets/cfg/.env`文件中设置`CLARITY_PROJECT_ID` 🔧
2. 应用启动时会自动初始化Clarity 🚀
3. 无需额外代码，Clarity会在后台自动收集数据 📡

**实现文件：**
- `lib/app/services/clarity_service.dart` - Clarity服务实现 🛠️
- `lib/main.dart` - Clarity初始化 🏁

#### 网络层重构 🌐

我们对网络层进行了全面重构，使用Dio作为HTTP客户端，并添加了拦截器、缓存和离线模式支持。🔄

**主要特性：**
- **统一HTTP客户端**：使用Dio提供统一的网络请求接口 📡
- **请求拦截器**：自动添加认证头、处理错误和日志记录 🛡️
- **响应拦截器**：统一处理响应数据格式和错误 📥
- **网络缓存**：支持请求结果缓存，减少网络请求 💾
- **离线模式**：在网络不可用时自动切换到离线模式 📶

**实现文件：**
- `lib/network/api_service.dart` - 网络服务核心实现 🧠
- `lib/network/network_service_provider.dart` - 网络服务Provider 📦
- `lib/network/connectivity_checker.dart` - 网络连接检查 🔍
- `lib/repositories/controllers/base_controller.dart` - 基础控制器更新 🔄

#### 路由系统优化 🛣️

我们优化了路由系统，从注解路由回退到原始路由系统，以提高稳定性和可控性。🎯

**主要特性：**
- **命名路由常量**：使用常量定义路由名称，避免拼写错误 🏷️
- **路由守卫**：实现路由访问控制 🚦
- **路由过渡动画**：自定义页面切换动画 🎬
- **统一路由管理**：集中管理所有路由定义 📋

**实现文件：**
- `lib/app/router/app_routes.dart` - 路由常量定义 📝
- `lib/app/router/route_generator.dart` - 路由生成逻辑 ⚙️
- `lib/app/router/app_router.dart` - 路由配置（保留用于将来可能的注解路由实现）🗂️

## 测试 🧪

### 静态测试（代码检查）🔍

我们在此项目中设置了代码检查规则，以确保代码质量和通用编码风格。我们
使用 [lint 包](https://pub.dev/packages/lint)，你可以在其中找到所有启用的 [规则](https://github.com/passsy/dart-lint/blob/master/lib/analysis_options.yaml)。
该包遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart)，
你可以在其中了解更多关于如何正确使用 Dart 的信息。📚

代码检查配置可以在 `analysis_options.yaml` 文件中找到。我们几乎保持 lint 包规则不变，
我们只是为它们添加更严格的严重性。在 CI/CD 期间，所有严重性都被视为错误。⚠️
因此，你可以使用**警告**或**提示**编译代码，但最终的生产代码必须没有任何规则违规！🚫

`flutter analyze` 运行分析器/代码检查器并检查代码的代码检查规则违规 📊

### 动态测试（单元、组件、集成）🏃‍♂️

在 Flutter 项目中有 3 种基本类型的动态测试。单元和组件测试可以在
`/test` 文件夹中找到。集成测试在 `/test_driver` 文件夹中。使用链接了解更多关于
[Flutter 测试](https://flutter.dev/docs/testing) 的信息。📖

某些组件在测试期间需要表现不同。通常是执行某些网络通信的组件（在测试中失败）。
要在组件内部获得此信息的暴露，请使用
`Test.of(context).isTested` 🔬

- `flutter test` 在 PC 上运行单元和组件测试（不需要设备） 💻
- `flutter run [pathToTestFile]` 在连接的设备上运行组件测试，适合调试测试 📱
- `flutter drive --target=test_driver/app.dart` 在连接的设备上运行集成测试 🚗
- `./coverage.sh` 运行单元和组件测试的测试覆盖率，并使用 LCOV 生成报告 📈

### 模拟对象 🎭

我们使用 [mockito 包](https://pub.dev/packages/mockito) 来模拟对象。在 `test/mocks/mockito.dart` 中定义
你想要生成的模拟对象，然后通过运行以下命令生成它们：⚙️

`flutter pub run build_runner build` 🏗️

## 贡献 🤝

欢迎 Pull requests。对于重大更改，请先打开一个 issue 来讨论你想要更改的内容。💬

请确保适当更新测试。🧪

## 许可证 📄
[MIT](https://choosealicense.com/licenses/mit/)

## 参考资料 📚

[react-markdown][react-markdown] - 作为此 README 灵感的项目 💡

[//]: # "源定义"
[react-markdown]: https://github.com/remarkjs/react-markdown "React-markdown 项目"

## 总结 🎯

总结一下.. 📝

我们有一个功能丰富的 Flutter 基础模板项目，从中我们可以更快更容易地构建我们的项目。🚀
项目已经进行了多项架构优化，包括状态管理升级到Riverpod、网络层重构和路由系统优化，
这些都为开发高质量、可维护的Flutter应用提供了坚实的基础。🏗️

特别是新增的 WebView Bridge 系统，为混合应用开发提供了强大的基础设施，使开发者能够：🌉

- **无缝集成Web内容**：通过WebView Bridge系统，Flutter应用可以与Web内容进行深度交互 🔄
- **复用现有Web资源**：可以将现有的Web应用或网页直接集成到Flutter应用中 🔄
- **统一用户体验**：在保持原生应用性能的同时，提供Web内容的灵活性 ⚡
- **模块化功能扩展**：通过Plus模块系统，可以轻松添加新的设备功能和API 🧩

这个模板不仅是一个起点，更是一个完整的解决方案，特别适合需要快速开发混合应用场景的团队和个人开发者。🎉
