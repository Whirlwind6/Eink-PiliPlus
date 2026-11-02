import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/utils/eink.dart';
import 'package:material_ui/material_ui.dart';

/// 墨水屏下的模态底部面板。
///
/// `showModalBottomSheet` 的遮罩色被写死成 `Colors.black54`，主题里改不到，
/// 于是纯白页面会被压出一整片灰（墨水屏上看着就是一块巨大的"阴影"）。
/// 这里统一包一层：墨水屏下去掉遮罩、去掉投影，只用 1px 细边框分层。
///
/// 参数与原函数保持一致，替换调用点即可，非墨水屏模式下行为完全不变。
Future<T?> showEinkSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useSafeArea = false,
  bool enableDrag = true,
  Clip? clipBehavior,
  BoxConstraints? constraints,
}) {
  final bool eink = Eink.enabled;
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    enableDrag: enableDrag,
    clipBehavior: clipBehavior,
    constraints: constraints,
    backgroundColor: eink ? Colors.white : null,
    elevation: eink ? 0 : null,
    // 关键是这一行：默认 black54 的遮罩在墨水屏上就是一层灰雾
    barrierColor: eink ? Colors.transparent : null,
    shape: eink
        ? const RoundedRectangleBorder(
            borderRadius: Style.bottomSheetRadius,
            side: BorderSide(color: Color(0xFFD8D8D8), width: 0.8),
          )
        : null,
  );
}
