part of chat;

class PeerManager {
  app.Application ap;
  final ChatController controller;
  int userId;
  List<PeerConnection> connections = [];
  CallView callView;
  StreamSubscription _sub;

  PeerManager(this.ap, this.controller, this.userId) {
    controller.onNotifyOffer.listen((offer) {
      if (callView == null) return;
      final conn = getConnection(offer.from);
      if (offer.isAnswer)
        conn.handleOfferAnswer(offer);
      else
        conn.handleOffer(offer);
    });
    controller.onNotifyIce.listen((ice) {
      if (callView == null) return;
      getConnection(ice.from).handleNewICECandidateMsg(ice);
    });
    controller.onCallAnswer.listen((room) {
      if (callView == null) return;
      setStreamToTarget(room.members.first.user_id);
    });
    controller.onCallStart.listen((room) {
      initCallView(room);
      callView
        ..answer.enable()
        ..onAnswer = () async {
          setStreamToTarget(room.members.first.user_id);
          controller.callAnswer(room);
        };
    });
    controller.onCallHangup.listen((room) {
      removeConnection(room.members.first.user_id);
      if (connections.isEmpty) hangup(room);
    });
  }

  void setStreamToTarget(int targetId) {
    final conn = getConnection(targetId);
    if (callView.localView._localStreamVideo != null)
      conn.setLocalStream(callView.localView._localStreamVideo);
  }

  void removeConnection(int targetUserId) {
    final exist = connections.firstWhere(
        (c) => c.userId == userId && c.targetUserId == targetUserId,
        orElse: () => null);
    if (exist != null) return;
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

  void initCallView(Room room) {
    if (callView != null) return;
    _sub?.cancel();
    callView = new CallView(ap, room)..onHangup = () => hangup(room);
    callView.win.observer.addHook(app.Win.hookClose, (_) {
      hangup(room);
      return true;
    });
    _sub = callView.localView.onLocalStreamChange
        .listen((s) => connections.forEach((c) => c.setLocalStream(s)));
  }

  void hangup(Room room) {
    callView?.localView?.close();
    _sub.cancel();
    connections = [];
    callView = null;
    controller.callHangup(room);
  }

  Future<void> doCall(Room room) async {
    initCallView(room);
    controller.callStart(room);
  }
}

class LocalView {
  app.Application ap;
  Media media;
  app.Win win;
  CLElement<VideoElement> videoLocal;
  CLElement<VideoElement> videoScreen;
  form.Select selectVideo;
  form.Select selectAudio;
  MediaStream _localStreamVideo;
  MediaStream _localStreamScreen;

  final StreamController<MediaStream> _localStreamContr =
      new StreamController.broadcast();

  Stream<MediaStream> get onLocalStreamChange => _localStreamContr.stream;

  LocalView(this.ap) {
    media = new Media();
    createDom();
  }

  void createDom() {
    videoLocal = new CLElement<VideoElement>(new VideoElement());
    selectVideo = new form.Select()
      ..onValueChanged.listen((e) {
        final map = ap.storageFetch('chat') ?? {};
        map['video_id'] = e.getValue();
        ap.storagePut('chat', map);
        setStream();
      });
    selectAudio = new form.Select()
      ..onValueChanged.listen((e) {
        final map = ap.storageFetch('chat') ?? {};
        map['audio_id'] = e.getValue();
        ap.storagePut('chat', map);
        setStream();
      });
    initDevices();
  }

  void initDevices() {
    selectVideo.cleanOptions();
    selectAudio.cleanOptions();
    final map = ap.storageFetch('chat') ?? {};
    media.getDevices(type: DeviceKind.videoinput).then((cameras) {
      cameras.forEach((c) => selectVideo.addOption(c.deviceId, c.label, false));
      selectVideo.setValue(map['video_id']);
    });
    media.getDevices(type: DeviceKind.audioinput).then((audios) {
      audios.forEach((c) => selectAudio.addOption(c.deviceId, c.label, false));
      selectAudio.setValue(map['audio_id']);
    });
  }

  Future<void> setShareStream() async {
    try {
      _localStreamScreen?.getTracks()?.forEach((t) => t.stop());
      _localStreamScreen = await media.getScreen();
      _localStreamContr.add(_localStreamScreen);
      videoScreen.dom
        ..autoplay = true
        ..srcObject = _localStreamScreen;
    } catch (e) {}
  }

  Future<void> setStream() async {
    try {
      selectVideo.removeWarnings();
      final map = ap.storageFetch('chat') ?? {};
      _localStreamVideo?.getTracks()?.forEach((t) => t.stop());
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
      initDevices();
    } catch (e) {
      selectVideo.setWarning(new DataWarning('video', e.toString()));
    }
  }

  void close() {
    _localStreamVideo?.getTracks()?.forEach((t) => t.stop());
    _localStreamScreen?.getTracks()?.forEach((t) => t.stop());
  }
}

class CallView {
  app.Application ap;
  app.Win win;
  CLElement<VideoElement> videoRemote;
  action.Button answer;
  action.Button hangup;
  void Function() onAnswer;
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

    videoRemote = new CLElement<VideoElement>(new VideoElement());
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
        win.close();
      });
    final cont = new Container();
    final contLeft = new Container()..auto = true;
    final contRight = new Container();
    final contRightBottom = new Container();
    cont..addCol(contLeft)..addCol(contRight);
    contLeft
      ..addClass('ui-video-remote')
      ..append(videoRemote);
    contRight
      ..addClass('ui-video-local')
      ..append(localView.videoLocal)
      ..append(localView.selectVideo..addClass('max'))
      ..append(localView.selectAudio..addClass('max'))
      ..addRow(contRightBottom
        ..addClass('action')
        ..append(answer..addClass('answer'))
        ..append(hangup..addClass('hangup')));
    win
      ..getContent().append(cont)
      ..render(900, 400);
  }
}
