import 'package:PiliPlus/common/style.dart';
import 'package:material_ui/material_ui.dart';
import 'package:PiliPlus/utils/eink.dart';

Widget selectMask(
  ColorScheme colorScheme,
  bool checked, {
  BorderRadiusGeometry borderRadius = Style.mdRadius,
}) {
  return AnimatedOpacity(
    opacity: checked ? 1 : 0,
    duration: const Duration(milliseconds: 200),
    child: Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        // 墨水屏下 60% 黑蒙层会变成一片深灰，改成浅灰
        color: Eink.enabled
            ? const Color(0xFFDCDCDC)
            : Colors.black.withValues(alpha: 0.6),
      ),
      child: AnimatedScale(
        scale: checked ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.done_all_outlined,
            color: colorScheme.primary,
            semanticLabel: '取消选择',
          ),
        ),
      ),
    ),
  );
}
