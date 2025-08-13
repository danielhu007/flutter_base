import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_base/utils/logger.dart';

/// Clarity服务类，用于管理Microsoft Clarity SDK的初始化和配置
class ClarityService {
  static final ClarityService _instance = ClarityService._internal();
  static ClarityService get instance => _instance;
  
  final log = getLogger(ClarityService);
  bool _isInitialized = false;
  
  ClarityService._internal();
  
  /// 初始化Clarity SDK
  Future<void> initialize() async {
    if (_isInitialized) {
      log.w('Clarity SDK已经初始化过了');
      return;
    }
    
    try {
      final projectId = dotenv.env['CLARITY_PROJECT_ID'];
      if (projectId == null || projectId.isEmpty || projectId == 'your_clarity_project_id_here') {
        log.w('Clarity项目ID未配置，跳过初始化');
        return;
      }
      
      await Clarity.initialize(projectId);
      _isInitialized = true;
      log.i('Clarity SDK初始化成功，项目ID: $projectId');
    } catch (e) {
      log.e('Clarity SDK初始化失败: $e');
    }
  }
  
  /// 检查Clarity是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 记录自定义事件
  void logEvent(String eventName, {Map<String, dynamic>? data}) {
    if (!_isInitialized) {
      log.w('Clarity SDK未初始化，无法记录事件: $eventName');
      return;
    }
    
    try {
      Clarity.logEvent(eventName, data: data);
      log.i('记录Clarity事件: $eventName, 数据: $data');
    } catch (e) {
      log.e('记录Clarity事件失败: $e');
    }
  }
  
  /// 记录页面访问
  void logPageView(String pageName) {
    if (!_isInitialized) {
      log.w('Clarity SDK未初始化，无法记录页面访问: $pageName');
      return;
    }
    
    try {
      Clarity.logEvent('page_view', data: {'page_name': pageName});
      log.i('记录页面访问: $pageName');
    } catch (e) {
      log.e('记录页面访问失败: $e');
    }
  }
  
  /// 记录用户操作
  void logUserAction(String action, {String? target, Map<String, dynamic>? additionalData}) {
    if (!_isInitialized) {
      log.w('Clarity SDK未初始化，无法记录用户操作: $action');
      return;
    }
    
    try {
      final data = <String, dynamic>{
        'action': action,
      };
      
      if (target != null) {
        data['target'] = target;
      }
      
      if (additionalData != null) {
        data.addAll(additionalData);
      }
      
      Clarity.logEvent('user_action', data: data);
      log.i('记录用户操作: $action, 目标: $target, 额外数据: $additionalData');
    } catch (e) {
      log.e('记录用户操作失败: $e');
    }
  }
  
  /// 设置用户标识
  void setUserIdentifier(String userId) {
    if (!_isInitialized) {
      log.w('Clarity SDK未初始化，无法设置用户标识: $userId');
      return;
    }
    
    try {
      Clarity.setUserId(userId);
      log.i('设置用户标识: $userId');
    } catch (e) {
      log.e('设置用户标识失败: $e');
    }
  }
  
  /// 设置自定义属性
  void setCustomProperty(String key, String value) {
    if (!_isInitialized) {
      log.w('Clarity SDK未初始化，无法设置自定义属性: $key=$value');
      return;
    }
    
    try {
      Clarity.setCustomProperty(key, value);
      log.i('设置自定义属性: $key=$value');
    } catch (e) {
      log.e('设置自定义属性失败: $e');
    }
  }
}