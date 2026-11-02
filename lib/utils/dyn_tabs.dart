import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';

/// 动态页标签的运行时视图。
///
/// 动态页原来直接遍历 [DynamicsTabType.values]，用户无法裁剪。
/// 这里把「设置 → 动态设置 → 动态标签页」保存的下标列表转成枚举列表，
/// 存的是枚举下标而不是位置，这样以后枚举顺序调整也不会错位。
///
/// 注意：动态页的 TabBar、TabBarView、每个标签的控制器 tag 都用同一个列表，
/// 三处必须保持一致，否则下标会错位。
abstract final class DynTabs {
  static List<DynamicsTabType>? _cache;

  /// 默认标签。
  ///
  /// 去掉了「番剧」和「UP」：「番剧」会额外拉一整屏封面图，「UP」只是按 UP 主
  /// 筛选，两者在墨水屏上都不划算。需要时可在
  /// 设置 → 动态设置 → 动态标签页 里勾选加回来。
  static const List<DynamicsTabType> defaultTypes = [
    DynamicsTabType.all,
    DynamicsTabType.video,
    DynamicsTabType.article,
  ];

  /// 当前生效的标签列表（至少一项）
  static List<DynamicsTabType> get list {
    final cached = _cache;
    if (cached != null) return cached;

    final saved = GStorage.setting.get(SettingBoxKey.dynTabSort) as List?;
    final result = <DynamicsTabType>[];
    if (saved != null) {
      for (final i in saved) {
        if (i is int && i >= 0 && i < DynamicsTabType.values.length) {
          final type = DynamicsTabType.values[i];
          if (!result.contains(type)) result.add(type);
        }
      }
    }
    // 没配置过、或配置被清空时回退到默认列表，避免页面没有任何标签
    if (result.isEmpty) {
      result.addAll(defaultTypes);
    } else if (result.length == DynamicsTabType.values.length) {
      // 保存过「全选」等于没裁剪（设置页的默认就是全选），
      // 这里按默认列表处理，保证「番剧」「UP」默认是关掉的
      result
        ..clear()
        ..addAll(defaultTypes);
    }
    return _cache = result;
  }

  /// 修改设置后需要调用，下次读取重新从存储解析
  static void refresh() => _cache = null;

  /// 把 [DynamicsTabType] 转成它在当前列表中的位置，找不到返回 -1
  static int indexOf(DynamicsTabType type) => list.indexOf(type);
}
