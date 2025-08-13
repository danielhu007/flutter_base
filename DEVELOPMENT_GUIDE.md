# Flutter Base 开发者指南

## 目录

1. [项目概述](#项目概述)
2. [环境搭建](#环境搭建)
3. [项目结构](#项目结构)
4. [开发流程](#开发流程)
5. [核心功能](#核心功能)
6. [WebView 桥接系统](#webview-桥接系统)
7. [状态管理](#状态管理)
8. [网络请求](#网络请求)
9. [数据存储](#数据存储)
10. [测试](#测试)
11. [构建和部署](#构建和部署)
12. [最佳实践](#最佳实践)
13. [故障排除](#故障排除)

---

## 项目概述

Flutter Base 是一个功能丰富的 Flutter 移动应用模板，采用现代化的架构设计，支持多平台开发（Android、iOS、Web、Windows）。项目集成了 WebView 桥接系统，支持混合应用开发，提供了丰富的设备 API 和 UI 组件。

### 主要特性

- **跨平台支持**: 支持 Android、iOS、Web 和 Windows 平台
- **WebView 桥接系统**: 实现 JavaScript 与原生代码的通信
- **状态管理**: 使用 Riverpod 进行状态管理
- **网络请求**: 集成 Dio 进行 HTTP 请求
- **数据存储**: 支持 SQLite 数据库
- **设备功能**: 集成设备信息、地理位置、相机、音频等功能
- **UI 组件**: 提供丰富的 UI 组件和主题系统
- **日志系统**: 自定义日志记录器
- **代码生成**: 使用 json_annotation 进行 JSON 序列化

---

## 环境搭建

### 1. 前置要求

- **Flutter SDK**: 版本 >= 3.19.0
- **Dart SDK**: 版本 >= 3.3.0 < 4.0.0
- **Android Studio** 或 **VS Code**（推荐）
- **Android SDK**（用于 Android 开发）
- **Xcode**（用于 iOS 开发，仅 macOS）

### 2. 安装 Flutter SDK

1. 下载 Flutter SDK：
   ```bash
   # macOS/Linux
   git clone https://github.com/flutter/flutter.git -b stable
   export PATH="$PATH:`pwd`/flutter/bin"
   
   # Windows
   # 下载 Flutter SDK 压缩包并解压到合适的位置
   # 将 Flutter 的 bin 目录添加到系统 PATH
   ```

2. 验证安装：
   ```bash
   flutter doctor
   ```

### 3. 设置开发环境

#### Android 开发环境

1. 安装 Android Studio
2. 配置 Android SDK：
   ```bash
   # 在 Android Studio 中安装 Android SDK 和 Android SDK Build-Tools
   # 设置 ANDROID_HOME 环境变量
   export ANDROID_HOME=$HOME/Library/Android/sdk
   export PATH=$PATH:$ANDROID_HOME/tools
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   ```
3. 接受 Android 许可证：
   ```bash
   flutter doctor --android-licenses
   ```

#### iOS 开发环境（仅 macOS）

1. 安装 Xcode
2. 配置 iOS 模拟器：
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

### 4. 克隆项目

```bash
git clone <项目仓库地址>
cd flutter-base
```

### 5. 安装依赖

```bash
flutter pub get
```

### 6. 配置环境变量

项目使用 `.env` 文件进行环境配置。复制并编辑环境配置文件：

```bash
cp .env.example .env
```

编辑 [`assets/cfg/.env`](assets/cfg/.env) 文件：

```env
APP_NAME=Flutter base

LOG_LEVEL=debug
LOG_COLOR=true
LOG_EMOJI=false

PRODUCTION_ERROR_WIDGET=false
DEVICE_PREVIEW=false

API_URL=https://z.fs.zunlijc.com

# Clarity 配置
CLARITY_PROJECT_ID=spfumhd4l8
```

### 7. 验证环境

运行以下命令确保环境配置正确：

```bash
flutter doctor
flutter analyze
```

---

## 项目结构

### 目录结构

```
flutter-base/
├── android/                 # Android 平台特定代码
├── ios/                     # iOS 平台特定代码
├── web/                     # Web 平台特定代码
├── windows/                 # Windows 平台特定代码
├── lib/                     # 主要应用代码
│   ├── app/                 # 应用核心
│   │   ├── app.dart         # 应用主入口
│   │   ├── app_wrapper.dart # 应用包装器
│   │   ├── router/          # 路由配置
│   │   ├── services/        # 应用服务
│   │   └── theme/           # 主题配置
│   ├── features/            # 功能模块
│   │   ├── counter/         # 计数器功能
│   │   ├── home/            # 首页功能
│   │   └── posts/           # 帖子功能
│   ├── models/              # 数据模型
│   ├── repositories/        # 数据访问层
│   ├── state/               # 状态管理
│   ├── utils/               # 工具类
│   ├── webview_bridge/      # WebView 桥接模块
│   └── widgets/             # 可重用 UI 组件
├── assets/                  # 资源文件
│   ├── cfg/                 # 配置文件
│   ├── lottie/              # Lottie 动画
│   └── web/                 # Web 资源
├── test/                    # 测试文件
├── scripts/                 # 脚本文件
└── doc/                     # 文档
```

### 核心模块说明

#### 应用核心 (`lib/app/`)

- [`app.dart`](lib/app/app.dart): 应用主入口，配置主题、路由和设备预览
- [`app_wrapper.dart`](lib/app/app_wrapper.dart): 应用包装器，初始化全局状态
- [`router/`](lib/app/router/): 路由配置，定义应用页面和导航

#### 功能模块 (`lib/features/`)

项目采用功能导向的架构，每个功能模块包含：
- `models/`: 数据模型
- `repositories/`: 数据访问层
- `state/`: 状态管理
- `widgets/`: UI 组件

#### WebView 桥接系统 (`lib/webview_bridge/`)

实现 JavaScript 与原生代码的通信，包含多个模块：
- [`plus_device.dart`](lib/webview_bridge/plus_device.dart): 设备信息模块
- [`plus_camera.dart`](lib/webview_bridge/plus_camera.dart): 相机模块
- [`plus_audio.dart`](lib/webview_bridge/plus_audio.dart): 音频模块
- [`plus_geolocation.dart`](lib/webview_bridge/plus_geolocation.dart): 地理位置模块
- [`plus_sqlite.dart`](lib/webview_bridge/plus_sqlite.dart): SQLite 数据库模块
- 等等...

---

## 开发流程

### 1. 运行应用

#### 在模拟器/真机上运行

```bash
# 查看可用设备
flutter devices

# 在指定设备上运行
flutter run -d <设备ID>

# 在默认设备上运行
flutter run
```

#### 热重载

在应用运行期间，修改代码后按 `r` 进行热重载，按 `R` 进行热重启。

#### 调试模式

```bash
# 启用调试模式
flutter run --debug

# 启用性能分析
flutter run --profile
```

### 2. 代码生成

项目使用代码生成来创建模型序列化和模拟对象：

```bash
# 生成代码文件
dart run build_runner build --delete-conflicting-outputs

# 使用项目脚本生成并格式化代码
./scripts/universal/generate_files.sh
```

### 3. 代码格式化

```bash
# 格式化代码
dart format -l 120 lib test

# 使用项目脚本格式化代码
./scripts/universal/format_code.sh
```

### 4. 代码分析

```bash
# 运行静态分析
flutter analyze

# 必须通过分析才能合并代码
```

### 5. 依赖管理

```bash
# 安装依赖
flutter pub get

# 检查依赖更新
flutter pub outdated

# 更新依赖
flutter pub upgrade

# 验证依赖
./scripts/universal/validate_dependencies.sh
```

### 6. 开发工作流

1. **创建功能分支**：
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **开发功能**：
   - 在 [`lib/features/`](lib/features/) 目录下创建新功能模块
   - 遵循项目的架构模式
   - 编写测试代码

3. **生成代码**：
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **格式化代码**：
   ```bash
   dart format -l 120 lib test
   ```

5. **运行测试**：
   ```bash
   flutter test
   ```

6. **代码分析**：
   ```bash
   flutter analyze
   ```

7. **提交代码**：
   ```bash
   git add .
   git commit -m "Add your feature description"
   git push origin feature/your-feature-name
   ```

---

## 核心功能

### 1. 应用入口

应用入口位于 [`lib/main.dart`](lib/main.dart:1)：

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/cfg/.env');
  
  // 获取Clarity项目ID
  final projectId = dotenv.env['CLARITY_PROJECT_ID'] ?? '';
  
  // 配置Clarity
  final config = ClarityConfig(
    projectId: projectId,
    logLevel: LogLevel.None,
  );
  
  runApp(ClarityWidget(
    app: ProviderScope(child: AppWrapper(app: App())),
    clarityConfig: config,
  ));
}
```

### 2. 应用配置

应用配置在 [`lib/app/app.dart`](lib/app/app.dart:1) 中：

```dart
class App extends StatelessWidget {
  final String appName = dotenv.get('APP_NAME', fallback: '');
  final bool devicePreview = dotenv.env['DEVICE_PREVIEW'] == 'true';
  final bool productionErrorWidget =
      dotenv.get('PRODUCTION_ERROR_WIDGET', fallback: 'true') == 'true';

  @override
  Widget build(BuildContext context) {
    // 设备预览配置
    if (devicePreview) {
      return DevicePreview(builder: (_) => app);
    }
    
    // 应用配置
    final app = MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: AppTheme().appThemeLight,
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generate,
    );
    
    return app;
  }
}
```

### 3. 路由系统

路由配置在 [`lib/app/router/`](lib/app/router/) 目录中：

- [`app_routes.dart`](lib/app/router/app_routes.dart:1): 定义路由常量
- [`route_generator.dart`](lib/app/router/route_generator.dart:1): 路由生成器

```dart
class AppRoutes {
  static const home = '/';
  static const webView = '/webview';
  static const placeholder = '/placeholder';
  // ... 更多路由
}
```

### 4. 主题系统

主题配置在 [`lib/app/theme/`](lib/app/theme/) 目录中：

```dart
class AppTheme {
  static ThemeData get appThemeLight {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      // ... 更多主题配置
    );
  }
}
```

---

## WebView 桥接系统

WebView 桥接系统是项目的核心功能之一，实现了 JavaScript 与原生代码的通信。系统采用模块化设计，支持多种设备 API。

### 1. 系统架构

#### 核心组件

- [`WebViewBridge`](lib/widgets/webview_bridge.dart:42): WebView 桥接组件
- [`PlusBridgeModule`](lib/webview_bridge/plus_bridge_base.dart:3): 桥接模块基类
- [`PlusModuleRegistry`](lib/webview_bridge/plus_module_registry.dart:1): 模块注册表

#### 工作原理

1. **初始化**: WebView 加载时注入 JavaScript 桥接代码
2. **通信**: JavaScript 通过 `window.flutter_invoke` 调用原生方法
3. **分发**: 原生代码通过 `handlePlusMethod` 分发到对应模块
4. **响应**: 原生方法执行后返回结果给 JavaScript

### 2. 模块系统

#### 模块注册

所有桥接模块在 [`plus_module_registry.dart`](lib/webview_bridge/plus_module_registry.dart:41) 中注册：

```dart
final List<PlusBridgeModule> plusModules = [
  PlusRuntimeModule(),
  PlusDeviceModule(),
  PlusEventsModule(),
  // ... 更多模块
];
```

#### 模块实现

每个模块继承自 [`PlusBridgeModule`](lib/webview_bridge/plus_bridge_base.dart:3)：

```dart
class PlusDeviceModule extends PlusBridgeModule {
  @override
  String get jsNamespace => 'device';
  
  @override
  Future<dynamic>? handle(String method, dynamic params, BuildContext context) async {
    switch (method) {
      case 'getProperty':
        // 处理获取设备属性
        break;
      case 'vibrate':
        // 处理震动
        break;
      // ... 更多方法
    }
  }
  
  @override
  String get jsCode => '''
    // JavaScript 代码
    window.plus.device = {
      // ... API 定义
    };
  ''';
}
```

### 3. 可用模块

#### 设备模块 ([`plus_device.dart`](lib/webview_bridge/plus_device.dart:1))

- 获取设备信息（型号、厂商、UUID）
- 震动功能
- 拨号功能

#### 相机模块 ([`plus_camera.dart`](lib/webview_bridge/plus_camera.dart:1))

- 拍照功能
- 录像功能
- 图像选择

#### 音频模块 ([`plus_audio.dart`](lib/webview_bridge/plus_audio.dart:1))

- 音频播放
- 音频录制
- 后台播放控制

#### 地理位置模块 ([`plus_geolocation.dart`](lib/webview_bridge/plus_geolocation.dart:1))

- 获取当前位置
- 监听位置变化
- 地理编码

#### SQLite 模块 ([`plus_sqlite.dart`](lib/webview_bridge/plus_sqlite.dart:1))

- 数据库操作
- 事务处理
- 数据查询

#### 其他模块

- [`plus_gallery.dart`](lib/webview_bridge/plus_gallery.dart:1): 图库功能
- [`plus_share.dart`](lib/webview_bridge/plus_share.dart:1): 分享功能
- [`plus_zip.dart`](lib/webview_bridge/plus_zip.dart:1): 压缩解压功能
- [`plus_io.dart`](lib/webview_bridge/plus_io.dart:1): 文件操作
- [`plus_nativeObj.dart`](lib/webview_bridge/plus_nativeObj.dart:1): 原生对象操作
- [`plus_nativeUI.dart`](lib/webview_bridge/plus_nativeUI.dart:1): 原生 UI 操作

### 4. 使用示例

#### 在 WebView 中调用原生功能

```javascript
// 等待 plusready 事件
document.addEventListener('plusready', function() {
  // 获取设备信息
  plus.device.getInfo(function(info) {
    console.log('Device info:', info);
  });
  
  // 震动
  plus.device.vibrate(1000);
  
  // 获取位置
  plus.geolocation.getCurrentPosition(function(position) {
    console.log('Current position:', position);
  });
});
```

#### 在 Flutter 中使用 WebView

```dart
WebViewBridge(
  url: 'assets/web/example/device.html',
  plusModules: ['device', 'geolocation'], // 可选：指定加载的模块
)
```

---

## 状态管理

项目使用 Riverpod 进行状态管理，这是一个轻量级且强大的状态管理解决方案。

### 1. 基本概念

#### Provider

Provider 是 Riverpod 的核心概念，用于提供和访问状态：

```dart
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);
  
  void increment() {
    state++;
  }
}
```

#### 使用 Provider

在 Widget 中使用 Provider：

```dart
class Counter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    
    return ElevatedButton(
      onPressed: () => ref.read(counterProvider.notifier).increment(),
      child: Text('Count: $count'),
    );
  }
}
```

### 2. 项目中的状态管理

#### 全局状态初始化

全局状态在 [`ProviderInitializer`](lib/state/provider_initializer.dart:1) 中初始化：

```dart
class ProviderInitializer extends StatelessWidget {
  final Widget child;
  
  ProviderInitializer({required this.child});
  
  @override
  Widget build(BuildContext context) {
    // Riverpod providers 现在在 riverpod_providers.dart 中定义
    // 不需要在 widget tree 中初始化
    return child;
  }
}
```

#### 状态提供者

状态提供者在 [`lib/state/riverpod_providers.dart`](lib/state/riverpod_providers.dart) 中定义：

```dart
final reposProvider = Provider((ref) => Repositories());

final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});
```

### 3. 最佳实践

#### 状态分类

1. **全局状态**: 应用级别的状态，如用户信息、主题设置
2. **功能状态**: 特定功能的状态，如计数器、表单数据
3. **临时状态**: 短期存在的状态，如页面加载状态

#### 状态组织

```dart
// 全局状态
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});

// 功能状态
final postsProvider = FutureProvider<List<Post>>((ref) async {
  final repository = ref.read(reposProvider).posts;
  return repository.fetchPosts();
});

// 临时状态
final loadingProvider = StateProvider<bool>((ref) => false);
```

#### 状态更新

```dart
// 更新状态
ref.read(counterProvider.notifier).increment();

// 监听状态变化
ref.listen<int>(counterProvider, (previous, next) {
  print('Counter changed from $previous to $next');
});
```

---

## 网络请求

项目使用 Dio 进行网络请求，提供了强大的 HTTP 客户端功能。

### 1. 网络配置

#### Dio 实例

在 [`lib/network/`](lib/network/) 目录中配置 Dio 实例：

```dart
final dio = Dio(BaseOptions(
  baseUrl: dotenv.env['API_URL'] ?? '',
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 3),
));
```

#### 拦截器

配置请求和响应拦截器：

```dart
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    // 添加请求头
    options.headers['Authorization'] = 'Bearer $token';
    return handler.next(options);
  },
  onResponse: (response, handler) {
    // 处理响应
    return handler.next(response);
  },
  onError: (error, handler) {
    // 处理错误
    return handler.next(error);
  },
));
```

### 2. 仓库模式

项目采用仓库模式进行数据访问：

#### 基础仓库

```dart
abstract class BaseRepository {
  final Dio dio;
  
