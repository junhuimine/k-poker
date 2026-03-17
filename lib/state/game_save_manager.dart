/// 🎴 K-Poker -- 게임 저장/불러오기 시스템
///
/// LocalStorage (SharedPreferences) 기반 자동 저장

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/run_state.dart';

const String _saveKey = 'kpoker_save_data';

class GameSaveManager {
  /// 게임 상태 저장
  static Future<void> save(RunState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(state.toJson());
      await prefs.setString(_saveKey, json);
    } catch (e) {
      // 저장 실패 시 무시 (게임은 계속)
    }
  }

  /// 저장된 게임 불러오기
  static Future<RunState?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_saveKey);
      if (json == null) return null;
      return RunState.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// 저장 데이터 존재 여부
  static Future<bool> hasSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_saveKey);
  }

  /// 저장 데이터 삭제 (새 게임)
  static Future<void> deleteSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
  }
}
