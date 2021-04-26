part of dto;

@DTOSerializable()
class ChatSearchDTO {
  late String search;

  ChatSearchDTO();

  factory ChatSearchDTO.fromMap(Map data) => _$ChatSearchDTOFromMap(data);

  Map toMap() => _$ChatSearchDTOToMap(this);

  Map toJson() => toMap();
}

@DTOSerializable()
class Message {
  static int typeMessage = 0;
  static int typeFile = 1;

  int? id;
  late int type;
  late Member member;
  late int room_id;
  String? context;
  late DateTime timestamp;
  List<Member>? seen;
  String? content;

  Message();

  factory Message.fromMap(Map data) => _$MessageFromMap(data);

  Map toMap() => _$MessageToMap(this);

  Map toJson() => toMap();
}

@DTOSerializable()
class Member {
  late int user_id;
  String? name;
  String? picture;
  bool? status;

  Member();

  factory Member.fromMap(Map data) => _$MemberFromMap(data);

  Map toMap() => _$MemberToMap(this);

  Map toJson() => toMap();
}

@DTOSerializable()
class Room {
  int? room_id;
  late List<Member> members;
  String? context;
  int? lsm_id;
  int? unseen;
  int? messages;

  Room();

  factory Room.fromMap(Map data) => _$RoomFromMap(data);

  Map toMap() => _$RoomToMap(this);

  Map toJson() => toMap();
}

@DTOSerializable()
class OfferRequest {
  int from;
  int to;
  bool isAnswer = false;
  Map description;

  OfferRequest();

  factory OfferRequest.fromMap(Map data) => _$OfferRequestFromMap(data);

  Map toMap() => _$OfferRequestToMap(this);

  Map toJson() => toMap();
}

@DTOSerializable()
class IceCandidate {
  int from;
  int to;
  Map candidate;

  IceCandidate();

  factory IceCandidate.fromMap(Map data) => _$IceCandidateFromMap(data);

  Map toMap() => _$IceCandidateToMap(this);

  Map toJson() => toMap();
}