  BaseRepository(this.dio);
  
  Future<T> get<T>(String path, {Map<String, dynamic>? queryParameters});
  Future<T> post<T>(String path, {dynamic data});
  Future<T> put<T>(String path, {dynamic data});
  Future<T> delete<T>(String path);
}
```

#### 具体仓库

```dart
class PostRepository extends BaseRepository {
  PostRepository(Dio dio) : super(dio);
  
  Future<List<Post>> fetchPosts() async {
    final response = await get('/posts');
    return (response.data as List)
        .map((json) => Post.fromJson(json))
        .toList();
  }
  
  Future<Post> fetchPost(int id) async {
    final response = await get('/posts/$id');
    return Post.fromJson(response.data);
  }
}
```

### 3. 缓存策略

项目使用 [`dio_cache_interceptor`](pubspec.yaml:42) 进行请求缓存：

```dart
dio.interceptors.add(DioCacheInterceptor(
  options: CacheOptions(
    store: MemCacheStore(),
    policy: CachePolicy.requestFirst,
    hitCacheOnErrorExcept: [401, 403],
    maxStale: const Duration(days: 7),
  ),
));
```

### 4. 使用示例

#### 在 Widget 中使用

```dart
class PostsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);
    
    return postsAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (posts) => ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return ListTile(
            title: Text(post.title),
            subtitle: Text(post.body),
          );
        },
      ),
    );
  }
}
```

#### 在 Repository 中使用

```dart
class ExternalService {
  final Dio dio;
  
