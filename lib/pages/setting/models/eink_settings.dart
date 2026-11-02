import 'package:PiliPlus/pages/setting/models/model.dart';
import 'package:PiliPlus/utils/eink.dart';
import 'package:PiliPlus/utils/extension/get_ext.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// 切换开关后立即刷新：重新读取缓存 + 重建主题 + 重建界面
void _onEinkChanged(bool value) {
  Eink.sync();
  Get.updateMyAppTheme();
  Get.appUpdate();
}

List<SettingsModel> get einkSettings => [
  SwitchModel(
    title: '墨水屏模式',
    subtitle: '强制浅色、纯白背景，去掉阴影与渐变，并默认隐藏所有封面图',
    leading: const Icon(Icons.auto_stories_outlined),
    setKey: SettingBoxKey.einkMode,
    // 与 Pref.einkMode 的默认值保持一致，否则开关显示「关」但界面已是墨水屏
    defaultVal: true,
    onChanged: _onEinkChanged,
  ),
  SwitchModel(
    title: '隐藏封面图',
    subtitle: '封面、动态配图、视频详情配图等一律不加载，只显示文字；需先开启墨水屏模式',
    leading: const Icon(Icons.hide_image_outlined),
    setKey: SettingBoxKey.einkHideCover,
    defaultVal: true,
    onChanged: _onEinkChanged,
  ),
  SwitchModel(
    title: '隐藏头像',
    subtitle: '头像不加载，显示为灰色圆点；需先开启墨水屏模式',
    leading: const Icon(Icons.account_circle_outlined),
    setKey: SettingBoxKey.einkHideAvatar,
    defaultVal: false,
    onChanged: _onEinkChanged,
  ),
  SwitchModel(
    title: '不显示视频画面',
    subtitle: '播放器只输出声音，画面区域保持纯白静止，避免整块高频刷新；需先开启墨水屏模式',
    leading: const Icon(Icons.hearing_outlined),
    setKey: SettingBoxKey.einkHideVideo,
    defaultVal: true,
    onChanged: _onEinkChanged,
  ),
  const NormalModel(
    title: '说明',
    subtitle: '卡片高度、列表列数等布局参数在页面创建时确定，切换后若排版未刷新，重启 App 即可；'
        '直播间画面不属于播放器，仍是深色',
    leading: Icon(Icons.info_outline),
  ),
];
