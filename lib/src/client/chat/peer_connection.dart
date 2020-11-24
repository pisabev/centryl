part of chat;

class PeerConnection {
  int userId;
  int targetUserId;
  final ChatController controller;
  final StreamController<MediaStream> _contrRemoteStream =
      new StreamController.broadcast();
  RtcPeerConnection _conn;

  PeerConnection(this.controller, this.userId, this.targetUserId) {
    _createConnection();
  }

  Stream<MediaStream> get onRemoteStream => _contrRemoteStream.stream;

  Map _rtcIceCandidateToMap(RtcIceCandidate candidate) => {
        'candidate': candidate.candidate,
        'sdpMLineIndex': candidate.sdpMLineIndex,
        'sdpMid': candidate.sdpMid
      };

  Map _rtcSessionDescriptionToMap(RtcSessionDescription description) =>
      {'type': description.type, 'sdp': description.sdp};

  void _createConnection() {
    _conn = new RtcPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.stunprotocol.org'}
      ]
    })
      ..onTrack.listen((e) => _contrRemoteStream.add(e.streams[0]))
      ..onIceCandidate.listen((e) {
        if (e.candidate is RtcIceCandidate) {
          final o = new dto.IceCandidate()
            ..from = userId
            ..to = targetUserId
            ..candidate = _rtcIceCandidateToMap(e.candidate);
          controller.sendIce(o);
        }
      })
      ..onNegotiationNeeded.listen((e) async {
        try {
          final RtcSessionDescription offer = await _conn.createOffer();
          final o = new dto.OfferRequest()
            ..from = userId
            ..to = targetUserId
            ..description = _rtcSessionDescriptionToMap(offer);
          await _conn.setLocalDescription(o.description);
          controller.sendOffer(o);
        } catch (e) {
          throw Exception('Unable to PeerConnection:'
              'RtcPeerConnection.onNegotiationNeeded: ${e.message}');
        }
      })
      ..onSignalingStateChange.listen((e) {
        //print(_conn.signalingState);
      })
      ..onIceConnectionStateChange.listen((e) {
        switch (_conn.iceConnectionState) {
          case 'failed':
          case 'disconnected':
            reset();
            break;
        }
      });
  }

  void setLocalStream(MediaStream stream) =>
      stream.getTracks().forEach((dynamic t) => _conn.addTrack(t, stream));

  Future<void> handleOffer(dto.OfferRequest offer) async {
    try {
      await _conn.setRemoteDescription(offer.description);
      final RtcSessionDescription answer = await _conn.createAnswer();
      final o = new dto.OfferRequest()
        ..from = userId
        ..to = targetUserId
        ..isAnswer = true
        ..description = _rtcSessionDescriptionToMap(answer);
      await _conn.setLocalDescription(o.description);
      controller.sendOffer(o);
    } catch (e) {
      throw Exception('Unable to PeerConnection:handleOffer: ${e.message}');
    }
  }

  Future<void> handleOfferAnswer(dto.OfferRequest offer) async {
    try {
      await _conn.setRemoteDescription(offer.description);
    } catch (e) {
      throw Exception(
          'Unable to PeerConnection:handleOfferAnswer: ${e.message}');
    }
  }

  Future<void> handleNewICECandidateMsg(dto.IceCandidate ice) async {
    try {
      await _conn.addIceCandidate(new RtcIceCandidate(ice.candidate),
          allowInterop(() {}), allowInterop((_) {}));
    } catch (e) {
      throw Exception(
          'Unable to PeerConnection:handleNewICECandidateMsg: ${e.message}');
    }
  }

  void reset() {
    _conn.close();
    _createConnection();
  }
}