  ExternalService(this.dio);
  
  Future<ExampleModel> fetchDummy() async {
    final response = await dio.get('https://jsonplaceholder.typicode.com/todos/1');
    return ExampleModel.fromJson(response.data);
  }
}
```

---

## 数据存储

项目支持多种数据存储方式，包括 SQLite 数据库、文件存储和共享偏好设置。

### 1. SQLite 数据库

#### 数据库配置

使用 [`sqflite`](pubspec.yaml:47) 进行 SQLite 数据库操作：

```dart
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  
  DatabaseHelper._internal();
  
  static DatabaseHelper get instance => _instance;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }
}
```

#### 数据操作

```dart
class PostRepository {
  final DatabaseHelper _dbHelper;
  
  PostRepository(this._dbHelper);
  
  Future<int> insertPost(Post post) async {
    final db = await _dbHelper.database;
    return await db.insert('posts', post.toJson());
  }
  
  Future<List<Post>> getPosts() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('posts');
    return List.generate(maps.length, (i) {
      return Post.fromJson(maps[i]);
    });
  }
  
  Future<int> updatePost(Post post) async {
    final db = await _dbHelper.database;
    return await db.update(
      'posts',
      post.toJson(),
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }
  
  Future<int> deletePost(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
```

### 2. 文件存储

#### 路径获取

使用 [`path_provider`](pubspec.yaml:45) 获取文件路径：

```dart
final directory = await getApplicationDocumentsDirectory();
final path = '${directory.path}/my_file.txt';
```

#### 文件操作

```dart
// 写入文件
final file = File(path);
await file.writeAsString('Hello, World!');

// 读取文件
final content = await file.readAsString();

// 删除文件
await file.delete();
```

### 3. 共享偏好设置

使用 [`shared_preferences`](pubspec.yaml) 进行简单数据存储：

```dart
// 保存数据
final prefs = await SharedPreferences.getInstance();
await prefs.setString('username', 'John Doe');
await prefs.setInt('age', 30);
await prefs.setBool('isLoggedIn', true);

// 读取数据
final username = prefs.getString('username');
final age = prefs.getInt('age');
final isLoggedIn = prefs.getBool('isLoggedIn');
```

### 4. WebView 中的数据存储

通过 WebView 桥接系统，JavaScript 也可以访问数据存储功能：

```javascript
// SQLite 操作
plus.sqlite.openDatabase({
  name: 'mydb',
  path: '_doc/mydb.db',
  success: function(db) {
    db.executeSQL('CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)');
  }
});

// 文件操作
plus.io.requestFileSystem(1, function(fs) {
  fs.root.getFile('test.txt', {create: true}, function(fileEntry) {
    fileEntry.createWriter(function(writer) {
      writer.write('Hello from WebView!');
    });
  });
});
```

---

## 测试

项目包含完整的测试体系，包括单元测试、组件测试和集成测试。

### 1. 测试结构

```
test/
├── unit/                   # 单元测试
│   ├── models/            # 模型测试
│   └── repositories/      # 仓库测试
├── widget/                # 组件测试
│   └── screens/           # 屏幕测试
└── mocks/                 # 模拟对象
    └── mockito.dart       # Mockito 模拟定义
```

### 2. 单元测试

#### 模型测试

```dart
void main() {
  group('Post Model', () {
    test('should create Post from JSON', () {
      final json = {
        'id': 1,
        'title': 'Test Post',
        'body': 'Test Body',
      };
      
      final post = Post.fromJson(json);
      
      expect(post.id, 1);
      expect(post.title, 'Test Post');
      expect(post.body, 'Test Body');
    });
    
    test('should convert Post to JSON', () {
      final post = Post(
        id: 1,
        title: 'Test Post',
        body: 'Test Body',
      );
      
      final json = post.toJson();
      
      expect(json['id'], 1);
      expect(json['title'], 'Test Post');
      expect(json['body'], 'Test Body');
    });
  });
}
```

#### 仓库测试

```dart
void main() {
  group('PostRepository', () {
    late MockDio mockDio;
    late PostRepository repository;
    
    setUp(() {
      mockDio = MockDio();
      repository = PostRepository(mockDio);
    });
    
    test('should fetch posts successfully', () async {
      // 准备模拟数据
      final mockResponse = [
        {'id': 1, 'title': 'Post 1', 'body': 'Body 1'},
        {'id': 2, 'title': 'Post 2', 'body': 'Body 2'},
      ];
      
      // 设置模拟响应
      when(mockDio.get('/posts')).thenAnswer(
        (_) async => Response(data: mockResponse, statusCode: 200),
      );
      
      // 执行测试
      final posts = await repository.fetchPosts();
      
      // 验证结果
      expect(posts.length, 2);
      expect(posts[0].title, 'Post 1');
      expect(posts[1].title, 'Post 2');
    });
  });
}
```

### 3. 组件测试

#### 屏幕测试

```dart
void main() {
  testWidgets('HomeScreen should display correctly', (WidgetTester tester) async {
    // 准备测试环境
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    
    // 验证初始状态
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('WebView 演示'), findsOneWidget);
    
    // 模拟用户交互
    await tester.tap(find.text('打开网络页面'));
    await tester.pumpAndSettle();
    
    // 验证导航结果
    expect(find.text('WebViewBridge 网络页面'), findsOneWidget);
  });
}
```

### 4. 模拟对象

#### Mockito 模拟

在 [`test/mocks/mockito.dart`](test/mocks/mockito.dart) 中定义模拟对象：

```dart
@GenerateMocks([Dio])
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
```

生成模拟对象：

```bash
dart run build_runner build --delete-conflicting-outputs
```

使用模拟对象：

```dart
void main() {
  group('Example Test', () {
    late MockDio mockDio;
    
    setUp(() {
      mockDio = MockDio();
    });
    
    test('should handle errors', () async {
      // 设置模拟错误
      when(mockDio.get('/posts')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/posts'),
          type: DioExceptionType.connectionError,
        ),
      );
      
      // 执行测试
      expect(
        () => repository.fetchPosts(),
        throwsA(isA<DioException>()),
      );
    });
  });
}
```

### 5. 运行测试

#### 运行所有测试

```bash
flutter test
```

#### 运行特定测试

```bash
flutter test test/unit/models/post_model_test.dart
```

#### 运行测试并生成覆盖率报告

```bash
flutter test --coverage
```

#### 生成 HTML 覆盖率报告

```bash
./scripts/linux/coverage.sh
```

### 6. 测试最佳实践

#### 测试命名

```dart
// 好的测试命名
test('should return user data when API call is successful', () async {
  // 测试代码
});

