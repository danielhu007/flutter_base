import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_base/app/app.dart';
import 'package:flutter_base/app/app_wrapper.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Code run during splash screen
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/cfg/.env');
  
  // 获取Clarity项目ID
  final projectId = dotenv.env['CLARITY_PROJECT_ID'] ?? '';
  
  // 配置Clarity
  final config = ClarityConfig(
    projectId: projectId,
    logLevel: LogLevel.None, // 使用 LogLevel.Verbose 进行调试
  );
  
  runApp(ClarityWidget(
    app: ProviderScope(child: AppWrapper(app: App())),
    clarityConfig: config,
  ));
}
