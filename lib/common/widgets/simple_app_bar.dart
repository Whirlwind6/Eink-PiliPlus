import 'package:PiliPlus/utils/eink.dart';
import 'package:PiliPlus/utils/extension/theme_ext.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:material_ui/material_ui.dart';

class SimpleAppBar extends StatelessWidget {
  const SimpleAppBar({
    super.key,
    required this.height,
    required this.brightness,
    this.statusBarBrightness = .dark,
    this.statusBarIconBrightness = .light,
    this.backgroundColor,
  });

  final double height;
  final Brightness brightness;
  final Brightness statusBarBrightness;
  final Brightness statusBarIconBrightness;

  /// 为空时默认黑色；墨水屏模式下默认跟随主题表面色
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    // 墨水屏下顶部条一律跟随主题表面色（白色），图标改为深色。
    // 这里不判断调用方是否显式传了黑色，否则播放页会漏出黑条
    final isEink = Eink.enabled;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarBrightness: isEink ? brightness : statusBarBrightness,
        statusBarIconBrightness: isEink
            ? brightness.reverse
            : statusBarIconBrightness,
        statusBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: brightness.reverse,
      ),
      child: ColoredBox(
        color: isEink
            ? ColorScheme.of(context).surface
            : (backgroundColor ?? Colors.black),
        child: SizedBox(height: height, width: .infinity),
      ),
    );
  }
}
