import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/utils/eink.dart';
import 'package:PiliPlus/utils/extension/theme_ext.dart';
import 'package:PiliPlus/utils/font_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoThemeData;
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:material_ui/material_ui.dart';

abstract final class ThemeUtils {
  static late ThemeData lightTheme;

  static late ThemeData darkTheme;

  static late ThemeMode themeMode;

  static ThemeData get theme {
    if (themeMode == .dark ||
        (themeMode == .system &&
            PlatformDispatcher.instance.platformBrightness == .dark)) {
      return darkTheme;
    }
    return lightTheme;
  }

  static bool get isDarkMode => theme.isDark;

  static String themeUrl(bool isDark) =>
      'native.theme=${isDark ? 2 : 1}&night=${isDark ? 1 : 0}';

  static ThemeData getThemeData({
    required ColorScheme colorScheme,
    required bool isDynamic,
    bool isDark = false,
  }) {
    final fontWeight = Pref.appFontWeight == .normal && Eink.enabled
        ? FontWeight.w500
        : Pref.appFontWeight;
    final fontFamily = FontUtils.fontFamily;

    TextTheme? textTheme;
    if (fontWeight != .normal) {
      final textStyle = TextStyle(fontWeight: fontWeight);
      textTheme = TextTheme(
        displayLarge: textStyle,
        displayMedium: textStyle,
        displaySmall: textStyle,
        headlineLarge: textStyle,
        headlineMedium: textStyle,
        headlineSmall: textStyle,
        titleLarge: textStyle,
        titleMedium: textStyle,
        titleSmall: textStyle,
        bodyLarge: textStyle,
        bodyMedium: textStyle,
        bodySmall: textStyle,
        labelLarge: textStyle,
        labelMedium: textStyle,
        labelSmall: textStyle,
      );
    }

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          color: colorScheme.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        surfaceTintColor: isDark ? colorScheme.surfaceContainerHighest : null,
      ),
      snackBarTheme: SnackBarThemeData(
        elevation: 20,
        actionTextColor: colorScheme.primary,
        closeIconColor: colorScheme.secondary,
        backgroundColor: colorScheme.secondaryContainer,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: fontWeight,
          color: colorScheme.onSecondaryContainer,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        surfaceTintColor: isDark ? colorScheme.surfaceContainerHighest : null,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        surfaceTintColor: isDark ? colorScheme.onSurfaceVariant : null,
      ),
      progressIndicatorTheme: isDark
          ? ProgressIndicatorThemeData(
              // ignore: deprecated_member_use
              year2023: false,
              refreshBackgroundColor: colorScheme.onInverseSurface,
            )
          // ignore: deprecated_member_use
          : const ProgressIndicatorThemeData(year2023: false),
      dialogTheme: DialogThemeData(
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          color: colorScheme.onSurface,
        ),
        backgroundColor: colorScheme.surface,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: Style.bottomSheetRadius,
        ),
      ),
      // ignore: deprecated_member_use
      sliderTheme: const SliderThemeData(year2023: false),
      tooltipTheme: TooltipThemeData(
        textStyle: TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontFamily: fontFamily,
          fontWeight: fontWeight,
        ),
        decoration: const BoxDecoration(
          color: Color(0xE6616161), // Colors.grey[700]!.withValues(alpha: 0.9)
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        selectionHandleColor: colorScheme.primary,
      ),
      switchTheme: const SwitchThemeData(
        padding: .zero,
        materialTapTargetSize: .shrinkWrap,
        thumbIcon: WidgetStateProperty<Icon?>.fromMap(
          <WidgetStatesConstraint, Icon?>{
            WidgetState.selected: Icon(Icons.done),
            WidgetState.any: null,
          },
        ),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        shape: Border(),
        collapsedShape: Border(),
      ),
      listTileTheme: const ListTileThemeData(controlAffinity: .leading),
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(
          shadowColor: WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        },
      ),
    );
    if (isDark && Pref.isPureBlackTheme) {
      return darkenTheme(theme);
    }
    if (Eink.enabled && !isDark) {
      return einkTheme(theme);
    }
    return theme;
  }

  /// 墨水屏主题
  ///
  /// 墨水屏只有灰阶、且每次刷新都会闪烁，因此：
  /// - 所有容器表面统一为纯白，文字为近黑色，去掉 Material You 的色调叠加
  /// - 阴影、elevation 全部去掉，改用 1px 细线区分层次（纯色块在墨水屏上几乎不反光，阴影只会糊成脏灰色）
  /// - 去掉水波纹与点击高亮，减少无意义的局部刷新
  static ThemeData einkTheme(ThemeData theme) {
    const paper = Colors.white;
    const ink = Color(0xFF111111);
    const inkSecondary = Color(0xFF3C3C3C);
    const line = Color(0xFFD8D8D8);
    const surfaceHigh = Color(0xFFF6F6F6);
    const surfaceHighest = Color(0xFFEEEEEE);

    final colorScheme = theme.colorScheme.copyWith(
      brightness: .light,
      primary: ink,
      onPrimary: paper,
      primaryContainer: const Color(0xFFE4E4E4),
      onPrimaryContainer: ink,
      inversePrimary: inkSecondary,
      secondary: inkSecondary,
      onSecondary: paper,
      secondaryContainer: const Color(0xFFEAEAEA),
      onSecondaryContainer: ink,
      tertiary: inkSecondary,
      onTertiary: paper,
      surface: paper,
      onSurface: ink,
      surfaceTint: paper,
      surfaceDim: paper,
      surfaceBright: paper,
      surfaceContainerLowest: paper,
      surfaceContainerLow: paper,
      surfaceContainer: paper,
      surfaceContainerHigh: surfaceHigh,
      surfaceContainerHighest: surfaceHighest,
      onSurfaceVariant: inkSecondary,
      inverseSurface: ink,
      // 部分控件把它当作浅色底使用，保持一个很浅的灰，避免与纯白背景糊在一起
      onInverseSurface: const Color(0xFFEDEDED),
      outline: const Color(0xFF757575),
      outlineVariant: line,
      shadow: Colors.transparent,
      scrim: const Color(0x66000000),
    );

    const border = BorderSide(color: line, width: 0.8);
    const radius = BorderRadius.all(Radius.circular(8));

    return theme.copyWith(
      colorScheme: colorScheme,
      canvasColor: paper,
      scaffoldBackgroundColor: paper,
      // Material 的投影色默认取 ThemeData.shadowColor，
      // 归零后所有 elevation 阴影（卡片、弹窗、底部面板）一并消失
      shadowColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
      ),
      cardTheme: theme.cardTheme.copyWith(
        color: paper,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: radius,
          side: border,
        ),
      ),
      dialogTheme: theme.dialogTheme.copyWith(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: radius,
          side: border,
        ),
      ),
      bottomSheetTheme: theme.bottomSheetTheme.copyWith(
        backgroundColor: paper,
        modalBackgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        // 弹出式面板走 modalElevation，默认是 1，仍有投影，这里一并归零
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: Style.bottomSheetRadius,
          side: BorderSide(color: line, width: 0.8),
        ),
      ),
      popupMenuTheme: theme.popupMenuTheme.copyWith(
        color: paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: radius,
          side: border,
        ),
      ),
      navigationBarTheme: theme.navigationBarTheme.copyWith(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        indicatorColor: surfaceHighest,
      ),
      navigationRailTheme: theme.navigationRailTheme.copyWith(
        backgroundColor: paper,
        elevation: 0,
        indicatorColor: surfaceHighest,
      ),
      bottomNavigationBarTheme: theme.bottomNavigationBarTheme.copyWith(
        backgroundColor: paper,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: line,
        thickness: 0.6,
        space: 0.6,
      ),
      snackBarTheme: theme.snackBarTheme.copyWith(
        backgroundColor: const Color(0xFFE8E8E8),
        elevation: 0,
        contentTextStyle: theme.snackBarTheme.contentTextStyle?.copyWith(
          color: ink,
        ),
      ),
      listTileTheme: theme.listTileTheme.copyWith(
        iconColor: inkSecondary,
        textColor: ink,
      ),
      iconTheme: theme.iconTheme.copyWith(color: inkSecondary),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: ink,
        selectionColor: const Color(0x33202020),
        selectionHandleColor: inkSecondary,
      ),
    );
  }

  static ThemeData darkenTheme(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final color = colorScheme.surfaceContainerHighest.darken(0.7);
    return theme.copyWith(
      canvasColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: Colors.black,
      ),
      cardTheme: theme.cardTheme.copyWith(
        color: colorScheme.surfaceContainer.darken(0.75),
      ),
      dialogTheme: theme.dialogTheme.copyWith(backgroundColor: color),
      bottomSheetTheme: theme.bottomSheetTheme.copyWith(
        backgroundColor: color,
      ),
      bottomNavigationBarTheme: theme.bottomNavigationBarTheme.copyWith(
        backgroundColor: color,
      ),
      navigationBarTheme: theme.navigationBarTheme.copyWith(
        backgroundColor: color,
      ),
      navigationRailTheme: theme.navigationRailTheme.copyWith(
        backgroundColor: Colors.black,
      ),
      popupMenuTheme: theme.popupMenuTheme.copyWith(color: color),
      colorScheme: colorScheme.copyWith(
        primary: colorScheme.primary.darken(0.1),
        onPrimary: colorScheme.onPrimary.darken(0.1),
        primaryContainer: colorScheme.primaryContainer.darken(0.1),
        onPrimaryContainer: colorScheme.onPrimaryContainer.darken(0.1),
        inversePrimary: colorScheme.inversePrimary.darken(0.1),
        secondary: colorScheme.secondary.darken(0.05),
        onSecondary: colorScheme.onSecondary.darken(0.05),
        secondaryContainer: colorScheme.secondaryContainer.darken(0.05),
        onSecondaryContainer: colorScheme.onSecondaryContainer.darken(0.05),
        error: colorScheme.error.darken(0.05),
        surface: Colors.black,
        onSurface: colorScheme.onSurface.darken(0.15),
        surfaceTint: colorScheme.surfaceTint.darken(),
        inverseSurface: colorScheme.inverseSurface.darken(),
        onInverseSurface: colorScheme.onInverseSurface.darken(),
        surfaceContainer: colorScheme.surfaceContainer.darken(),
        surfaceContainerHigh: colorScheme.surfaceContainerHigh.darken(),
        surfaceContainerHighest: colorScheme.surfaceContainerHighest.darken(
          0.4,
        ),
      ),
    );
  }
}
