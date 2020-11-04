library test.cl.chat;

import 'dart:async';

import 'package:centryl/app.dart' as app;
import 'package:centryl/chat.dart' as chat;
import 'package:centryl/develop.dart';

chat.ChatController controller;
app.Application ap;

void main() {
  ap = initApp(new app.Client({
    'client': {'name': 'Peter', 'user_id': 1}
  }));

  controller = new chat.ChatController()
    ..loadRooms = (() => new Future.value(rooms))
    ..loadRoomMessages = ((room) => new Future.value(mess[room]))
    ..loadRoomMessagesNew = loadMessagesNew
    ..persistMessage = persistMessage
    ..callStart = ((room) {

    });

  final o = new chat.Chat(
      ap,
      ap.fieldRight,
      new chat.RoomListContext(ap, controller),
      new chat.RoomContext(ap, controller),
      controller);
  ap.addons.append(o.chatDom());
}

Future<bool> persistMessage(chat.Message message) async {
  final room = findRoomByMessage(message);
  mess[room].insert(0, message..id = getMessageId());
  controller.notifierMessage.add(room);
  return true;
}

Future<List<chat.Message>> loadMessagesNew(chat.Room room) async =>
    mess[room].where((m) => m.id > room.lsm_id).toList();

final List<chat.Room> rooms = [
  _generateRoom(),
  _generateRoom(),
  _generateRoom(),
  _generateRoom()
];

final Map<chat.Room, List<chat.Message>> mess = {};

chat.Room _generateRoom() {
  final room = new chat.Room(
      room_id: roomId.generate(),
      members: [_generateMemberMe(), _generateMember()]);
  mess[room] = [];
  final n = new RandomInteger(10).generate();
  for (int i = 0; i < n; i++) mess[room].add(_generateMessage(room));
  return room;
}

chat.Room findRoomByMessage(chat.Message message) =>
    rooms.firstWhere((r) => r.room_id == message.room_id, orElse: () => null);

chat.Member _generateMember() =>
    new chat.Member(user_id: userId.generate(), name: memberName.generate());

chat.Member _generateMemberMe() =>
    new chat.Member(user_id: ap.client.userId, name: ap.client.name);

chat.Message _generateMessage(chat.Room room) => new chat.Message(
    id: getMessageId(),
    room_id: room.room_id,
    member: room.members[new RandomInteger(2).generate()],
    content: messageText.generate(),
    timestamp: new DateTime.now());

final roomId = new RandomUniqueInteger(8);
final roomTitle = new RandomUniqueWord([
  'Room 1',
  'Room 2',
  'Room 3',
  'Room 4',
  'Room 5',
  'Room 6',
  'Room 7',
  'Room 8',
  'Room 9'
]);
final memberName = new RandomUniqueWord([
  'John',
  'Ali',
  'Mary',
  'Lily',
  'Alex',
  'Emma',
  'Anastasia',
  'Monica',
  'Michael'
]);
final messageText = new RandomText('Lorem Ipsum is simply dummy text of the '
    'printing and typesetting industry. Lorem Ipsum has been the industry\'s '
    'standard dummy text ever since the 1500s, when an unknown printer took a '
    'galley of type and scrambled it to make a type specimen book. It has '
    'survived not only five centuries, but also the leap into electronic '
    'typesetting, remaining essentially unchanged. It was popularised in '
    'the 1960s with the release of Letraset sheets containing Lorem Ipsum '
    'passages, and more recently with desktop publishing software like Aldus '
    'PageMaker including versions of Lorem Ipsum.');

int messageId = 0;

int getMessageId() => ++messageId;
final userId = new RandomUniqueInteger(8, exclude: {1});
