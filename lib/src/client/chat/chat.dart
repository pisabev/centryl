part of chat;

class Chat {
  app.Application ap;
  CLElement container;
  ChatController controller;
  Container dom;

  RoomListContext roomListContext;
  RoomContext roomContext;
  PeerManager peerManager;

  int unread = 0;

  SpanElement count;

  static int me_user_id;
  static String baseurl;

  bool _focused = false;

  Chat(this.ap, this.container, this.roomListContext, this.roomContext,
      this.controller) {
    dom = new Container()
      ..addClass('ui-chat')
      ..append(roomListContext)
      ..append(roomContext);
    peerManager = new PeerManager(ap, controller, ap.client.userId);

    me_user_id = ap.client.userId;
    baseurl = ap.baseurl;

    controller
      .._doCall = peerManager.doCall
      ..showRoom = renderRoom
      ..closeChat = (() => ap.asideHide())
      ..closeRoom = (room) {
        renderList();
        if (room.context != null) renderChat();
      };

    controller.onNotifyMessage.listen((event) => init());
    controller.onNotifyMessageSeen.listen((m) => init());

    new MessageDecoratorManager()
      ..registerDecorator(Message.typeMessage, new MessageDecoratorLink())
      ..registerDecorator(Message.typeMessage, new MessageDecoratorEmoticons())
      ..registerDecorator(Message.typeFile, new MessageDecoratorFileImage())
      ..registerDecorator(Message.typeFile, new MessageDecoratorFileVideo())
      ..registerDecorator(Message.typeFile, new MessageDecoratorFilePdf())
      ..registerDecorator(Message.typeFile, new MessageDecoratorFileDoc())
      ..registerDecorator(Message.typeFile, new MessageDecoratorFileXls())
      ..registerDecorator(Message.typeFile, new MessageDecoratorFileGeneric());
  }

  set focused(bool f) {
    _focused = f;
    if (!_focused) {
      roomListContext.focused = false;
      roomContext.focused = false;
    }
  }

  bool get focused => _focused;

  action.Button chatDom() => new action.Button()
    ..setIcon(Icon.mode_comment)
    ..addAction((e) {
      renderChat();
      if (roomContext.activeRoom != null &&
          roomContext.activeRoom.context == null)
        renderRoom(roomContext.activeRoom);
      else
        renderList();
    })
    ..append(count = new SpanElement()..classes.add('note'))
    ..setTip(intl.Messages(), 'bottom');

  Future<void> init() async {
    if (controller.loadUnread != null) unread = await controller.loadUnread();
    showUnread();
  }

  void renderChat() {
    container.removeChilds();

    focused = ap.toggleAside(this);
    if (!focused) return;

    container.append(dom);
  }

  void showUnread() {
    if (unread > 0) {
      count
        ..style.display = 'block'
        ..text = '${unread > 99 ? '99+' : unread}';
    } else {
      count.style.display = 'none';
    }
  }

  void renderRoom(Room room) {
    dom.addClass('show-context');
    roomContext
      ..renderRoom(room)
      ..focused = true;
    roomListContext.focused = false;
  }

  void renderList() {
    dom.removeClass('show-context');
    roomListContext.load();
    roomContext
      ..activeRoom = null
      ..focused = false;
    roomListContext.focused = true;
  }

  bool isListVisible() => focused && roomListContext.focused;

  bool isRoomVisible(int roomId) {
    if (!focused || !roomContext.focused) return false;
    return roomContext.activeRoom.room_id == roomId;
  }
}
