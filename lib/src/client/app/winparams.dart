part of app;

class WinParams extends WinMeta {
  Map<String, dynamic> get map => {
    'title': title,
    'icon': icon,
    'type': type,
    'width': width,
    'height': height,
    'left': left,
    'top': top,
  };
}