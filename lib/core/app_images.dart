// The file paths of the images the app can load, in one place.
// A path here must also be listed under "assets:" in pubspec.yaml.
class AppImages {
  AppImages._();

  static const String appIcon = 'assets/icon/app_icon.png';

// Note: app_icon_background.png and app_icon_foreground.png are NOT
// listed here. Only the flutter_launcher_icons tool uses them (see
// pubspec.yaml) to make the phone's app icon. The running app never
// loads them.
}