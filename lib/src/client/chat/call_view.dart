part of chat;

class CallView {
  app.Application ap;
  late app.Win win;
  late Container contTop, contInner, contBottom;
  late CLElement<VideoElement> videoRemote;
  late action.Button hangup;
  final void Function() onHangup;
  Room room;
  late LocalView localView;

  CallView(this.ap, this.room, {required this.onHangup}) {
    localView = new LocalView(ap);
    createDom();
  }

  void analyzer() {
    // return;
    // final c = new AudioContext();
    // final mic = c.createMediaStreamSource(videoRemote.dom.srcObject);
    // final analyzer = c.createAnalyser();
    // mic.connectNode(analyzer);
    // final data = new Uint8List(100);
    // new Timer.periodic(const Duration(seconds: 1), (_) {
    //   analyzer.getByteFrequencyData(data);
    //   print(data);
    // });
  }

  void createDom() {
    win = ap.winmanager.loadWindow(title: room.getTitle(), icon: Icon.call);
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
        if (onHangup is Function) onHangup!();
      });
    final cont = new Container()..addClass('ui-video');
    contTop = new Container()..addClass('top');
    contInner = new Container()
      ..auto = true
      ..addClass('inner');
    contBottom = new Container()..addClass('bottom');
    cont..addRow(contTop)..addRow(contInner)..addRow(contBottom);
    contTop.addRow(localView.getContainer());
    contInner.append(videoRemote);
    contBottom
      ..append(hangup)
      ..append(localView.camera)
      ..append(localView.mic)
      ..append(localView.share);
    win
      ..getContent().append(cont)
      ..render(800, 600);
  }

  void close() {
    localView.close();
    win.close();
  }
}
