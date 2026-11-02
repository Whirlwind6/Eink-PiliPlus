import 'package:PiliPlus/utils/storage_pref.dart';

/// 墨水屏（E-Ink）优化的运行时开关。
///
/// 墨水屏的刷新代价很高，深色背景、图片、阴影、动画都会带来闪烁与残影，
/// 因此这里把相关设置缓存成静态变量，供 widget 的 build 方法直接读取，
/// 避免每帧都去读一次 Hive。
///
/// 启动时（`main()` 中 `GStorage.init()` 之后）与切换设置项后需要调用
/// [sync] 刷新缓存。
abstract final class Eink {
  /// 是否为墨水屏模式
  static bool enabled = false;

  /// 是否隐藏封面 / 内容图片
  static bool hideCover = false;

  /// 是否隐藏头像
  static bool hideAvatar = false;

  /// 是否不渲染视频画面（只听声音）
  static bool hideVideo = false;

  /// 从设置中重新读取开关
  static void sync() {
    enabled = Pref.einkMode;
    hideCover = enabled && Pref.einkHideCover;
    hideAvatar = enabled && Pref.einkHideAvatar;
    hideVideo = enabled && Pref.einkHideVideo;
  }

  /// 是否显示封面图（墨水屏下关闭图片即视为不需要封面）
  static bool get showCover => !hideCover;
}
