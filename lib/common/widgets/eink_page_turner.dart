import 'package:PiliPlus/utils/eink.dart';
import 'package:material_ui/material_ui.dart';

/// 墨水屏用的整屏翻页键。
///
/// 墨水屏上手指长距离拖动会留下残影，滑动本身也不够利落，
/// 这里给长列表加一对「上一屏 / 下一屏」按钮，点一下直接跳一屏。
/// 用 `jumpTo` 而不是动画滚动，避免整屏刷新时的拖影。
///
/// 仅在墨水屏模式下显示，其他模式返回空占位，不影响原有布局。
class EinkPageTurner extends StatelessWidget {
  const EinkPageTurner({
    super.key,
    this.controller,
    this.width = 40,
    this.height = 40,
  });

  /// 要控制的列表；为空时回退到 [PrimaryScrollController]
  final ScrollController? controller;
  final double width;
  final double height;

  /// 一屏的比例，留一点重叠方便接上阅读位置
  static const double _pageRatio = 0.9;

  @override
  Widget build(BuildContext context) {
    if (!Eink.enabled) {
      return const SizedBox.shrink();
    }
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: Color(0xFFD8D8D8), width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(context, up: true),
          SizedBox(
            width: width,
            child: const Divider(height: 0.6, thickness: 0.6),
          ),
          _buildButton(context, up: false),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required bool up}) {
    return InkWell(
      onTap: () => _turn(context, up: up),
      child: SizedBox(
        width: width,
        height: height,
        child: Icon(
          up ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          size: 22,
          color: const Color(0xFF3C3C3C),
        ),
      ),
    );
  }

  void _turn(BuildContext context, {required bool up}) {
    final position = _position(context);
    if (position == null || !position.hasContentDimensions) {
      return;
    }
    final max = position.maxScrollExtent;
    if (max <= 0) {
      return;
    }
    if (up && position.pixels <= 0) {
      return;
    }
    final double step = position.viewportDimension * _pageRatio;
    final double target = up
        ? position.pixels - step
        : position.pixels + step;
    position.jumpTo(target.clamp(0.0, max).toDouble());
  }

  ScrollPosition? _position(BuildContext context) {
    final ctrl = controller;
    if (ctrl != null && ctrl.hasClients) {
      return ctrl.positions.first;
    }
    // 嵌套滚动（例如视频页里内嵌的评论区）没有独立控制器，
    // 由外层 NestedScrollView 通过 PrimaryScrollController 向下传递
    final primary = PrimaryScrollController.maybeOf(context);
    if (primary != null && primary.hasClients) {
      return primary.positions.first;
    }
    return null;
  }
}
