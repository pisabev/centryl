part of chat;

@JS('window.navigator.mediaDevices.getDisplayMedia')
external Future<List> _getDisplayMedia();

enum DeviceKind { audioinput, videoinput, audiooutput }

class Media {
  Future<List<MediaDeviceInfo>> getDevices({DeviceKind type}) async {
    final r = (await window.navigator.mediaDevices.enumerateDevices())
        .cast<MediaDeviceInfo>();
    if (type == null) return r;
    switch (type) {
      case DeviceKind.audioinput:
        return r.where((r) => r.kind == 'audioinput').toList();
      case DeviceKind.videoinput:
        return r.where((r) => r.kind == 'videoinput').toList();
      case DeviceKind.audiooutput:
        return r.where((r) => r.kind == 'audiooutput').toList();
    }
    return null;
  }

  Future<MediaStream> getScreen() => promiseToFuture(_getDisplayMedia());

  Future<MediaStream> getUserMedia(String deviceId, [String audioId]) =>
      window.navigator.getUserMedia(video: {
        if (deviceId != null) 'deviceId': {'exact': deviceId},
        'width': {'ideal': '1920', 'min': '640'},
        'height': {'ideal': '1080', 'min': '400'},
        'aspectRatio': {'ideal': '1.7777777778'},
        'frameRate': {'ideal': '60', 'min': '10'}
      }, audio: audioId != null ? {'deviceId': audioId} : true);
}
