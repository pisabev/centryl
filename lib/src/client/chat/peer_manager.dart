part of chat;

class PeerManager {
  app.Application ap;
  final ChatController controller;
  int userId;
  List<PeerConnection> connections = [];
  CallView callView;
  CallStartView callStartView;
  StreamSubscription _sub;

  PeerManager(this.ap, this.controller, this.userId) {
    controller.onNotifyOffer.listen((offer) {
      if (callView == null && callStartView == null) return;
      final conn = getConnection(offer.from);
      if (offer.isAnswer)
        conn.handleOfferAnswer(offer);
      else {
        conn.handleOffer(offer);
        if (callStartView != null) initCallView(callStartView.room);
      }
    });
    controller.onNotifyIce.listen((ice) {
      if (callView == null) return;
      getConnection(ice.from).handleNewICECandidateMsg(ice);
    });
    controller.onCallAnswer.listen((room) {
      if (callStartView == null) return;
      initCallView(room);
    });
    controller.onCallStart.listen((room) {
      initCallStartView(room, caller: false)
        ..answer.enable()
        ..onAnswer = () => controller.callAnswer(room);
    });
    controller.onCallHangup.listen((room) {
      if (callStartView != null) closeCallStartView();
      if (callView != null) closeCallView();
    });
  }

  void removeConnection(int targetUserId) {
    final exist = connections.firstWhere(
        (c) => c.userId == userId && c.targetUserId == targetUserId,
        orElse: () => null);
    if (exist == null) return;
    exist._conn.close();
    connections.remove(exist);
  }

  PeerConnection getConnection(int targetUserId) {
    final exist = connections.firstWhere(
        (c) => c.userId == userId && c.targetUserId == targetUserId,
        orElse: () => null);
    if (exist != null) return exist;
    final con = new PeerConnection(controller, userId, targetUserId);
    con.onRemoteStream.listen((stream) {
      callView.videoRemote.dom
        ..autoplay = true
        ..srcObject = stream;
      callView.analyzer();
    });
    connections.add(con);
    return con;
  }

  CallStartView initCallStartView(Room room, {bool caller = true}) =>
      callStartView = new CallStartView(ap, room, caller: caller)
        ..onHangup = () {
          closeCallStartView();
          controller.callHangup(room);
        };

  void initCallView(Room room) {
    closeCallStartView();
    if (callView != null) return;
    _sub?.cancel();
    getConnection(room.members.first.user_id);
    callView = new CallView(ap, room)
      ..onHangup = () {
        closeCallView();
        controller.callHangup(room);
      };
    _sub = callView.localView.onLocalStreamChange
        .listen((s) => connections.forEach((c) => c.setLocalStream(s)));
  }

  void closeCallStartView() {
    if (callStartView == null) return;
    callStartView.close();
    callStartView = null;
  }

  void closeCallView() {
    if (callView == null) return;
    _sub?.cancel();
    removeConnection(callView.room.members.first.user_id);
    callView.close();
    callView = null;
  }

  Future<void> doCall(Room room) async {
    initCallStartView(room);
    controller.callStart(room);
  }
}

class LocalView {
  app.Application ap;
  Media media;
  app.Win win;
  CLElement<VideoElement> videoLocal;
  CLElement<VideoElement> videoScreen;
  MediaStream _localStreamVideo;
  MediaStream _localStreamScreen;
  action.Button settings;

  final StreamController<MediaStream> _localStreamContr =
      new StreamController.broadcast();

  Stream<MediaStream> get onLocalStreamChange => _localStreamContr.stream;

  LocalView(this.ap) {
    media = new Media();
    createDom();
  }

  void createDom() {
    videoLocal = new CLElement<VideoElement>(new VideoElement());
    settings = new action.Button()
      ..setIcon(Icon.settings)
      ..setTip(intl.Settings())
      ..addAction((e) => settingsPopUp());
    setStream();
  }

