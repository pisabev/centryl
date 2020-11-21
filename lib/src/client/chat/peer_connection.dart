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

  void _createConnection() {
    _conn = new RtcPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.stunprotocol.org'}
      ]
    })
      ..onAddStream.listen((e) => _contrRemoteStream.add(e.stream))
      ..onIceCandidate.listen((e) {
        if (e.candidate is RtcIceCandidate) {
          final dto = new IceCandidate()
            ..from = userId
            ..to = targetUserId
            ..candidate = e.candidate;
          controller.sendIce(dto);
        }
      })
      ..onNegotiationNeeded.listen((e) async {
        try {
          final RtcSessionDescription offer = await _conn.createOffer();
          final dto = new OfferRequest()
            ..from = userId
            ..to = targetUserId
            ..description = offer;
          await _conn.setLocalDescription(dto.getDescription());
          controller.sendOffer(dto);
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

  Future<void> handleOffer(OfferRequest offer) async {
    try {
      await _conn.setRemoteDescription(offer.getDescription());
      final RtcSessionDescription answer = await _conn.createAnswer();
      final dto = new OfferRequest()
        ..from = userId
        ..to = targetUserId
        ..isAnswer = true
        ..description = answer;
      await _conn.setLocalDescription(dto.getDescription());
      controller.sendOffer(dto);
    } catch (e) {
      throw Exception('Unable to PeerConnection:handleOffer: ${e.message}');
    }
  }

  Future<void> handleOfferAnswer(OfferRequest offer) async {
    try {
      await _conn.setRemoteDescription(offer.getDescription());
    } catch (e) {
      throw Exception(
          'Unable to PeerConnection:handleOfferAnswer: ${e.message}');
    }
  }

  Future<void> handleNewICECandidateMsg(IceCandidate ice) async {
    try {
      await _conn.addIceCandidate(new RtcIceCandidate(ice.getCandidate()),
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