test('should throw exception when API call fails', () async {
  // 测试代码
});

// 避免的测试命名
test('test user', () async {
  // 测试代码
});
```

#### 测试组织

```dart
void main() {
  group('UserRepository', () {
    group('fetchUser', () {
      test('should return user when ID is valid', () async {
        // 测试代码
      });
      
      test('should throw exception when ID is invalid', () async {
        // 测试代码
      });
    });
    
    group('saveUser', () {
      test('should save user when data is valid', () async {
        // 测试代码
      });
    });
  });
}
```

---

## 构建和部署

### 1. 构建应用

#### Android APK

```bash
# 构建调试版 APK
flutter build apk --debug

# 构建发布版 APK
flutter build apk --release

# 构建特定架构的 APK
flutter build apk --release --split-per-abi
```

#### iOS 应用

```bash
# 构建iOS应用
flutter build ios --release

# 在Xcode中打开
open ios/Runner.xcworkspace
```

#### Web 应用

```bash
# 构建Web应用
flutter build web --release
```

#### Windows 应用

```bash
# 构建Windows应用
flutter build windows --release
```

### 2. 签名配置

#### Android 签名

1. 创建签名密钥：
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. 配置 [`android/key.properties`](android/key.properties)：
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=<path-to-upload-keystore.jks>
   ```

