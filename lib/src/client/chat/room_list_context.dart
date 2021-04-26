part of chat;

class RoomListContext extends Container {
  app.Application ap;
  ChatController controller;
  bool focused = false;

  late Container roomTopCont;
  late Container roomInnerCont;

  late Container listRDom;

  late form.Input sInput;

  List<Room>? rooms;

  RoomListContext(this.ap, this.controller) : super() {
    createDom();
    controller.onNotifyMessage.listen((r) async {
      if (!focused) return;
      final changed = rooms?.firstWhereOrNull((room) => room.sameAs(r));
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

    action.Button? clear;
    sInput = new form.Input()
      ..setPlaceHolder(intl.Search_people())
      ..setPrefixElement(new CLElement(new Icon(Icon.search).dom))
      ..addAction((e) {
        loadUsers(sInput.field.dom.value!);
        if (sInput.field.dom.value!.isNotEmpty)
          clear?.show();
        else
          clear?.hide();
      }, 'keyup');
    roomTopCont
      ..append(sInput)
      ..append(clear = new action.Button()
        ..setIcon(Icon.clear)
        ..addClass('light')
        ..hide()
        ..addAction((e) {
          clear?.hide();
          sInput.setValue(null);
          load();
        }));
  }

  Future load() async {
    if (controller.loadRooms == null) return;
    rooms = await controller.loadRooms!();
    listRDom.removeChilds();
    rooms!.forEach(renderRoom);
  }

  Future loadUsers(String search) async {
    if (search.isEmpty) return load();
    if (controller.loadUsers == null) return;
    rooms =
        await controller.loadUsers!(new dto.ChatSearchDTO()..search = search);
    listRDom.removeChilds();
    rooms?.forEach(renderRoom);
  }

  void renderRoom(Room room) {
    room._controller = controller;
    listRDom.addRow(room.render());
  }
}
