part of chat;

class CallView {
  app.Application ap;
  app.Win win;
  Container contTop, contInner, contBottom;
  CLElement<VideoElement> videoRemote;
  action.Button hangup;
  void Function() onHangup;
  Room room;
  LocalView localView;

  CallView(this.ap, this.room) {
    localView = new LocalView(ap);
    createDom();
  }

  void analyzer() {
    return;
    final c = new AudioContext();
    final mic = c.createMediaStreamSource(videoRemote.dom.srcObject);
    final analyzer = c.createAnalyser();
    mic.connectNode(analyzer);
    final data = new Uint8List(100);
    new Timer.periodic(const Duration(seconds: 1), (_) {
      analyzer.getByteFrequencyData(data);
      print(data);
    });
  }

  void createDom() {
    win = ap.winmanager.loadWindow(title: room.title, icon: Icon.call);
    win.win_close.hide();
    // win.observer.addHook(app.Win.hookClose, (_) {
    //   if (onHangup is Function && !_closed) onHangup();
    //   return true;
    // });
    videoRemote = new CLElement<VideoElement>(new VideoElement());
    hangup = new action.Button()
      ..setIcon(Icon.call_end)
      ..addClass('warning')
      ..addAction((e) {
        if (onHangup is Function) onHangup();
      });
    final share = new action.Button()
      ..setIcon(Icon.content_copy)
      ..addClass('attention')
      ..addAction((e) => localView.setShareStream());
    final cont = new Container()..addClass('ui-video');
    contTop = new Container()..addClass('top');
    contInner = new Container()
      ..auto = true
      ..addClass('inner');
    contBottom = new Container()..addClass('bottom');
    cont..addRow(contTop)..addRow(contInner)..addRow(contBottom);
    contTop.addRow(localView.getContainer());
    contInner.append(videoRemote);
    contBottom..append(hangup)..append(share);
    win
      ..getContent().append(cont)
      ..render(800, 600);
  }

  void close() {
    localView.close();
    win.close();
  }
}
