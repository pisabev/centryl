part of chat;

class RoomListContext extends Container {
  app.Application ap;
  ChatController controller;
  bool focused = false;

  Container roomTopCont;
  Container roomInnerCont;

  Container listRDom;

  form.Input sInput;

  List<Room> rooms;

  RoomListContext(this.ap, this.controller) : super() {
    createDom();
    controller.onNotifyMessage.listen((r) async {
      if (!focused) return;
      final changed =
          rooms.firstWhere((room) => room.sameAs(r), orElse: () => null);
      if (changed != null) changed.setUnseen(r.unseen);
    });
    controller.onNotifyRoom.listen((r) {
      if (!focused) return;
      load();
    });
  }

  void createDom() {
    addClass('ui-room-list-context');

    roomTopCont = new Container()..addClass('top');
    roomInnerCont = new Container()
      ..addClass('inner')
      ..auto = true;

    addRow(roomTopCont);
    addRow(roomInnerCont);

    listRDom = new Container()..addClass('room-list');
    roomInnerCont.append(listRDom, scrollable: true);

    sInput = new form.Input()
      ..setPrefixElement(new CLElement(new Icon(Icon.search).dom));
    roomTopCont
      ..append(sInput)
      ..append(new action.Button()
        ..addClass('warning')
        ..addAction(addRoom)
        ..setIcon(Icon.add));
  }

  Future load() async {
    if (controller.loadRooms == null) return;
    rooms = await controller.loadRooms();
    listRDom.removeChilds();
    rooms.forEach(renderRoom);
  }

  void addRoom([_]) {
    if (controller.addRoom != null) controller.addRoom();
  }

  void renderRoom(Room room) {
    room._controller = controller;
    listRDom.addRow(room.render());
    room.dom.addAction(room.openRoom);
  }
}
