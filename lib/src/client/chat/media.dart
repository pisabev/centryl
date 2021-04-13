part of chat;

@JS('window.navigator.mediaDevices.getDisplayMedia')
external Future<List> _getDisplayMedia();

enum DeviceKind { audioinput, videoinput, audiooutput }

class Media {
  app.Application ap;
  String? _videoId;
  String? _audioId;

  Future<List<MediaDeviceInfo>> getDevices({DeviceKind? type}) async {
    final r = (await window.navigator.mediaDevices!.enumerateDevices())
        .cast<MediaDeviceInfo>();
    if (type == null) return r;
    switch (type) {
      case DeviceKind.audioinput:
        return r
            .where((r) => r.kind == 'audioinput' && r.deviceId!.isNotEmpty)
            .toList();
      case DeviceKind.videoinput:
        return r
            .where((r) => r.kind == 'videoinput' && r.deviceId!.isNotEmpty)
            .toList();
      case DeviceKind.audiooutput:
        return r
            .where((r) => r.kind == 'audiooutput' && r.deviceId!.isNotEmpty)
            .toList();
    }
  }

  String? get videoId => _videoId;

  String? get audioId => _audioId;

  set videoId(String? id) {
    _videoId = id;
    final map = ap.storageFetch('chat') ?? <String, dynamic>{};
    map['video_id'] = id;
    ap.storagePut('chat', map);
  }

  set audioId(String? id) {
    _audioId = id;
    final map = ap.storageFetch('chat') ?? <String, dynamic>{};
    map['audio_id'] = id;
    ap.storagePut('chat', map);
  }

  Media(this.ap) {
    final map = ap.storageFetch('chat') ?? <String, dynamic>{};
    _videoId = map['video_id'];
    _audioId = map['audio_id'];
  }

  Future<MediaStream> getScreen() => promiseToFuture(_getDisplayMedia());

  Future<MediaStream?> getUserMedia(
      {bool video = true, bool audio = true}) async {
    dynamic _videoConstraints() => {
          if (videoId != null && videoId!.isNotEmpty)
            'deviceId': {'exact': videoId},
          'width': {'ideal': '1920', 'min': '640'},
          'height': {'ideal': '1080', 'min': '400'},
          'aspectRatio': {'ideal': '1.7777777778'},
          'frameRate': {'ideal': '60', 'min': '10'}
        };

    dynamic _audioConstraints() =>
        (audioId != null && audioId!.isNotEmpty) ? {'deviceId': audioId} : true;
    if (audio && video)
      return window.navigator
          .getUserMedia(video: _videoConstraints(), audio: _audioConstraints());
    else if (video)
      return window.navigator.getUserMedia(video: _videoConstraints());
    else if (audio)
      return window.navigator.getUserMedia(audio: _audioConstraints());
    return null;
  }
}
