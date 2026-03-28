/// 🎴 K-Poker -- 게임 저장/불러오기 시스템
///
/// LocalStorage (SharedPreferences) 기반 자동 저장
/// 버전 관리로 세이브 호환성 보장
library;

import 'dart:convert';
import 'dart:developer' as dev;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/run_state.dart';
import '../models/round_state.dart';

const String _saveKey = 'kpoker_save_data';
const String _roundSaveKey = 'kpoker_round_data';

class GameSaveManager {
  /// 현재 세이브 데이터 버전
  static const int currentVersion = 1;

  /// 게임 상태 저장 (버전 포함)
  static Future<void> save(RunState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final envelope = <String, dynamic>{
        'version': currentVersion,
        'data': state.toJson(),
      };
      final json = jsonEncode(envelope);
      await prefs.setString(_saveKey, json);
    } catch (e) {
      dev.log('GameSaveManager.save failed: $e', name: 'SaveManager');
    }
  }

  /// 라운드 중간 상태 저장 (카드 배치, 턴 등)
  static Future<void> saveRound(RoundState roundState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(roundState.toJson());
      await prefs.setString(_roundSaveKey, json);
    } catch (e) {
      dev.log('GameSaveManager.saveRound failed: $e', name: 'SaveManager');
    }
  }

  /// 라운드 중간 상태 불러오기
  static Future<RoundState?> loadRound() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_roundSaveKey);
      if (json == null) return null;
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return RoundState.fromJson(decoded);
    } catch (e) {
      dev.log('GameSaveManager.loadRound failed: $e', name: 'SaveManager');
      return null;
    }
  }

  /// 라운드 저장 데이터 삭제 (라운드 종료 시)
  static Future<void> deleteRoundSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roundSaveKey);
  }

  /// 라운드 저장 데이터 존재 여부
  static Future<bool> hasRoundSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_roundSaveKey);
  }

  /// 저장된 게임 불러오기 (버전 마이그레이션 포함)
  static Future<RunState?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_saveKey);
      if (json == null) return null;

      final decoded = jsonDecode(json) as Map<String, dynamic>;

      // 버전 필드가 없으면 v0 (버전 관리 이전 레거시 데이터)
      final version = decoded['version'] as int? ?? 0;

      if (version > currentVersion) {
        dev.log(
          'Save version $version > current $currentVersion, discarding',
          name: 'SaveManager',
        );
        await deleteSave();
        return null;
      }

      // 버전별 데이터 추출
      Map<String, dynamic> data;
      if (version == 0) {
        data = decoded;
      } else {
        data = decoded['data'] as Map<String, dynamic>;
      }

      data = _migrate(data, from: version);

      return RunState.fromJson(data);
    } catch (e) {
      dev.log('GameSaveManager.load failed: $e', name: 'SaveManager');
      return null;
    }
  }

  /// 버전 마이그레이션 체인
  static Map<String, dynamic> _migrate(
    Map<String, dynamic> data, {
    required int from,
  }) {
    return data;
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
    await prefs.remove(_roundSaveKey);
  }
}