3. 修改 [`android/app/build.gradle`](android/app/build.gradle)：
   ```gradle
   android {
       ...
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

#### iOS 签名

1. 在 Apple Developer Portal 配置应用
2. 在 Xcode 中配置签名证书
3. 配置 [`ios/Runner/Info.plist`](ios/Runner/Info.plist)

### 3. 部署到应用商店

#### Google Play Store

1. 生成签名 APK 或 AAB：
   ```bash
   flutter build appbundle --release
   ```

2. 上传到 Google Play Console
3. 填写应用信息
4. 提交审核

#### Apple App Store

1. 构建iOS应用：
   ```bash
   flutter build ios --release
   ```

2. 在 Xcode 中打开项目：
   ```bash
   open ios/Runner.xcworkspace
   ```

3. 配置应用信息
4. 使用 Application Loader 上传
5. 在 App Store Connect 中提交审核

### 4. 持续集成/持续部署 (CI/CD)

#### GitHub Actions 示例

```yaml
name: Flutter CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Generate code
      run: dart run build_runner build --delete-conflicting-outputs
    
    - name: Run tests
      run: flutter test --coverage
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3

  build:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

---

## 最佳实践

### 1. 代码组织

#### 文件命名

```dart
// 好的文件命名
// lib/features/user/user_model.dart
// lib/features/user/user_repository.dart
// lib/features/user/user_screen.dart
// lib/features/user/user_widget.dart

// 避免的文件命名
// lib/features/user/model.dart
// lib/features/user/repo.dart
// lib/features/user/view.dart
```

