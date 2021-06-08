part of app;

class Questioner extends Dialog {
  late action.Button yesDom, noDom;
  FutureOr<bool> Function() _callback_yes = () async => true;
  FutureOr<bool> Function() _callback_no = () async => true;

  Questioner(ap, container) : super(ap, container) {
    yesDom = new action.Button()
      ..setTitle(intl.Yes())
      ..addAction<Event>((e) async {
        e.stopPropagation();
        if (await _callback_yes()) win?.close();
      }, 'click');
    noDom = new action.Button()
      ..setTitle(intl.No())
      ..addAction<Event>((e) async {
        e.stopPropagation();
        if (await _callback_no()) win?.close();
      }, 'click');
  }

  set onYes(FutureOr<bool> Function() callback_yes) =>
      _callback_yes = callback_yes;

  set onNo(FutureOr<bool> Function() callback_no) => _callback_no = callback_no;

  void render({int width = 400, int height = 300, bool scrollable = true}) {
    win = ap.winmanager.loadBoundWin(title: _title ?? '', icon: _icon);
    final m = new Container();
    final menu = new action.Menu(m)..add(yesDom)..add(noDom);
    menu.container..addClass('right')..addClass('dialog');
    final cont = new Container()
      ..auto = true
      ..append(container, scrollable: scrollable);
    win!.getContent()..addRow(cont)..addRow(m);
    win!.win.addClass('dialog');
    win!.render(width, height);
    win!.win_close
      ..removeActionsAll()
      ..addAction((e) async {
        if (await _callback_no()) win!.close();
      }, 'click');
  }
}