  Future<void> settingsPopUp() async {
    final selectVideo = new form.Select();
    final selectAudio = new form.Select();
    final cameras = await media.getDevices(type: DeviceKind.videoinput);
    cameras.forEach((c) => selectVideo.addOption(c.deviceId, c.label, false));
    final audios = await media.getDevices(type: DeviceKind.audioinput);
    audios.forEach((c) => selectAudio.addOption(c.deviceId, c.label, false));
    final map = ap.storageFetch('chat') ?? {};
    if (map['video_id'] != null) selectVideo.setValue(map['video_id']);
    if (map['audio_id'] != null) selectAudio.setValue(map['audio_id']);
    selectVideo.onValueChanged.listen((e) async {
      selectVideo.removeWarnings();
      final map = ap.storageFetch('chat') ?? {};
      map['video_id'] = e.getValue();
      ap.storagePut('chat', map);
      try {
        await setStream();
      } catch (e) {
        selectVideo.setWarning(new DataWarning('video', e.toString()));
      }
    });
    selectAudio.onValueChanged.listen((e) async {
      selectAudio.removeWarnings();
      final map = ap.storageFetch('chat') ?? {};
      map['audio_id'] = e.getValue();
      ap.storagePut('chat', map);
      try {
        await setStream();
      } catch (e) {
        selectAudio.setWarning(new DataWarning('video', e.toString()));
      }
    });
    final cont = new Container()
      ..append(selectVideo)
      ..append(selectAudio)
      ..addClass('ui-video-settings');
    new app.Confirmer(ap, cont)
      ..icon = Icon.settings
      ..title = intl.Settings()
      ..render(width: 250, height: 250);
  }

  Future<void> setShareStream() async {
    closeStreamScreen();
    _localStreamScreen = await media.getScreen();
    _localStreamContr.add(_localStreamScreen);
    videoScreen.dom
      ..autoplay = true
      ..srcObject = _localStreamScreen;
  }

  Future<void> setStream() async {
    closeStreamVideo();
    final map = ap.storageFetch('chat') ?? {};
    _localStreamVideo =
        await media.getUserMedia(map['video_id'], map['audio_id']);
    map['video_id'] =
        _localStreamVideo.getVideoTracks().first.getSettings()['deviceId'];
    map['audio_id'] =
        _localStreamVideo.getAudioTracks().first.getSettings()['deviceId'];
    ap.storagePut('chat', map);
    _localStreamContr.add(_localStreamVideo);
    videoLocal.dom
      ..autoplay = true
      ..muted = true
      ..srcObject = _localStreamVideo;
  }

  void closeStreamScreen() {
    _localStreamScreen?.getTracks()?.forEach((dynamic t) => t.stop());
    videoScreen?.dom?.srcObject = null;
    _localStreamScreen = null;
  }

  void closeStreamVideo() {
    _localStreamVideo
        ?.getTracks()
        ?.forEach(allowInterop((dynamic t) => t.stop()));
    videoLocal?.dom?.srcObject = null;
    _localStreamVideo = null;
  }

  void close() {
    closeStreamScreen();
    closeStreamVideo();
  }
}

class CallStartView {
  app.Application ap;
  app.Win win;
  Container contTop, contBottom;
  action.Button answer;
  action.Button hangup;
  void Function() onAnswer;
  void Function() onHangup;
  Room room;
  final bool caller;

  CallStartView(this.ap, this.room, {this.caller = true}) {
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
      ..auto = true
      ..append(calling.createDom(status: false))
      ..append(new HeadingElement.h2()..text = calling.name);
    contBottom = new Container()..addClass('bottom');
    if (!caller) contBottom.append(answer);
    contBottom.append(hangup);
    cont..addRow(contTop)..addRow(contBottom);
    win
      ..getContent().append(cont)
      ..render(300, 300);
    contBottom.append(new AudioElement()
      ..src = '${ap.baseurl}packages/centryl/sound/ringing.wav'
      ..play().catchError((e) => null));
  }

  void close() {
    win.close();
  }
}

class CallView {
  app.Application ap;
  app.Win win;
  Container contLeft, contRight, contRightTop, contRightBottom;
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
    final cont = new Container();
    contLeft = new Container()..auto = true;
    contRight = new Container()..addClass('ui-video-local');
    contRightTop = new Container();
    contRightBottom = new Container()..addClass('bottom');
    cont..addCol(contLeft)..addCol(contRight);
    contLeft
      ..addClass('ui-video-remote')
      ..append(videoRemote);
    contRight
      ..addRow(contRightTop
        ..append(localView.videoLocal)
        ..append(localView.settings..addClass('settings')))
      ..addRow(contRightBottom..append(hangup));
    win
      ..getContent().append(cont)
      ..render(1000, 600);
  }

  void close() {
    localView.close();
    win.close();
  }
}
