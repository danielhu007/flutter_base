# Flutter Base Template 🚀

English | [简体中文](README.md)

[//]: # "INTRO (This is a comment)"
An innovative Flutter hybrid app development template, designed for developers who "know both Web and native"!

> You can develop mobile apps like writing HTML/JS, and also use Flutter's native capabilities to create high-performance experiences. Whether you're a web frontend expert or a Flutter native developer, you can easily get started and quickly implement uniapp-style JS calls to native capabilities.
>
> This project's design philosophy references the hybrid development approach of **uniapp**, and the JSBridge mechanism is inspired by the **html5+** standard. With just one codebase, you can cover Android, iOS, Web, and Windows, helping your product launch at lightning speed!

## Why Choose This Template? 🌟

- **Develop Apps with HTML/JS Knowledge**: Web pages can directly call native APIs, zero barrier for frontend developers.
- **Full Access to Native Flutter Capabilities**: Supports all Flutter native components and ecosystem, balancing performance and experience.
- **Rapid JSBridge Integration**: References html5+ standards, JS directly calls plus.* native modules, develop like uniapp.
- **Multi-platform Unified Architecture**: One codebase covers Android, iOS, Web, Windows, greatly improving development efficiency.
- **Rich Examples and Documentation**: Built-in numerous demo pages and detailed development guides for quick onboarding.
- **Suitable for Individuals and Teams**: Whether for personal projects or enterprise applications, easy to master.

## Typical Scenarios

- Want to quickly develop apps using web technologies? Write HTML/JS directly, call native capabilities like plus.device, plus.networkinfo.
- Need high-performance native experience? Use Flutter components and ecosystem for ultimate smoothness.
- Hybrid development, progressive migration, web resource reuse, cross-platform unified experience, one-stop solution!

## Feature Overview 📋

*   [x] **Optimized folder structure** 📁
*   [x] **Customizable logging system** 📝
*   [x] **Testing with coverage** 🧪
*   [x] **WebView Bridge hybrid app system** - Core feature 🌉
*   [x] **File upload functionality** - Supports resumable upload, concurrent, pause/resume, progress notifications, etc. 📤
*   [x] **State management upgraded to Riverpod** 💧
*   [x] **Network layer refactoring** - Based on Dio 🌐
*   [x] **Routing system optimization** 🛣️
*   [x] **Microsoft Clarity integration** 📊
*   [x] **Multimedia features** - Audio playback, image selection, camera functionality 🎵📷
*   [x] **Device features** - Vibration, geolocation, device information 📱📍
*   [x] **File operations** - Compression/decompression, file read/write, SQLite 📦🗄️
*   [ ] **Visual effects to maintain user engagement** 🎨

## Table of Contents 📑

*   [What is this?](#what-is-this)
*   [When to use this?](#when-to-use-this)
*   [Getting Started](#getting-started)
    *   [Requirements](#requirements)
    *   [Installation](#installation)
    *   [Usage](#usage)
    *   [Workflow](#workflow)
*   [Details](#details)
    * [Folder Structure](#folder-structure)
    * [Logging System](#logging-system)
    * [WebView Bridge System](#webview-bridge-system)
    * [Architecture Optimization](#architecture-optimization)
* [Testing](#testing)
    * [Static Testing (Code Analysis)](#static-testing-code-analysis)
    * [Dynamic Testing (Unit, Widget, Integration)](#dynamic-testing-unit-widget-integration)
    * [Mock Objects](#mock-objects)
*   [Contributing](#contributing)
*   [License](#license)
*   [References](#references)
*   [Summary](#summary)

## What is this? 🤔

This project is a feature-rich Flutter base template focused on hybrid app development, especially the WebView Bridge system. It provides a complete infrastructure that you can customize and extend according to your needs. 🛠️

## Why use this? 🤔

This template provides a battle-tested Flutter app architecture, especially suitable for hybrid apps that need to integrate WebView content. It includes:

- **Complete WebView Bridge System**: Enables two-way communication between Flutter and Web content 🌉
- **Modular Design**: Clear code organization structure, easy to maintain and extend 🧩
- **Modern State Management**: Uses Riverpod for efficient state management 💧
- **Rich Device Feature Integration**: Geolocation, camera, file operations, etc. 📱📷🗄️
- **Optimized Network Layer**: Dio-based network request handling, supports caching and offline mode 🌐

Stop searching Google for architecture problems. I've done this work for you, providing a solid foundation you can start developing with right away. 🏗️

## Getting Started 🚀

The best way to get started with this project is to use AndroidStudio IDE. Since this is a Flutter/Dart project, please set up your development environment according to the [Flutter documentation](https://flutter.dev/docs). 💻

### Requirements ⚠️

* A project where you can add a README
* Basic [Markdown][about-markdown] knowledge (here's a [cheatsheet][markdown-cheatsheet])

### Installation 💿

Clone this repository to your computer using git.

```
git clone https://your-repository-url/flutter-base
```

### Usage 📖

1. Create the configuration file required for building the app `/assets/cfg/config.json`:

```json
 {
    "appName": "My App",

    "logLevel": "debug",
    "logColor": true,
    "logEmoji": false,

    "devicePreview": false
}
```

2. Create the environment variable file `/assets/cfg/.env`:

```env
# App configuration
APP_NAME=My App
DEVICE_PREVIEW=false
PRODUCTION_ERROR_WIDGET=true

# Microsoft Clarity configuration
CLARITY_PROJECT_ID=your_clarity_project_id
```

### Workflow 🔄

If you want to add content to the code, please follow this checklist:

**Create a new branch** 🌿
- Fork from `dev` branch
- Descriptive feature name

**Add commits** ✅
- Each commit must focus on one type of change
- Describe commit intent and add links in commit messages
- `flutter test` and `flutter analyze` must pass
- Rethink your changes, refactor if possible

**Merge Request** 📤
- Fill out the merge request after the branch is complete


## Details ℹ️

More detailed description of the project source code

### Folder Structure 📁

The Flutter project contains several main folders, let's break down this folder:

- `app/` - Application entry point, theme and routing 🏠
  - `router/` - Routing configuration and generator 🛣️
  - `theme/` - App theme and color scheme 🎨
  - `services/` - App-level services (like Clarity analytics) 🔧
- `features/` - Feature-based modules 🧩
  - `counter/` - Counter feature example (using Riverpod state management) 🔢
  - `home/` - Home page, contains all feature demo entries 🏠
  - `posts/` - Post-related features (models and repositories) 📝
- `models/` - Entities used in the app, usually implement conversion between JSON and objects 📊
- `network/` - Network layer implementation, based on Dio 🌐
- `repositories/` - Data access layer, using base controller pattern 🗃️
- `state/` - Global state management using Riverpod 💧
- `utils/` - Utilities including custom logger 🛠️
- `webview_bridge/` - Custom WebView Bridge module for hybrid app features 🌉
  - `plus_*.dart` - Various Plus module implementations ⚡
- `widgets/` - Reusable UI components 🧩

### Logging System 📝

For logging events, we use the [logger package](https://pub.dev/packages/logger). We customize the appearance of logs by editing [SimplePrinter](https://github.com/leisim/logger/blob/master/lib/src/printers/simple_printer.dart).
This is how we use different log levels:

- **verbose** - Most detailed information, data processing (requests, json parsing, etc.), used in Streams 🔍
- **debug** - More detailed information about processes that might help locate some errors 🐛
- **info** - General progress in user interactions and app flows ℹ️
- **warning** - Potentially harmful situations, indicating potential problems ⚠️
- **error** - Error situations that may still allow the app to continue running ❌
- **wtf** - Fatal failures that may cause the app to terminate 💥

### WebView Bridge System 🌉

This is a powerful hybrid app development system that allows deep integration between Flutter apps and Web content. The system provides a complete two-way communication mechanism, enabling Web content to call native functionality while Flutter can also send events and data to Web content. 🔄

> #### Design Philosophy
>
> The JSBridge mechanism of WebView Bridge references **html5+** and combines uniapp's modular calling approach. You can directly call Flutter-provided plus objects and native APIs through JS in Web pages, experiencing a development model similar to uniapp, reducing migration and learning costs.

#### System Architecture 🏗️

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter App   │◄──►│  WebView Bridge  │◄──►│   Web Content   │
│                 │    │                  │    │                 │
│  - UI Widgets   │    │  - JS Injection  │    │  - HTML/CSS/JS  │
│  - Native APIs  │    │  - Event System  │    │  - Plus Objects │
│  - State Mgmt   │    │  - Module Router │    │  - Bridge Calls │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

#### Core Components ⚙️

**1. WebViewBridge Widget (`lib/widgets/webview_bridge.dart`)**
- Unified WebView component, supports asset and http(s) page loading 📱
- Automatically injects JS Bridge and plus objects 💉
- Handles WebView lifecycle events ⏱️
- Supports modular loading, can selectively load specific PlusModules 🧩

**2. Plus Bridge Module System (`lib/webview_bridge/`)**
- `plus_bridge_base.dart` - Base module interface 📋
- `plus_module_registry.dart` - Module registration and routing 🗺️
- `plus_device.dart` - Device information module 📱
- `plus_events.dart` - Event system module 📡
- `plus_runtime.dart` - Runtime information module ⏱️
- `plus_webview_events.dart` - WebView event management 🌐
- `plus_audio.dart` - Audio playback module 🎵
- `plus_camera.dart` - Camera functionality module 📷
- `plus_gallery.dart` - Gallery functionality module 🖼️
- `plus_geolocation.dart` - Geolocation module 📍
- `plus_nativeObj.dart` - Native object module 🔧
- `plus_nativeUI.dart` - Native UI module 🎨
- `plus_navigator.dart` - Navigation module 🧭
- `plus_share.dart` - Share functionality module 📤
- `plus_sqlite.dart` - SQLite database module 🗄️
- `plus_zip.dart` - Compression/decompression module 📦
- `plus_io.dart` - File IO module 📁
- `plus_android.dart` - Android-specific features 🤖
- `plus_os.dart` - Operating system information 💻
- `plus_networkinfo.dart` - Network information 📶
- `plus_downloader.dart` - Download functionality ⬇️
- `plus_uploader.dart` - File upload functionality ⬆️

#### Supported Plus Modules 📚

**Device Module (`plus.device`) 📱**
```javascript
// Get device information
plus.device.model      // Device model
plus.device.vendor     // Device vendor
plus.device.uuid       // Device unique identifier
plus.device.imei       // IMEI (not available on Android 10+)
plus.device.imsi       // IMSI (not available on Android 10+)

// Device functionality
plus.device.beep(times)           // Beep 🔔
plus.device.dial(number, confirm) // Dial 📞
plus.device.vibrate(milliseconds) // Vibrate 📳
```

**Runtime Module (`plus.runtime`) ⏱️**
```javascript
// App information
plus.runtime.appid    // App package name
plus.runtime.version  // App version
plus.runtime.channel  // Release channel
plus.runtime.launcher // Launcher type
plus.runtime.origin   // App source

// App control
plus.runtime.quit()   // Exit app 🚪
```

**Events Module (`plus.events`) 📡**
```javascript
// Event listening
const callbackId = plus.events.addEventListener('eventName', callback);
plus.events.removeEventListener('eventName', callbackId);

// Event triggering
plus.events.fireEvent('eventName', data);
```

**Audio Module (`plus.audio`) 🎵**
```javascript
// Audio playback
plus.audio.play(url, options);      // Play audio ▶️
plus.audio.pause();                 // Pause playback ⏸️
plus.audio.resume();                // Resume playback ▶️
plus.audio.stop();                  // Stop playback ⏹️
plus.audio.setVolume(volume);       // Set volume 🔊
```

**Camera Module (`plus.camera`) 📷**
```javascript
// Camera functionality
plus.camera.captureImage(successCallback, errorCallback);   // Take photo 📸
plus.camera.captureVideo(successCallback, errorCallback);   // Record video 🎥
```

**Gallery Module (`plus.gallery`) 🖼️**
```javascript
// Gallery functionality
plus.gallery.pick(successCallback, errorCallback, options);  // Select image/video 📂
plus.gallery.save(path, successCallback, errorCallback);      // Save to gallery 💾
```

**Geolocation Module (`plus.geolocation`) 📍**
```javascript
// Geolocation functionality
plus.geolocation.getCurrentPosition(successCallback, errorCallback);  // Get current position 🗺️
plus.geolocation.watchPosition(successCallback, errorCallback);       // Watch position changes 🔄
plus.geolocation.clearWatch(watchId);                                // Stop watching ⏹️
```

**SQLite Module (`plus.sqlite`) 🗄️**
```javascript
// Database operations
plus.sqlite.openDatabase(name, successCallback, errorCallback);       // Open database 🔓
plus.sqlite.executeSql(sql, successCallback, errorCallback);          // Execute SQL ⚙️
plus.sqlite.transaction(callbacks);                                   // Transaction operations 🔄
```

**Zip Module (`plus.zip`) 📦**
```javascript
// Compression/decompression
plus.zip.compress(source, target, successCallback, errorCallback);     // Compress 🗜️
plus.zip.decompress(source, target, successCallback, errorCallback);   // Decompress 📂
```

**Share Module (`plus.share`) 📤**
```javascript
// Share functionality
plus.share.shareWithSystem(message, subject, url);    // System share 🔄
```

**IO Module (`plus.io`) 📁**
```javascript
// File operations
plus.io.readFile(path, successCallback, errorCallback);     // Read file 📖
plus.io.writeFile(path, data, successCallback, errorCallback); // Write file ✍️
plus.io.deleteFile(path, successCallback, errorCallback);   // Delete file 🗑️
```

**Uploader Module (`plus.uploader`) ⬆️**
```javascript
// Create upload task
var task = plus.uploader.createUpload(url, options, completedCB);

// Add file
task.addFile(path, {key: 'file', name: 'filename.jpg', mime: 'image/jpeg'});

// Add form data
task.addData('key', 'value');

// Set request headers
task.setRequestHeader('Authorization', 'Bearer token');

// Control upload
task.start();      // Start upload ▶️
task.pause();      // Pause upload ⏸️
task.resume();     // Resume upload ▶️
task.abort();      // Cancel upload ⏹️

// Listen to state changes
task.addEventListener('statechanged', function(upload, state) {
  console.log('Upload state:', state, 'Progress:', upload.uploadedSize + '/' + upload.totalSize);
});

// Enumerate upload tasks
plus.uploader.enumerate(state, function(tasks) {
  console.log('Upload task list:', tasks);
});

// Clear upload tasks
plus.uploader.clear(state);
```

**NativeUI Module (`plus.nativeUI`) 🎨**
```javascript
// Native UI
plus.nativeUI.alert(message, alertCallback, title, buttonName);  // Show alert ⚠️
plus.nativeUI.confirm(message, confirmCallback, title, buttons); // Confirm dialog ❓
plus.nativeUI.toast(message, options);                           // Toast notification 🍞
```

**Navigator Module (`plus.navigator`) 🧭**
```javascript
// Navigation functionality
plus.navigator.createWebView(url, options);    // Create WebView 🌐
plus.navigator.closeWebView();                 // Close WebView 🔙
```

#### Usage 🛠️

**1. Direct use of WebViewBridge** 📱
```dart
// Load asset page
WebViewBridge(url: 'assets/web/example/webview_events_demo.html')

// Load network page
WebViewBridge(url: 'https://example.com')
```

**2. Management through plus_webview module** 🧩
```dart
// Create WebView
final result = await webviewModule.handle('create', {
  'url': 'assets/web/example/webview_events_demo.html',
  'id': 'events_demo'
}, context);

// Show WebView
await webviewModule.handle('show', {
  'id': result['id']
}, context);
```

**3. Frontend JavaScript calls** 💻
```javascript
// Call device functionality
plus.device.vibrate(500);

// Get app information
console.log(plus.runtime.version);

// Listen to events
plus.events.addEventListener('customEvent', function(data) {
  console.log('Event received:', data);
});
```

#### Example Pages 📄

The project includes multiple example pages (`assets/web/example/`):
- `webview_events_demo.html` - Complete event demonstration 🎭
- `device.html` - Device functionality demonstration 📱
- `events.html` - Event system demonstration 📡
- `simple_test.html` - Simple test page 🧪
- `index.html` - Homepage 🏠
- `audio.html` - Audio playback demonstration 🎵
- `camera.html` - Camera functionality demonstration 📷
- `gallery.html` - Gallery functionality demonstration 🖼️
- `geolocation.html` - Geolocation demonstration 📍
- `sqlite.html` - SQLite database demonstration 🗄️
- `zip.html` - Compression/decompression demonstration 📦
- `share.html` - Share functionality demonstration 📤
- `nativeui.html` - Native UI demonstration 🎨
- `navigator.html` - Navigation functionality demonstration 🧭
- `io.html` - File IO demonstration 📁
- `android.html` - Android-specific features demonstration 🤖
- `uploader.html` - File upload functionality demonstration ⬆️
- `networkinfo_ping.html` - Real-time ping to a URL, showing latency and status colors, mobile-compatible, suitable for network quality testing.

#### Technical Features ⚙️

- **Unified Loading**: Handles asset and http(s) pages uniformly 🔄
- **Modular Design**: Extensible plus module system 🧩
- **Event-Driven**: Complete event listening and triggering mechanism 📡
- **Type Safety**: TypeScript-style JavaScript interfaces 🔒
- **Error Handling**: Comprehensive error handling and logging 🚨

### Architecture Optimization 🚀

The project has undergone multiple architecture optimizations to improve code quality, maintainability, and development efficiency. 📈

#### State Management Upgraded to Riverpod 💧

We have upgraded state management from Provider to Riverpod, a more modern and powerful state management solution. ⚡

**Main Improvements:**
- **Compile-time Safety**: Riverpod provides compile-time error checking, reducing runtime errors 🔒
- **Better Testing Support**: Easier unit testing and mocking 🧪
- **More Flexible Composition**: Can easily combine multiple Providers 🧩
- **Automatic Dependency Handling**: Automatically manages dependencies between Providers 🔄

**Implementation Files:**
- `lib/state/riverpod_providers.dart` - Riverpod Provider definitions 📋
- `lib/state/provider_initializer.dart` - Provider initialization logic ⚙️
- `lib/features/counter/providers/counter_provider.dart` - Counter state management example 🔢
- `lib/repositories/providers/repos_provider.dart` - Repository pattern Provider 🗃️

#### Microsoft Clarity Integration 📊

The project integrates Microsoft Clarity analytics tool to help developers understand user behavior and app usage. 📈

**Main Features:**
- **User Behavior Recording**: Records user operation paths in the app 👣
- **Heatmap Analysis**: Shows areas users most frequently click and interact with 🔥
- **Performance Monitoring**: Monitors app loading time and performance metrics ⏱️
- **Error Tracking**: Automatically records and reports errors in the app 🐛

**Configuration Method:**
1. Set `CLARITY_PROJECT_ID` in the `/assets/cfg/.env` file 🔧
2. Clarity is automatically initialized when the app starts 🚀
3. No additional code needed, Clarity automatically collects data in the background 📡

**Implementation Files:**
- `lib/app/services/clarity_service.dart` - Clarity service implementation 🛠️
- `lib/main.dart` - Clarity initialization 🏁

#### Network Layer Refactoring 🌐

We have comprehensively refactored the network layer, using Dio as the HTTP client, and added interceptors, caching, and offline mode support. 🔄

**Main Features:**
- **Unified HTTP Client**: Uses Dio to provide a unified network request interface 📡
- **Request Interceptors**: Automatically add authentication headers, handle errors and logging 🛡️
- **Response Interceptors**: Uniformly handle response data format and errors 📥
- **Network Caching**: Supports request result caching, reducing network requests 💾
- **Offline Mode**: Automatically switches to offline mode when network is unavailable 📶

**Implementation Files:**
- `lib/network/api_service.dart` - Network service core implementation 🧠
- `lib/network/network_service_provider.dart` - Network service Provider 📦
- `lib/network/connectivity_checker.dart` - Network connection check 🔍
- `lib/repositories/controllers/base_controller.dart` - Base controller update 🔄

#### Routing System Optimization 🛣️

We have optimized the routing system, reverting from annotation routing to the original routing system to improve stability and controllability. 🎯

**Main Features:**
- **Named Route Constants**: Use constants to define route names, avoiding spelling errors 🏷️
- **Route Guards**: Implement route access control 🚦
- **Route Transition Animations**: Custom page transition animations 🎬
- **Unified Route Management**: Centralized management of all route definitions 📋

**Implementation Files:**
- `lib/app/router/app_routes.dart` - Route constant definitions 📝
- `lib/app/router/route_generator.dart` - Route generation logic ⚙️
- `lib/app/router/app_router.dart` - Route configuration (retained for possible future annotation routing implementation) 🗂️

## Testing 🧪

### Static Testing (Code Analysis) 🔍

We have set up code analysis rules in this project to ensure code quality and common coding style. We use the [lint package](https://pub.dev/packages/lint), where you can find all enabled [rules](https://github.com/passsy/dart-lint/blob/master/lib/analysis_options.yaml).
This package follows [Effective Dart](https://dart.dev/guides/language/effective-dart),
where you can learn more about how to properly use Dart. 📚

Code analysis configuration can be found in the `analysis_options.yaml` file. We keep the lint package rules almost unchanged,
we just add stricter severity to them. During CI/CD, all severities are treated as errors. ⚠️
Therefore, you can compile code with **warnings** or **hints**, but the final production code must have no rule violations! 🚫

`flutter analyze` runs the analyzer/linter and checks the code for lint rule violations 📊

### Dynamic Testing (Unit, Widget, Integration) 🏃‍♂️

There are 3 basic types of dynamic testing in Flutter projects. Unit and widget tests can be found in the `/test` folder. Integration tests are in the `/test_driver` folder. Use the links to learn more about [Flutter Testing](https://flutter.dev/docs/testing). 📖

Some components need to behave differently during testing. Usually components that perform some network communication (which fails in tests).
To get exposure to this information inside a component, use `Test.of(context).isTested` 🔬

- `flutter test` runs unit and widget tests on PC (no device needed) 💻
- `flutter run [pathToTestFile]` runs widget tests on a connected device, suitable for debugging tests 📱
- `flutter drive --target=test_driver/app.dart` runs integration tests on a connected device 🚗
- `./coverage.sh` runs test coverage for unit and widget tests and generates a report using LCOV 📈

### Mock Objects 🎭

We use the [mockito package](https://pub.dev/packages/mockito) to mock objects. Define the mock objects you want to generate in `test/mocks/mockito.dart`, then generate them by running: ⚙️

`flutter pub run build_runner build` 🏗️

## Contributing 🤝

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change. 💬

Please make sure to update tests as appropriate. 🧪

## License 📄
[MIT](https://choosealicense.com/licenses/mit/)

## References 📚

[react-markdown][react-markdown] - Project that inspired this README 💡

[//]: # "Source definitions"
[react-markdown]: https://github.com/remarkjs/react-markdown "React-markdown project"

## Summary 🎯

To summarize.. 📝

We have a feature-rich Flutter base template project from which we can build our projects faster and easier. 🚀
The project has undergone multiple architecture optimizations, including state management upgrade to Riverpod, network layer refactoring, and routing system optimization,
all of which provide a solid foundation for developing high-quality, maintainable Flutter apps. 🏗️

Especially the newly added WebView Bridge system provides powerful infrastructure for hybrid app development, enabling developers to: 🌉

- **Seamlessly Integrate Web Content**: Through the WebView Bridge system, Flutter apps can deeply interact with Web content 🔄
- **Reuse Existing Web Resources**: Existing web apps or web pages can be directly integrated into Flutter apps 🔄
- **Unified User Experience**: Provide flexibility of Web content while maintaining native app performance ⚡
- **Modular Functionality Extension**: Easily add new device features and APIs through the Plus module system 🧩

This template is not just a starting point, but a complete solution, especially suitable for teams and individual developers who need to quickly develop hybrid app scenarios. 🎉