part of chat;

class ChatController {
  StreamController<Room> notifierMessage = new StreamController.broadcast();
  StreamController<Room> notifierRoom = new StreamController.broadcast();
  StreamController<Message> notifierMessageUpdate =
      new StreamController.broadcast();
  StreamController<Message> notifierMessageSeen =
      new StreamController.broadcast();
  StreamController<Room> notifierType = new StreamController.broadcast();

  StreamController<OfferRequest> notifierOffer =
      new StreamController.broadcast();
  StreamController<IceCandidate> notifierIce = new StreamController.broadcast();
  StreamController<Room> notifierCallStart = new StreamController.broadcast();
  StreamController<Room> notifierCallAnswer = new StreamController.broadcast();
  StreamController<Room> notifierCallHangup = new StreamController.broadcast();

  Stream<Room> get onNotifyMessage => notifierMessage.stream;

  Stream<Room> get onNotifyRoom => notifierRoom.stream;

  Stream<Message> get onNotifyMessageUpdate => notifierMessageUpdate.stream;

  Stream<Message> get onNotifyMessageSeen => notifierMessageSeen.stream;

  Stream<Room> get onNotifyType => notifierType.stream;

  Stream<OfferRequest> get onNotifyOffer => notifierOffer.stream;

  Stream<IceCandidate> get onNotifyIce => notifierIce.stream;

  Stream<Room> get onCallStart => notifierCallStart.stream;

  Stream<Room> get onCallAnswer => notifierCallAnswer.stream;

  Stream<Room> get onCallHangup => notifierCallHangup.stream;

  FutureOr<List<Message>> Function(Room) loadRoomMessages;
  FutureOr<List<Message>> Function(Room) loadRoomMessagesNew;
  FutureOr<int> Function() loadUnread;
  FutureOr<List<Room>> Function() loadRooms;
  FutureOr<bool> Function(Message) persistMessage;
  FutureOr<bool> Function(Message) markMessageAsSeen;
  FutureOr<bool> Function(Message) messageUpdate;
  FutureOr<bool> Function(Room) messageType;
  FutureOr<Room> Function(Room) createRoom;
  FutureOr<bool> Function(Room) addRoomMember;
  FutureOr<bool> Function(Room) deleteRoom;

  FutureOr Function() addRoom;
  FutureOr Function(Room) showRoom;
  FutureOr Function(Room) closeRoom;

  FutureOr Function(OfferRequest) sendOffer;
  FutureOr Function(IceCandidate) sendIce;
  FutureOr Function(Room) callStart;
  FutureOr Function(Room) callAnswer;
  FutureOr Function(Room) callHangup;
  FutureOr Function(Room) _doCall;
}
