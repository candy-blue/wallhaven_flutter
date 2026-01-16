// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Wallhaven Flutter';

  @override
  String get searchHint => '搜索壁纸...';

  @override
  String get settings => '设置';

  @override
  String get loginApiKey => '登录 / API Key';

  @override
  String get apiKey => 'API Key';

  @override
  String get enterApiKey => '输入您的 Wallhaven API Key';

  @override
  String get username => '用户名';

  @override
  String get enterUsername => '输入您的 Wallhaven 用户名';

  @override
  String get usernameRequiredForCollections => '查看收藏夹需要输入用户名';

  @override
  String get pleaseEnterUsername => '请在设置中输入用户名';

  @override
  String get save => '保存';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

  @override
  String get categories => '分类';

  @override
  String get purity => '纯净度';

  @override
  String get sorting => '排序';

  @override
  String get general => '普通';

  @override
  String get anime => '动漫';

  @override
  String get people => '人物';

  @override
  String get sfw => '安全';

  @override
  String get sketchy => '擦边';

  @override
  String get nsfw => 'R18';

  @override
  String get dateAdded => '添加日期';

  @override
  String get relevance => '相关度';

  @override
  String get random => '随机';

  @override
  String get views => '浏览量';

  @override
  String get favorites => '收藏数';

  @override
  String get toplist => '排行榜';

  @override
  String get hot => '热度';

  @override
  String get saved => '已保存!';

  @override
  String get download => '下载';

  @override
  String get resolution => '分辨率';

  @override
  String get size => '大小';

  @override
  String get category => '分类';

  @override
  String get noWallpapersFound => '未找到壁纸';

  @override
  String get error => '错误';

  @override
  String get downloading => '下载中...';

  @override
  String downloadedTo(Object path) {
    return '已下载至 $path';
  }

  @override
  String get savedToGallery => '已保存到相册!';

  @override
  String get webDownloadNotImplemented => '网页版下载暂未实现';

  @override
  String get aiArt => 'AI 绘画';

  @override
  String get loginReminder => '请在设置中配置 API Key 以解锁全部功能。';

  @override
  String get pleaseLoginFirst => '请先登录以使用此功能';

  @override
  String get removedFromFavorites => '已取消收藏';

  @override
  String get addedToFavorites => '已添加到收藏';

  @override
  String get operationFailed => '操作失败';

  @override
  String get cannotOpenLink => '无法打开链接';

  @override
  String get shareFailed => '分享失败';

  @override
  String get downloadPath => '下载路径';

  @override
  String get defaultDownloadsFolder => '默认 (下载文件夹)';

  @override
  String get tapIconToChange => '点击图标修改';

  @override
  String get ratios => '比例';

  @override
  String get colors => '颜色';

  @override
  String get order => '顺序';

  @override
  String get topRange => '排行范围';

  @override
  String get apply => '应用';

  @override
  String get reset => '重置';

  @override
  String get asc => '升序';

  @override
  String get desc => '降序';

  @override
  String get lastDay => '最近1天';

  @override
  String get last3Days => '最近3天';

  @override
  String get lastWeek => '最近1周';

  @override
  String get lastMonth => '最近1月';

  @override
  String get last3Months => '最近3月';

  @override
  String get last6Months => '最近6月';

  @override
  String get lastYear => '最近1年';
}
