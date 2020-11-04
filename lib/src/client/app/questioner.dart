part of app;

class Questioner extends Dialog {
  action.Button yesDom, noDom;
  FutureOr<bool> Function() _callback_yes = () async => true;
  FutureOr<bool> Function() _callback_no = () async => true;

  Questioner(ap, container)
      : super(ap, new Container()..addRow(container..auto = true)) {
    yesDom = new action.Button()
      ..setTitle(intl.Yes())
      ..addAction((e) async {
        e.stopPropagation();
        if (await _callback_yes()) win.close();
      }, 'click');
    noDom = new action.Button()
      ..setTitle(intl.No())
      ..addAction((e) async {
        e.stopPropagation();
        if (await _callback_no()) win.close();
      }, 'click');
  }

  set onYes(FutureOr<bool> Function() callback_yes) =>
      _callback_yes = callback_yes;

  set onNo(FutureOr<bool> Function() callback_no) => _callback_no = callback_no;

  void render({int width = 400, int height = 300, bool scrollable = true}) {
    final m = new Container();
    final menu = new action.Menu(m)..add(yesDom)..add(noDom);
    menu.container..addClass('right')..addClass('dialog');
    container.addRow(m);
    super.render(width: width, height: height, scrollable: scrollable);
    win.win_close
      ..removeActionsAll()
      ..addAction((e) async {
        if (await _callback_no()) win.close();
      }, 'click');
  }
}
