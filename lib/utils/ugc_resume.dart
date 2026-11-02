import 'dart:convert';

import 'package:PiliPlus/utils/storage.dart';
import 'package:hive_ce/hive.dart';

/// UGC 合集的一条续播记录。
///
/// 只记录「上次看到哪一集、那一集的第几秒」，不涉及账号、不上传。
class UgcResumePoint {
  const UgcResumePoint({
    required this.bvid,
    required this.cid,
    required this.positionMs,
    required this.updatedAt,
  });

  final String bvid;
  final int cid;
  final int positionMs;
  final int updatedAt;

  static UgcResumePoint? fromJson(String raw) {
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return null;
      final bvid = map['bvid'];
      if (bvid is! String || bvid.isEmpty) return null;
      return UgcResumePoint(
        bvid: bvid,
        cid: map['cid'] is int ? map['cid'] as int : 0,
        positionMs: map['pos'] is int ? map['pos'] as int : 0,
        updatedAt: map['ts'] is int ? map['ts'] as int : 0,
      );
    } catch (_) {
      return null;
    }
  }

  String toJson() => jsonEncode({
    'bvid': bvid,
    'cid': cid,
    'pos': positionMs,
    'ts': updatedAt,
  });
}

/// UGC 合集断点续播的本地存储。
///
/// key 为 `ugcResume:<seasonId>`，落在原有的 localCache 盒子里，
/// 不新增 Hive box、不注册 adapter，卸载/清缓存时随之消失。
abstract final class UgcResume {
  static const String _prefix = 'ugcResume:';

  /// 超过这个时间没再看过，就不再自动跳转，避免翻出一年前的记录
  static const Duration _maxAge = Duration(days: 30);

  /// localCache 在 GStorage.init() 里打开；测试环境或极早期调用可能还没就绪
  static Box<dynamic>? get _box {
    try {
      return GStorage.localCache;
    } catch (_) {
      return null;
    }
  }

  static String _key(int seasonId) => '$_prefix$seasonId';

  static UgcResumePoint? read(int seasonId) {
    try {
      final raw = _box?.get(_key(seasonId));
      if (raw is! String) return null;
      final point = UgcResumePoint.fromJson(raw);
      if (point == null) return null;
      if (point.updatedAt > 0 &&
          DateTime.now().millisecondsSinceEpoch - point.updatedAt >
              _maxAge.inMilliseconds) {
        return null;
      }
      return point;
    } catch (_) {
      return null;
    }
  }

  static Future<void> save({
    required int seasonId,
    required String bvid,
    required int cid,
    required int positionMs,
  }) async {
    try {
      final box = _box;
      if (box == null || !box.isOpen) return;
      await box.put(
        _key(seasonId),
        UgcResumePoint(
          bvid: bvid,
          cid: cid,
          positionMs: positionMs,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ).toJson(),
      );
    } catch (_) {
      // 存储失败不影响播放，静默忽略
    }
  }

  static Future<void> clear(int seasonId) async {
    try {
      final box = _box;
      if (box == null || !box.isOpen) return;
      await box.delete(_key(seasonId));
    } catch (_) {}
  }
}
