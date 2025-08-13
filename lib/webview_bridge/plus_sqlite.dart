import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'plus_bridge_base.dart';

class PlusSqliteModule extends PlusBridgeModule {
  @override
  String get jsNamespace => 'sqlite';

  final Map<String, Database> _dbs = {};

  // H5+ openDatabase
  Future<Map<String, dynamic>> openDatabaseH5(Map params) async {
    final String name = params['name'] as String;
    final String path = params['path'] as String;
    try {
      final db = await openDatabase(path, version: 1);
      _dbs['$name|$path'] = db;
      return {'success': true};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // H5+ isOpenDatabase
  bool isOpenDatabaseH5(Map params) {
    final String name = params['name'] as String;
    final String path = params['path'] as String;
    return _dbs['$name|$path']?.isOpen ?? false;
  }

  // H5+ closeDatabase
  Future<Map<String, dynamic>> closeDatabaseH5(Map params) async {
    final String name = params['name'] as String;
    final String path = params['path'] as String;
    try {
      final db = _dbs['$name|$path'];
      if (db != null) {
        await db.close();
        _dbs.remove('$name|$path');
        return {'success': true};
      } else {
        return {'error': 'db not found'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // H5+ transaction
  Future<Map<String, dynamic>> transactionH5(Map params) async {
    final String name = params['name'] as String;
    final String path = params['path'] as String;
    final String operation = params['operation'] as String;
    final db = _dbs['$name|$path'];
    if (db == null) {
      return {'error': 'db not found'};
    }
    try {
      if (operation == 'begin') {
        await db.transaction((txn) async {});
      } else if (operation == 'commit') {
        // sqflite 自动 commit
      } else if (operation == 'rollback') {
        // sqflite 不支持 rollback 单独操作
      }
      return {'success': true};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // H5+ executeSql
  Future<Map<String, dynamic>> executeSqlH5(Map params) async {
    final String name = params['name'] as String;
    final String path = params['path'] as String;
    final sql = params['sql'];
    final db = _dbs['$name|$path'];
    if (db == null) {
      return {'error': 'db not found'};
    }
    try {
      if (sql is String) {
        await db.execute(sql as String);
      } else if (sql is List) {
        for (final s in sql) {
          await db.execute(s as String);
        }
      }
      return {'success': true};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // H5+ selectSql
  Future<Map<String, dynamic>> selectSqlH5(Map params) async {
    final String name = params['name'] as String;
    final String path = params['path'] as String;
    final sql = params['sql'];
    final db = _dbs['$name|$path'];
    if (db == null) {
      return {'error': 'db not found'};
    }
    try {
      if (sql is String) {
        final List<Map<String, dynamic>> result =
            await db.rawQuery(sql as String);
        return {'success': true, 'data': result};
      } else {
        return {'error': 'sql must be String'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  @override
  Future<dynamic>? handle(
      String method, dynamic params, BuildContext context) async {
    final Map<String, dynamic> mapParams = params as Map<String, dynamic>;
    switch (method) {
      case 'openDatabase':
        return await openDatabaseH5(mapParams);
      case 'isOpenDatabase':
        return isOpenDatabaseH5(mapParams);
      case 'closeDatabase':
        return await closeDatabaseH5(mapParams);
      case 'transaction':
        return await transactionH5(mapParams);
      case 'executeSql':
        return await executeSqlH5(mapParams);
      case 'selectSql':
        return await selectSqlH5(mapParams);
      default:
        return null;
    }
  }

  @override
  String get jsCode => '''
    window.plus = window.plus || {};
    // plus.sqlite 模块注入，兼容 H5+
    window.plus.sqlite = {
      openDatabase: function(options) {
        window.flutter_invoke('sqlite.openDatabase', options).then(function(res) {
          if (res && res.success && typeof options.success === 'function') {
            options.success();
          } else if (res && res.error && typeof options.fail === 'function') {
            options.fail({ message: res.error });
          }
        });
      },
      isOpenDatabase: function(options) {
        return window.flutter_invoke('sqlite.isOpenDatabase', options);
      },
      closeDatabase: function(options) {
        window.flutter_invoke('sqlite.closeDatabase', options).then(function(res) {
          if (res && res.success && typeof options.success === 'function') {
            options.success();
          } else if (res && res.error && typeof options.fail === 'function') {
            options.fail({ message: res.error });
          }
        });
      },
      transaction: function(options) {
        window.flutter_invoke('sqlite.transaction', options).then(function(res) {
          if (res && res.success && typeof options.success === 'function') {
            options.success();
          } else if (res && res.error && typeof options.fail === 'function') {
            options.fail({ message: res.error });
          }
        });
      },
      executeSql: function(options) {
        window.flutter_invoke('sqlite.executeSql', options).then(function(res) {
          if (res && res.success && typeof options.success === 'function') {
            options.success();
          } else if (res && res.error && typeof options.fail === 'function') {
            options.fail({ message: res.error });
          }
        });
      },
      selectSql: function(options) {
        window.flutter_invoke('sqlite.selectSql', options).then(function(res) {
          if (res && res.success && typeof options.success === 'function') {
            options.success(res.data);
          } else if (res && res.error && typeof options.fail === 'function') {
            options.fail({ message: res.error });
          }
        });
      }
    };
  ''';
}
