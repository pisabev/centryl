// GENERATED CODE - DO NOT MODIFY BY HAND

part of dto;

// **************************************************************************
// DTOSerializableGenerator
// **************************************************************************

abstract class $DataContainer {
  static const String label = 'label', clas = 'clas', set = 'set';
}

DataContainer _$DataContainerFromMap(Map data) => new DataContainer()
  ..label = data[$DataContainer.label]
  ..clas = data[$DataContainer.clas]
  ..set = (data[$DataContainer.set] as List)
      ?.map((v0) => v0 == null ? null : new DataSet.fromMap(v0))
      ?.toList();

Map<String, dynamic> _$DataContainerToMap(DataContainer obj) =>
    <String, dynamic>{
      $DataContainer.label: obj.label,
      $DataContainer.clas: obj.clas,
      $DataContainer.set: obj.set == null
          ? null
          : new List.generate(obj.set.length, (i0) => obj.set[i0]?.toMap())
    };

abstract class $DataSet {
  static const String key = 'key', value = 'value';
}

DataSet _$DataSetFromMap(Map data) =>
    new DataSet(data[$DataSet.key], data[$DataSet.value]);

Map<String, dynamic> _$DataSetToMap(DataSet obj) =>
    <String, dynamic>{$DataSet.key: obj.key, $DataSet.value: obj.value};

abstract class $ChatSearchDTO {
  static const String search = 'search';
}

ChatSearchDTO _$ChatSearchDTOFromMap(Map data) =>
    new ChatSearchDTO()..search = data[$ChatSearchDTO.search];

Map<String, dynamic> _$ChatSearchDTOToMap(ChatSearchDTO obj) =>
    <String, dynamic>{$ChatSearchDTO.search: obj.search};

abstract class $Message {
  static const String typeMessage = 'typeMessage',
      typeFile = 'typeFile',
      id = 'id',
      type = 'type',
      member = 'member',
      seen = 'seen',
      room_id = 'room_id',
      context = 'context',
      content = 'content',
      timestamp = 'timestamp';
}

Message _$MessageFromMap(Map data) => new Message()
  ..id = data[$Message.id]
  ..type = data[$Message.type]
  ..member = data[$Message.member] == null
      ? null
      : new Member.fromMap(data[$Message.member])
  ..seen = (data[$Message.seen] as List)
      ?.map((v0) => v0 == null ? null : new Member.fromMap(v0))
      ?.toList()
  ..room_id = data[$Message.room_id]
  ..context = data[$Message.context]
  ..content = data[$Message.content]
  ..timestamp = data[$Message.timestamp] is String
      ? DateTime.tryParse(data[$Message.timestamp])
      : data[$Message.timestamp];

Map<String, dynamic> _$MessageToMap(Message obj) => <String, dynamic>{
      $Message.id: obj.id,
      $Message.type: obj.type,
      $Message.member: obj.member?.toMap(),
      $Message.seen: obj.seen == null
          ? null
          : new List.generate(obj.seen.length, (i0) => obj.seen[i0]?.toMap()),
      $Message.room_id: obj.room_id,
      $Message.context: obj.context,
      $Message.content: obj.content,
      $Message.timestamp: obj.timestamp?.toIso8601String()
    };

abstract class $Member {
  static const String user_id = 'user_id',
      name = 'name',
      picture = 'picture',
      status = 'status';
}

Member _$MemberFromMap(Map data) => new Member()
  ..user_id = data[$Member.user_id]
  ..name = data[$Member.name]
  ..picture = data[$Member.picture]
  ..status = data[$Member.status];

Map<String, dynamic> _$MemberToMap(Member obj) => <String, dynamic>{
      $Member.user_id: obj.user_id,
      $Member.name: obj.name,
      $Member.picture: obj.picture,
      $Member.status: obj.status
    };

abstract class $Room {
  static const String room_id = 'room_id',
      context = 'context',
      members = 'members',
      lsm_id = 'lsm_id',
      unseen = 'unseen',
      messages = 'messages';
}

Room _$RoomFromMap(Map data) => new Room()
  ..room_id = data[$Room.room_id]
  ..context = data[$Room.context]
  ..members = (data[$Room.members] as List)
      ?.map((v0) => v0 == null ? null : new Member.fromMap(v0))
      ?.toList()
  ..lsm_id = data[$Room.lsm_id]
  ..unseen = data[$Room.unseen]
  ..messages = data[$Room.messages];

Map<String, dynamic> _$RoomToMap(Room obj) => <String, dynamic>{
      $Room.room_id: obj.room_id,
      $Room.context: obj.context,
      $Room.members: obj.members == null
          ? null
          : new List.generate(
              obj.members.length, (i0) => obj.members[i0]?.toMap()),
      $Room.lsm_id: obj.lsm_id,
      $Room.unseen: obj.unseen,
      $Room.messages: obj.messages
    };

abstract class $OfferRequest {
  static const String from = 'from',
      to = 'to',
      isAnswer = 'isAnswer',
      description = 'description';
}

OfferRequest _$OfferRequestFromMap(Map data) => new OfferRequest()
  ..from = data[$OfferRequest.from]
  ..to = data[$OfferRequest.to]
  ..isAnswer = data[$OfferRequest.isAnswer]
  ..description = data[$OfferRequest.description];

Map<String, dynamic> _$OfferRequestToMap(OfferRequest obj) => <String, dynamic>{
      $OfferRequest.from: obj.from,
      $OfferRequest.to: obj.to,
      $OfferRequest.isAnswer: obj.isAnswer,
      $OfferRequest.description: obj.description
    };

abstract class $IceCandidate {
  static const String from = 'from', to = 'to', candidate = 'candidate';
}

IceCandidate _$IceCandidateFromMap(Map data) => new IceCandidate()
  ..from = data[$IceCandidate.from]
  ..to = data[$IceCandidate.to]
  ..candidate = data[$IceCandidate.candidate];

Map<String, dynamic> _$IceCandidateToMap(IceCandidate obj) => <String, dynamic>{
      $IceCandidate.from: obj.from,
      $IceCandidate.to: obj.to,
      $IceCandidate.candidate: obj.candidate
    };
