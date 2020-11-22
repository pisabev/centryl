part of chat;

class Room {
  ChatController _controller;
  int room_id;
  String context;
  List<Member> members;
  int lsm_id;
  int unseen;
  String title;

  CLElement not;
  Container dom;

  Room(
      {this.room_id,
      this.context,
      this.title,
      this.members,
      this.lsm_id = 0,
      this.unseen = 0});

  bool sameAs(Room r) {
    if (room_id != null && r.room_id != null)
      return room_id == r.room_id;
    else if (context != null && r.context != null) return context == r.context;
    return false;
  }

  factory Room.fromMap(Map data) => new Room(
      room_id: data['room_id'],
      context: data['context'],
      members: (data['members'] as List)
          .map<Member>((m) => new Member.fromMap(m))
          .toList(),
      lsm_id: data['lsm_id'],
      unseen: data['unseen'] ?? 0,
      title: data['title']);

  void setUnseen(int num) {
    unseen = num;
    if (dom == null) return;
    not.setText('$unseen');
    if (unseen > 0)
      not.show();
    else
      not.hide(useVisibility: true);
  }

  String getTitle() =>
      title ?? members.where((u) => !u.isMe).map((u) => u.name).join(', ');

  Container render() {
    dom = new Container()..addClass('room-box');
    final contI = new CLElement(new DivElement())..addClass('profile');
    final contM = new CLElement(new DivElement())
      ..addClass('title')
      ..setText(getTitle());
    action.Button rem;
    if (room_id != null) {
      rem = new action.ButtonOption()
        ..buttonOption.addAction((e) => e.stopPropagation())
        ..addSub(new action.Button()
          ..setTitle(intl.Open())
          ..setIcon(Icon.message)
          ..addAction(openRoom));
      if (_controller.callStart != null) {
        final call = new action.Button()
          ..setIcon(Icon.call)
          ..setTitle(intl.Call())
          ..addAction((e) => _controller._doCall(this));
        rem.addSub(call);
      }
      rem
        ..addSub(new action.Button()
          ..setTitle(intl.Add_member())
          ..setIcon(Icon.add)
          ..addAction(addMember))
        ..addSub(new action.Button()
          ..setTitle(intl.Delete())
          ..setIcon(Icon.delete)
          ..addAction(deleteRoom));
      dom.addAction(openRoom);
    } else {
      rem = new action.Button()
        ..setTip(intl.Add_member())
        ..setIcon(Icon.add)
        ..addAction(createRoom);
    }
    members.forEach((m) {
      if (!m.isMe) m.renderProfile(contI);
    });
    dom..append(contI)..append(contM);
    not = new CLElement(new SpanElement())
      ..addClass('count')
      ..setText('$unseen');
    dom..append(not)..append(rem);
    if (unseen == 0) not.hide(useVisibility: true);
    return dom;
  }

  Future<void> createRoom([_]) async {
    if (_controller.createRoom != null) {
      final room = await _controller.createRoom(
          this..members.add(new Member()..user_id = Chat.me_user_id));
      if (room != null) _controller.showRoom(room);
    }
  }

  void openRoom([_]) {
    _controller.showRoom(this);
  }

  void addMember([_]) {
    if (_controller.addRoomMember != null) _controller.addRoomMember(this);
  }

  void deleteRoom([_]) {
    if (_controller.deleteRoom != null) _controller.deleteRoom(this);
  }

  Map toJson() => {
        'room_id': room_id,
        'context': context,
        'lsm_id': lsm_id,
        'members': members,
        'unseen': unseen,
        'title': title
      };
}
