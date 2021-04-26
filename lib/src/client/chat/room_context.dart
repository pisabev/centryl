part of chat;

class RoomContext extends Container {
  app.Application ap;
  ChatController controller;
  bool focused = false;
  LoadElement? _loader;

  late Container messageTopCont;
  late Container messageInnerCont;
  late Container messageBottomCont;
  late Container mBottomTop;
  late Container mBottomBottom;
  late Container mBottomEmoticons;
  late Container listMDom;
  late Container typeDom;

  late CLElement mTitle;
  late CLElement mProfile;
  late form.TextArea mInput;
  late action.Button back;
  late action.Button send;

  late num _initMHeight;
  Room? activeRoom;
  List<Message> messages = [];
  Timer? _timer;
  Message? lastMessage;
  List<Member> typers = [];
  final typeDelay = const Duration(seconds: 4);
  late Function _typing;

  RoomContext(this.ap, this.controller) : super() {
    _typing = utils.throttle(_sendType, typeDelay);
    createDom();
    controller
      ..onNotifyMessage.listen((r) async {
        if (!focused) return;
        if (activeRoom != null &&
            activeRoom!.sameAs(r) &&
            controller.loadRoomMessagesNew != null) {
          final messages = await controller.loadRoomMessagesNew!(activeRoom!);
          renderMessages(messages);
        }
      })
      ..onNotifyMessageUpdate.listen((m) async {
        if (!focused) return;
        if (activeRoom != null && activeRoom!.room_id == m.room_id) {
          final mes = messages.firstWhereOrNull((mes) => mes.id == m.id);
          if (mes != null) {
            if (m.content == null) {
              mes.dom.remove();
              messages.remove(mes);
            } else {
              mes
                ..content = m.content
                ..timestamp = m.timestamp
                .._renderMessageContent();
            }
          }
        }
      })
      ..onNotifyMessageSeen.listen((m) {
        if (!focused) return;
        if (activeRoom != null && activeRoom!.room_id == m.room_id) {
          final mes = messages.firstWhereOrNull((mes) => mes.id == m.id);
          if (mes != null)
            m.seen?.forEach((member) =>
                (!member.isMe && member.user_id != mes.member.user_id)
                    ? member.renderProfileSmall(mes.contBottom)
                    : null);
        }
      })
      ..onNotifyType.listen((r) {
        if (!focused) return;
        if (activeRoom != null && activeRoom!.sameAs(r)) {
          final exist = typers.firstWhereOrNull(
              (element) => element.user_id == r.members.first.user_id);
          if (exist != null) return;
          typers.add(r.members.first);
          initTyping();
          _timer?.cancel();
          _timer = new Timer(const Duration(seconds: 5), () {
            typers.remove(r.members.first);
            initTyping();
          });
        }
      });
  }

  void _sendType() {
    if (controller.messageType != null && activeRoom != null) {
      final me = activeRoom!.members.where((m) => m.isMe).toList();
      if (me.isNotEmpty) controller.messageType!(activeRoom!..members = me);
    }
  }

  void initTyping() {
    if (typers.isEmpty) {
      typeDom.hide();
      return;
    }
    final n = typers.map((e) => e.name).join(', ');
    if (typers.length > 1)
      typeDom.setText(intl.Typing_message_many(n));
    else
      typeDom.setText(intl.Typing_message_single(n));
    typeDom.show();
    _scrollMessageBottom();
  }

  void createDom() {
    addClass('ui-room-context');
    messageTopCont = new Container()..addClass('top');
    messageInnerCont = new Container()
      ..addClass('inner')
      ..auto = true;
    messageBottomCont = new Container()..addClass('bottom');
    mBottomEmoticons = new Container()..addClass('bottom-emoticon');
    mBottomTop = new Container()
      ..addClass('bottom-top')
      ..auto = true;
    mBottomBottom = new Container()..addClass('bottom-bottom');

    MessageDecoratorEmoticons._m.forEach((key, value) {
      mBottomEmoticons.append(new action.Button()
        ..addClass('light')
        ..setIcon('${Icon.spr}#$value')
        ..setTip(key, 'top')
        ..addAction((e) => mInput
          ..setValue('${mInput.getValue() ?? ''}$key')
          ..focus()));
    });

    messageBottomCont
      ..addRow(mBottomTop)
      ..addRow(mBottomEmoticons)
      ..addRow(mBottomBottom);

    addRow(messageTopCont);
    addRow(messageInnerCont);
    addRow(messageBottomCont);

    listMDom = new Container()..addClass('message-list');
    typeDom = new Container()
      ..addClass('type')
      ..hide();
    mProfile = new CLElement(new DivElement())..addClass('profile');
    mTitle = new CLElement(new DivElement())..addClass('title');
    back = new action.Button()
      ..setIcon(Icon.chevron_right)
      ..addAction((e) => closeRoom());
    messageTopCont..append(back)..append(mProfile)..append(mTitle);

    messageInnerCont.append(listMDom, scrollable: true);
    mInput = new form.TextArea()
      ..addValidationOnInput((e) {
        _typing();
        resizeForField();
        if (utils.KeyValidator.isKeyEnterCtrl(e))
          mInput.setValue('${mInput.getValue() ?? ''}\n');
        else if (utils.KeyValidator.isKeyEnter(e)) {
          e.preventDefault();
          sendMessage();
        }
        return true;
      })
      ..setPlaceHolder(intl.Type_message());
    final attach = new action.FileUploader(ap)..setIcon(Icon.insert_link);
    final emoticon = new action.Button()
      ..setIcon(Icon.emoticon)
      ..addAction((e) {
        mBottomEmoticons.toggleClass('show');
        resizeForEmoticons();
      });
    attach.observer
      ..addHook(action.FileUploader.hookLoading, _onFileLoadStart)
      ..addHook(action.FileUploader.hookLoaded, _onFileLoadEnd);
    send = new action.Button()
      ..addClass('important')
      ..setIcon(Icon.send)
      ..addAction(sendMessage);
    mBottomTop.append(mInput);

    mBottomBottom..append(attach)..append(emoticon);
    if (controller.callStart != null) {
      final call = new action.Button()
        ..setIcon(Icon.call)
        ..setTip(intl.Call())
        ..addAction((e) => controller._doCall!(activeRoom!))
        ..addClass('attention');
      mBottomBottom.append(call);
    }
    mBottomBottom.append(send);
  }

