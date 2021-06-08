part of chat;

class LocalView {
  app.Application ap;
  late Media media;
  late app.Win win;
  late CLElement<VideoElement> videoLocal;
  MediaStream? _localStream;
  late action.Button settings, share, mic, camera;
  late bool shareOn, micOn, cameraOn;

  final StreamController<MediaStream> _localStreamContr =
      new StreamController.broadcast();

  Stream<MediaStream> get onLocalStreamChange => _localStreamContr.stream;

  LocalView(this.ap,
      {this.shareOn = false, this.micOn = true, this.cameraOn = false}) {
    media = new Media(ap);
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
    try {
      micAction(init);
      cameraAction(init);
      _setStream(await media.getUserMedia(video: cameraOn, audio: micOn));
    } catch (e) {}
  }

  Future<void> settingsPopUp() async {
    final selectVideo = new form.Select();
    final selectAudio = new form.Select();
    final cameras = await media.getDevices(type: DeviceKind.videoinput);
    cameras.forEach((c) => selectVideo.addOption(c.deviceId, c.label, false));
    final audios = await media.getDevices(type: DeviceKind.audioinput);
    audios.forEach((c) => selectAudio.addOption(c.deviceId, c.label, false));
    if (media.videoId != null) selectVideo.setValue(media.videoId);
    if (media.audioId != null) selectAudio.setValue(media.audioId);
    final previewLocal = new CLElement<VideoElement>(new VideoElement());
    void setPreviewStream(MediaStream? str) {
      previewLocal.dom
        ..autoplay = true
        ..muted = true
        ..srcObject = str;
    }

    try {
      setPreviewStream(await media.getUserMedia());
    } catch (e) {}
    selectVideo.onValueChanged.listen((e) async {
      selectVideo.removeWarnings();
      media._videoId = e.getValue();
      try {
        setPreviewStream(await media.getUserMedia());
      } catch (e) {
        selectVideo.setWarning(new DataWarning('video', e.toString()));
      }
    });
    selectAudio.onValueChanged.listen((e) async {
      selectAudio.removeWarnings();
      media._audioId = e.getValue();
      try {
        setPreviewStream(await media.getUserMedia());
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
    w.win?.observer.addHook(app.Win.hookClose, (_) {
      previewLocal.dom.srcObject
          ?.getTracks()
          .forEach(allowInterop((dynamic t) => t.stop()));
      previewLocal.dom.srcObject = null;
      return true;
    });
  }

  Future<void> shareAction([bool init = false]) async {
    if (!init && shareOn) {
      await initAudioVideo(true);
    } else {
      _setStream(await getStreamShare());
    }
    if (!init) shareOn = !shareOn;
    shareOn ? share.addClass('attention') : share.removeClass('attention');
  }

  void micAction([bool init = false]) {
    if (!init) micOn = !micOn;
    _localStream?.getAudioTracks().forEach((t) => t.enabled = micOn);
    mic.setIcon(micOn ? Icon.mic : Icon.mic_off);
  }

  void cameraAction([bool init = false]) {
    if (!init) {
      cameraOn = !cameraOn;
      media.getUserMedia(video: cameraOn, audio: true).then((stream) {
        if (!micOn)
          _localStream?.getAudioTracks().forEach((t) => t.enabled = micOn);
        _setStream(stream);
      }).catchError((e) {});
    }
    camera.setIcon(cameraOn ? Icon.videocam : Icon.videocam_off);
  }

  Future<MediaStream> getStreamShare() async {
    final stream = await media.getScreen();
    final audioTracks = await getAudioTracks();
    audioTracks?.forEach(stream.addTrack);
    return stream;
  }

  Future<List<MediaStreamTrack>?> getVideoTracks() async {
    final stream = await media.getUserMedia(video: true, audio: false);
    return stream?.getVideoTracks().cast<MediaStreamTrack>();
  }

  Future<List<MediaStreamTrack>?> getAudioTracks() async {
    final stream = await media.getUserMedia(audio: true, video: false);
    return stream?.getAudioTracks().cast<MediaStreamTrack>();
  }

  void _setStream(MediaStream? stream) {
    if (stream == null) return;
    closeStream();
    _localStream = stream;
    _localStreamContr.add(_localStream!);
    videoLocal.dom
      ..autoplay = true
      ..muted = true
      ..srcObject = _localStream;
  }

  void closeStream() {
    _localStream?.getTracks().forEach(allowInterop((dynamic t) => t.stop()));
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
