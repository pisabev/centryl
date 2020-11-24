part of chat;

class LocalView {
  app.Application ap;
  Media media;
  app.Win win;
  CLElement<VideoElement> videoLocal;
  MediaStream _localStream;
  action.Button settings, share, mic, camera;
  bool shareOn, micOn, cameraOn;

  final StreamController<MediaStream> _localStreamContr =
      new StreamController.broadcast();

  Stream<MediaStream> get onLocalStreamChange => _localStreamContr.stream;

  LocalView(this.ap,
      {this.shareOn = false, this.micOn = true, this.cameraOn = false}) {
    media = new Media();
    createDom();
    init();
  }

  void createDom() {
    share = new action.Button()
      ..hide()
      ..addClass('light')
      ..setIcon(Icon.content_copy)
      ..addAction((e) => shareAction());
    camera = new action.Button()
      ..hide()
      ..addClass('light')
      ..addAction((e) => cameraAction());
    mic = new action.Button()
      ..hide()
      ..addClass('light')
      ..addAction((e) => micAction());
    videoLocal = new CLElement<VideoElement>(new VideoElement());
    settings = new action.Button()
      ..setIcon(Icon.settings)
      ..setTip(intl.Settings())
      ..addAction((e) => settingsPopUp());
  }

  Future<void> init() async {
    if (shareOn)
      await shareAction(true);
    else
      await initAudioVideo(true);
    mic.show();
    camera.show();
    share.show();
  }

  Future<void> initAudioVideo([bool init = false]) async {
    final stream = await getStreamAudioVideo();
    _setStream(stream);
    micAction(init);
    cameraAction(init);
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
    final previewLocal = new CLElement<VideoElement>(new VideoElement());
    MediaStream stream;
    void setPreviewStream(MediaStream str) {
      previewLocal.dom
        ..autoplay = true
        ..muted = true
        ..srcObject = str;
      stream = str;
    }
    setPreviewStream(await getStreamAudioVideo());
    selectVideo.onValueChanged.listen((e) async {
      selectVideo.removeWarnings();
      final map = ap.storageFetch('chat') ?? {};
      map['video_id'] = e.getValue();
      ap.storagePut('chat', map);
      try {
        setPreviewStream(await getStreamAudioVideo());
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
        setPreviewStream(await getStreamAudioVideo());
      } catch (e) {
        selectAudio.setWarning(new DataWarning('audio', e.toString()));
      }
    });
    final cont = new Container()
      ..append(previewLocal)
      ..append(selectVideo)
      ..append(selectAudio)
      ..addClass('ui-video-settings');
    final w = new app.Confirmer(ap, cont)
      ..icon = Icon.settings
      ..title = intl.Settings()
      ..onOk = (() => true)
      ..render(width: 250, height: 450);
    w.win.observer.addHook(app.Win.hookClose, (_) {
      previewLocal.dom.srcObject = null;
      return true;
    });
  }

  Future<void> shareAction([bool init = false]) async {
    if (!init && shareOn) {
      await initAudioVideo(true);
    } else {
      final stream = await getStreamShare();
      _setStream(stream);
    }
    if (!init) shareOn = !shareOn;
    shareOn ? share.addClass('attention') : share.removeClass('attention');
  }

  void micAction([bool init = false]) {
    if (!init) micOn = !micOn;
    _localStream.getAudioTracks().forEach((t) => t.enabled = micOn);
    mic.setIcon(micOn ? Icon.mic : Icon.mic_off);
  }

  void cameraAction([bool init = false]) {
    if (!init) cameraOn = !cameraOn;
    _localStream.getVideoTracks().forEach((t) => t.enabled = cameraOn);
    camera.setIcon(cameraOn ? Icon.videocam : Icon.videocam_off);
  }

  Future<MediaStream> getStreamShare() async {
    final stream = await media.getScreen();
    final audio = await media.getUserMediaAudio(null);
    audio.getAudioTracks().forEach(stream.addTrack);
    return stream;
  }

  Future<MediaStream> getStreamAudioVideo() async {
    final map = ap.storageFetch('chat') ?? {};
    final stream = await media.getUserMedia(map['video_id'], map['audio_id']);
    map['video_id'] = stream.getVideoTracks().first.getSettings()['deviceId'];
    map['audio_id'] = stream.getAudioTracks().first.getSettings()['deviceId'];
    ap.storagePut('chat', map);
    return stream;
  }

  void _setStream(MediaStream stream) {
    closeStream();
    _localStream = stream;
    _localStreamContr.add(_localStream);
    videoLocal.dom
      ..autoplay = true
      ..muted = true
      ..srcObject = _localStream;
  }

  void closeStream() {
    _localStream?.getTracks()?.forEach(allowInterop((dynamic t) => t.stop()));
    _localStream = null;
  }

  void close() {
    closeStream();
  }

  Container getContainer() => new Container()
    ..addClass('local-video')
    ..append(videoLocal)
    ..append(settings);
}