#### 类命名

```dart
// 好的类命名
class UserRepository {}
class UserModel {}
class UserScreen {}
class UserCard {}

// 避免的类命名
class UserRepo {}
class User {}
class UserView {}
class Card {}
```

#### 方法命名

```dart
// 好的方法命名
Future<User> fetchUser(int id) async {}
Future<void> saveUser(User user) async {}
Future<List<User>> getUsers() async {}

// 避免的方法命名
Future<User> getUser(int id) async {}
Future<void> user(User user) async {}
Future<List<User>> all() async {}
```

### 2. 代码风格

#### 导入顺序

```dart
// Dart 核心库
import 'dart:async';
import 'dart:convert';

// Flutter 框架
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 第三方包
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

// 项目内部
import 'package:flutter_base/models/user_model.dart';
import 'package:flutter_base/repositories/user_repository.dart';

// 相对路径
import '../widgets/user_card.dart';
```

#### 代码格式化

```dart
// 好的格式化
class UserRepository {
  final Dio _dio;
  
  UserRepository(this._dio);
  
  Future<User> fetchUser(int id) async {
    try {
      final response = await _dio.get('/users/$id');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch user: ${e.message}');
    }
  }
}

// 避免的格式化
class UserRepository{
  final Dio _dio;
  UserRepository(this._dio);
  Future<User> fetchUser(int id) async{
    try{
      final response=await _dio.get('/users/$id');
      return User.fromJson(response.data);
    }on DioException catch(e){
      throw Exception('Failed to fetch user: ${e.message}');
    }
  }
}
```

