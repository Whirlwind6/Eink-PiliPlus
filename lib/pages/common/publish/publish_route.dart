import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:material_ui/material_ui.dart';
import 'package:PiliPlus/utils/eink.dart';

class PublishRoute<T> extends PopupRoute<T> {
  PublishRoute({
    required this.pageBuilder,
    this.barrierDismissible = true,
    this.barrierLabel,
    Color? barrierColor,
    Duration? transitionDuration,
    this._transitionBuilder,
    super.settings,
  }) : _barrierColor = barrierColor,
       transitionDuration =
           transitionDuration ??
           (PlatformUtils.isDesktop
               ? const Duration(milliseconds: 400)
               : const Duration(milliseconds: 500));

  final RoutePageBuilder pageBuilder;

  @override
  final bool barrierDismissible;

  @override
  final String? barrierLabel;

  final Color? _barrierColor;

  /// 发布页是全屏白底，默认的 50% 黑遮罩在墨水屏上会压出一整屏灰
  @override
  Color get barrierColor =>
      _barrierColor ??
      (Eink.enabled ? const Color(0x14000000) : const Color(0x80000000));

  @override
  final Duration transitionDuration;

  final RouteTransitionsBuilder? _transitionBuilder;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: pageBuilder(context, animation, secondaryAnimation),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (_transitionBuilder != null) {
      return _transitionBuilder(context, animation, secondaryAnimation, child);
    }
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ),
      ),
      child: child,
    );
  }
}
