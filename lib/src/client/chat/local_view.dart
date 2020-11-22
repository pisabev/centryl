part of chat;

class LocalView {
  app.Application ap;
  Media media;
  app.Win win;
  CLElement<VideoElement> videoLocal, previewLocal;
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
    previewLocal = new CLElement<VideoElement>(new VideoElement());
    previewLocal.dom
      ..autoplay = true
      ..muted = true
      ..srcObject = _localStreamVideo;
    final cont = new Container()
      ..append(previewLocal)
      ..append(selectVideo)
      ..append(selectAudio)
      ..addClass('ui-video-settings');
    final w = new app.Confirmer(ap, cont)
      ..icon = Icon.settings
      ..title = intl.Settings()
      ..render(width: 250, height: 450);
    w.win.observer.addHook(app.Win.hookClose, (_) {
      previewLocal.dom.srcObject = null;
      previewLocal = null;
      return true;
    });
  }

  Future<void> setShareStream() async {
    closeStreamScreen();
    try {
      _localStreamScreen = await media.getScreen();
      _localStreamContr.add(_localStreamScreen);
      videoScreen.dom
        ..autoplay = true
        ..srcObject = _localStreamScreen;
    } catch (e) {}
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
    if (previewLocal != null) {
      previewLocal.dom
        ..autoplay = true
        ..muted = true
        ..srcObject = _localStreamVideo;
    }
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
    _localStreamVideo = null;
  }

  void close() {
    closeStreamScreen();
    closeStreamVideo();
  }

  Container getContainer() => new Container()
    ..addClass('local-video')
    ..append(videoLocal)
    ..append(settings);
}