### 3. 错误处理

#### 异常处理

```dart
// 好的异常处理
Future<User> fetchUser(int id) async {
  try {
    final response = await _dio.get('/users/$id');
    return User.fromJson(response.data);
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      throw Exception('Connection timeout');
    } else if (e.type == DioExceptionType.badResponse) {
      throw Exception('Server error: ${e.response?.statusCode}');
    } else {
      throw Exception('Network error: ${e.message}');
    }
  } catch (e) {
    throw Exception('Unexpected error: $e');
  }
}

// 避免的异常处理
Future<User> fetchUser(int id) async {
  final response = await _dio.get('/users/$id');
  return User.fromJson(response.data); // 没有异常处理
}
```

#### 错误消息

```dart
// 好的错误消息
throw Exception('Failed to fetch user: Network connection timeout');
throw Exception('Invalid user data: Missing required field "email"');
throw Exception('Permission denied: User does not have access to this resource');

// 避免的错误消息
throw Exception('Error');
throw Exception('Something went wrong');
throw Exception('Failed');
```

### 4. 性能优化

#### 列表优化

```dart
// 好的列表实现
class UserList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);
    
    return usersAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (users) => ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return UserCard(user: users[index]); // 使用 const 构造函数
        },
      ),
    );
  }
}

// 避免的列表实现
class UserList extends StatelessWidget {
  final List<User> users;
  
  UserList({required this.users});
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return Container( // 没有优化
          child: Text(users[index].name),
        );
      },
    );
  }
}
```

#### 图片优化

```dart
// 好的图片处理
Image.network(
  'https://example.com/image.jpg',
  width: 100,
  height: 100,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return const CircularProgressIndicator();
  },
  errorBuilder: (context, error, stack) {
    return const Icon(Icons.error);
  },
)

// 避免的图片处理
Image.network('https://example.com/image.jpg') // 没有优化
```

### 5. 安全性

#### 数据验证

```dart
// 好的数据验证
class UserModel {
  final int id;
  final String name;
  final String email;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw ArgumentError('Missing required field: id');
    }
    if (json['name'] == null || json['name'].toString().isEmpty) {
      throw ArgumentError('Missing required field: name');
    }
    if (json['email'] == null || !json['email'].toString().contains('@')) {
      throw ArgumentError('Invalid email format');
    }
    
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

// 避免的数据验证
class UserModel {
  final int id;
  final String name;
  final String email;
  
  UserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        email = json['email']; // 没有验证
}
```

#### 网络安全

```dart
// 好的网络请求
Future<User> fetchUser(int id) async {
  try {
    final response = await _dio.get(
      '/users/$id',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status! < 500,
      ),
    );
    
    if (response.statusCode == 401) {
      throw Exception('Unauthorized access');
    }
    
    return User.fromJson(response.data);
  } on DioException catch (e) {
    throw Exception('Network error: ${e.message}');
  }
}

// 避免的网络请求
Future<User> fetchUser(int id) async {
  final response = await _dio.get('/users/$id'); // 没有安全措施
  return User.fromJson(response.data);
}
```

---

## 故障排除

### 1. 常见问题

#### Flutter 相关问题

**问题**: `flutter doctor` 显示缺少 Android 许可证

**解决方案**:
```bash
flutter doctor --android-licenses
```

**问题**: 运行 `flutter run` 时出现 "Unable to locate adb"

**解决方案**:
```bash
# 确保 Android SDK 路径正确
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

**问题**: 热重载不工作

**解决方案**:
```bash
# 尝试热重启
flutter run --hot

# 或完全重启应用
flutter run
```

#### 依赖相关问题

**问题**: `flutter pub get` 失败

**解决方案**:
```bash
# 清理依赖缓存
flutter pub cache clean

# 删除 pubspec.lock
rm pubspec.lock

# 重新获取依赖
flutter pub get
```

**问题**: 代码生成失败

**解决方案**:
```bash
# 清理生成文件
find . -name "*.g.dart" -delete
find . -name "*.mocks.dart" -delete

