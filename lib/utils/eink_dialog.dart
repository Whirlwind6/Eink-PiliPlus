import 'package:PiliPlus/utils/eink.dart';
import 'package:material_ui/material_ui.dart';

/// 统一包装 `showDialog`。
///
/// `showDialog` 的 `barrierColor` 在框架里默认写死成 `Colors.black54`，
/// 主题的 `scrim` 也覆盖不到它。墨水屏上白页面会被压掉一半亮度，
/// 看起来就是一整屏灰雾，还会触发全屏反色刷新。
///
/// 这里只在墨水屏模式下把遮罩换成极浅的灰：既保留"下层不可点"的视觉暗示，
/// 又不至于整屏变暗。其他模式原样传 null，行为和官方一致。
Future<T?> showEinkDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  bool? requestFocus,
}) {
  return showDialog<T>(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible,
    // 显式传了遮罩色的调用点保持原样（例如需要完全透明的音量条）
    barrierColor: barrierColor ?? _einkBarrier,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    requestFocus: requestFocus,
  );
}

Color? get _einkBarrier =>
    Eink.enabled ? const Color(0x14000000) : null;
