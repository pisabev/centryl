part of chat;

class CallStartView {
  app.Application ap;
  app.Win win;
  Container contTop, contBottom;
  action.Button answer;
  action.Button hangup;
  final void Function() onAnswer;
  final void Function() onHangup;
  Room room;
  final bool caller;
  Timer _timer;
  Duration duration = const Duration(seconds: 30);

  CallStartView(this.ap, this.room,
      {this.onHangup, this.onAnswer, this.caller = true}) {
    createDom();
  }

  void createDom() {
    final calling = room.members.firstWhere((m) => !m.isMe);
    win = ap.winmanager.loadWindow(title: intl.Calling(), icon: Icon.call);
    win.win_close.hide();
    answer = new action.Button()
      ..setIcon(Icon.call)
      ..disable()
      ..addClass('important')
      ..addAction((e) {
        answer.disable();
        if (onAnswer is Function) onAnswer();
      });
    hangup = new action.Button()
      ..setIcon(Icon.call_end)
      ..addClass('warning')
      ..addAction((e) {
        if (onHangup is Function) onHangup();
      });
    final cont = new Container()..addClass('ui-call-start');
    contTop = new Container()
      ..addClass('top')
      ..append(calling.createDom(showStatus: false))
      ..append(new HeadingElement.h2()..text = calling.name);
    contBottom = new Container()..addClass('bottom');
    if (!caller) contBottom.append(answer);
    contBottom.append(hangup);
    cont..addRow(contTop)..addRow(contBottom);
    win
      ..getContent().append(cont)
      ..render(300, 300);
    contBottom.append(new AudioElement()
      ..loop = true
      ..src = '${ap.baseurl}packages/centryl/sound/ringing.wav'
      ..play().catchError((e) => null));
    _timer = new Timer(duration, onHangup);
  }

  void close() {
    _timer.cancel();
    win.close();
  }
}