# 重新生成
dart run build_runner build --delete-conflicting-outputs
```

#### WebView 相关问题

**问题**: WebView 无法加载本地 HTML 文件

**解决方案**:
```dart
// 确保 WebView 设置正确
InAppWebView(
  initialSettings: InAppWebViewSettings(
    allowFileAccessFromFileURLs: true,
    allowUniversalAccessFromFileURLs: true,
  ),
)
```

**问题**: JavaScript 调用原生方法失败

**解决方案**:
```dart
// 确保正确注册 JavaScript 处理器
controller.addJavaScriptHandler(
  handlerName: 'flutter_invoke',
  callback: (args) async {
    // 处理调用
  },
);
```

### 2. 调试技巧

#### 日志调试

使用自定义日志记录器：

```dart
import 'package:flutter_base/utils/logger.dart';

class MyService {
  final log = getLogger(MyService);
  
  void doSomething() {
    log.i('Doing something');
    log.d('Debug information');
    log.w('Warning message');
    log.e('Error message');
  }
}
```

#### 断点调试

1. 在 IDE 中设置断点
2. 以调试模式运行应用：
   ```bash
   flutter run --debug
   ```
3. 使用 IDE 的调试工具进行调试

#### WebView 调试

启用 WebView 调试：

```dart
InAppWebView(
  initialSettings: InAppWebViewSettings(
    javaScriptEnabled: true,
    debuggingEnabled: true,
  ),
  onConsoleMessage: (controller, consoleMessage) {
    print('[WebView] ${consoleMessage.message}');
  },
)
```

### 3. 性能问题

#### 应用启动慢

**解决方案**:
```dart
// 优化 main 函数
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 并行初始化
  await Future.wait([
    dotenv.load(fileName: 'assets/cfg/.env'),
    PackageInfo.fromPlatform(),
    // 其他初始化
  ]);
  
  runApp(MyApp());
}
```

#### 列表滚动卡顿

**解决方案**:
```dart
// 使用 ListView.builder
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(item: items[index]); // 使用轻量级组件
  },
)

// 避免使用 ListView
ListView(
  children: items.map((item) => ItemWidget(item: item)).toList(),
)
```

#### 内存泄漏

**解决方案**:
```dart
// 在 State 中正确清理资源
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  StreamSubscription? _subscription;
  
  @override
  void initState() {
    super.initState();
    _subscription = someStream.listen((data) {
      // 处理数据
    });
  }
  
  @override
  void dispose() {
    _subscription?.cancel(); // 清理资源
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // 构建UI
  }
}
```

### 4. 平台特定问题

#### Android 特定问题

**问题**: Android 应用崩溃

**解决方案**:
```bash
# 查看日志
adb logcat

# 检查 AndroidManifest.xml 配置
# 确保权限正确声明
```

**问题**: Android 签名问题

**解决方案**:
```bash
# 验证签名
jarsigner -verify -verbose -certs app-release.apk

# 检查签名配置
keytool -list -v -keystore upload-keystore.jks
```

#### iOS 特定问题

**问题**: iOS 应用无法构建

**解决方案**:
```bash
# 清理构建
flutter clean
flutter build ios --release

# 检查 Xcode 配置
open ios/Runner.xcworkspace
```

**问题**: iOS 权限问题

**解决方案**:
```xml
<!-- 在 Info.plist 中添加权限 -->
<key>NSCameraUsageDescription</key>
<string>需要访问相机</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要访问位置</string>
```

### 5. 获取帮助

#### 官方资源

- [Flutter 文档](https://flutter.dev/docs)
- [Flutter GitHub](https://github.com/flutter/flutter)
- [Dart 文档](https://dart.dev/guides)

#### 社区资源

- [Flutter 社区](https://flutter.dev/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter Discord](https://discord.gg/flutter)

#### 项目特定资源

- 查看 [`CLAUDE.md`](CLAUDE.md) 获取项目特定的开发指南
- 查看示例代码了解最佳实践
- 运行测试了解功能使用方式

---

## 总结

本指南提供了 Flutter Base 项目的完整开发流程，从环境搭建到应用部署。通过遵循本指南，开发者可以快速上手项目并开始开发功能。

### 关键要点

1. **环境搭建**: 确保正确安装 Flutter SDK 和相关工具
2. **项目结构**: 理解项目的模块化架构
3. **开发流程**: 遵循标准的开发工作流
4. **核心功能**: 充分利用 WebView 桥接系统和状态管理
5. **测试**: 编写完整的测试用例
6. **部署**: 正确构建和部署应用
7. **最佳实践**: 遵循代码规范和性能优化建议

### 后续学习

- 深入学习 Flutter 框架
- 探索更多 WebView 桥接功能
- 学习高级状态管理技巧
- 掌握性能优化方法

祝您开发愉快！