  void resizeForField() {
    final diff = mInput.field.dom.scrollHeight - mInput.field.dom.clientHeight;
    if (diff != 0) {
      final newHeight = messageBottomCont.getHeight() + diff;
      if (newHeight < 400) {
        messageBottomCont.setHeight(new Dimension.px(newHeight));
        _scrollMessageBottom(by: diff);
      } else {
        mInput.field.setStyle({'overflow': 'auto'});
      }
    }
  }

  void resizeForEmoticons() {
    const eHeight = 110;
    if (mBottomEmoticons.existClass('show')) {
      messageBottomCont
          .setHeight(new Dimension.px(messageBottomCont.getHeight() + eHeight));
      _scrollMessageBottom(by: eHeight);
    } else {
      messageBottomCont
          .setHeight(new Dimension.px(messageBottomCont.getHeight() - eHeight));
    }
  }

  void closeRoom() => controller.closeRoom!(activeRoom!);

  Future renderRoom(Room room) async {
    mProfile.removeChilds();
    room.members.forEach((m) {
      if (!m.isMe) m.renderProfile(mProfile);
    });
    mTitle.setText(room.getTitle());
    if (activeRoom == null || !activeRoom!.sameAs(room)) {
      if (controller.loadRoomMessages == null) return;
      activeRoom = room;
      lastMessage = null;
      messages = [];
      listMDom.removeChilds();
      renderMessages(await controller.loadRoomMessages!(room));
    }
  }

  void renderMessages(List<Message> messages) {
    if (messages.isEmpty) return;
    for (var i = messages.length - 1; i >= 0; i--) {
      final m = messages[i];
      var renderImage = true;
      if (lastMessage != null &&
          m.member.user_id == lastMessage!.member.user_id) renderImage = false;
      _renderMessage(m, renderImage: renderImage);
    }
    if (activeRoom!.lsm_id < messages.first.id! &&
        controller.markMessageAsSeen != null) {
      activeRoom!
        ..lsm_id = messages.first.id!
        ..setUnseen(0);
      controller.markMessageAsSeen!(messages.first);
    }
    listMDom.append(typeDom);
    _scrollMessageBottom();
  }

  void _renderMessage(Message message, {bool renderImage = true}) {
    if (messages.any((m) => m.id == message.id)) return;
    typers.removeWhere((m) => m.user_id == message.member.user_id);
    initTyping();
    message.controller = controller;
    messages.add(message);
    listMDom.addRow(message.render(renderImage: renderImage));
    lastMessage = message;
  }

  Message buildMessage(int type, String content) => new Message(
      id: null,
      room_id: activeRoom!.room_id!,
      type: type,
      context: activeRoom!.context,
      member: new Member(
          user_id: ap.client.userId,
          name: ap.client.name,
          picture: ap.client.picture),
      content: content,
      timestamp: new DateTime.now());

  void sendMessage([_]) {
    mInput.field.setStyle({'overflow': ''});
    messageBottomCont.dom.style.height = null;
    mBottomEmoticons.removeClass('show');
    resizeForEmoticons();
    final content = mInput.getValue()?.trim();
    if (content == null || content.isEmpty) return;
    mInput.setValue(null);
    messageBottomCont.setHeight(new Dimension.px(_initMHeight));
    if (controller.persistMessage != null)
      controller.persistMessage!(buildMessage(0, content));
  }

  bool _onFileLoadStart(String fileName) {
    _loader?.remove();
    _loader = new LoadElement(messageInnerCont);
    return true;
  }

  bool _onFileLoadEnd(String fileName) {
    _loader?.remove();
    if (controller.persistMessage != null)
      controller.persistMessage!(buildMessage(1, fileName));
    return true;
  }

  void _scrollMessageBottom({int? by}) {
    messageInnerCont.scroll!.containerEl.scrollTop = by != null
        ? messageInnerCont.scroll!.containerEl.scrollTop + by
        : messageInnerCont.scroll!.containerEl.scrollHeight;
  }
}
