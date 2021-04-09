part of app;

class Confirmer extends Dialog {
  late action.Button okDom;
  Function _callback = () async => true;

  Confirmer(ap, container) : super(ap, container) {
    okDom = new action.Button()
      ..setTitle(intl.OK())
      ..addClass('important')
      ..addAction<Event>((e) async {
        e.stopPropagation();
        if (await _callback()) win?.close();
      }, 'click');
  }

  set onOk(Function callback) => _callback = callback;

  @override
  void render({int width = 400, int height = 300, bool scrollable = true}) {
    win = ap.winmanager.loadBoundWin(title: _title, icon: _icon);
    final m = new Container();
    final menu = new action.Menu(m)..add(okDom);
    menu.container..addClass('center')..addClass('dialog');
    final cont = new Container()
      ..auto = true
      ..append(container, scrollable: scrollable);
    win!.getContent()..addRow(cont)..addRow(m);
    win!.win.addClass('dialog');
    win!.render(width, height);
  }
}
