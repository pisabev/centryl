part of chat;

class OfferRequest {
  int from;
  int to;
  bool isAnswer = false;
  RtcSessionDescription description;

  OfferRequest();

  factory OfferRequest.fromMap(Map data) => new OfferRequest()
    ..from = data['from']
    ..to = data['to']
    ..isAnswer = data['isAnswer']
    ..description = new RtcSessionDescription(data['description']);

  Map getDescription() => {'type': description.type, 'sdp': description.sdp};

  Map toMap() => {
        'from': from,
        'to': to,
        'isAnswer': isAnswer,
        'description': getDescription()
      };
}

class IceCandidate {
  int from;
  int to;
  RtcIceCandidate candidate;

  IceCandidate();

  factory IceCandidate.fromMap(Map data) => new IceCandidate()
    ..from = data['from']
    ..to = data['to']
    ..candidate = new RtcIceCandidate(data['candidate']);

  Map getCandidate() => {
        'candidate': candidate.candidate,
        'sdpMLineIndex': candidate.sdpMLineIndex,
        'sdpMid': candidate.sdpMid
      };

  Map toMap() => {'from': from, 'to': to, 'candidate': getCandidate()};
}
