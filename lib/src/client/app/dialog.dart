part of app;

class Dialog {
  Application ap;
  late String _icon, _title;
  Container container;
  Win? win;

  Dialog(this.ap, this.container);

  set title(String title) => _title = title;

  set icon(String icon) => _icon = icon;

  void close() => win?.close();

  void render({int width = 400, int height = 300, bool scrollable = true}) {
    win = ap.winmanager.loadBoundWin(title: _title, icon: _icon);
    win!.getContent().append(container, scrollable: scrollable);
    win!.win.addClass('dialog');
    win!.render(width, height);
  }
}
