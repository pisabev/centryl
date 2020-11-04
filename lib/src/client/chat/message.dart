part of chat;

class Message {
  static int typeMessage = 0;
  static int typeFile = 1;
  ChatController controller;

  int id;
  int type;
  Member member;
  List<Member> seen;
  int room_id;
  String context;
  String content;
  DateTime timestamp;

  CLElement dom;
  CLElement messageDom;
  CLElement timestampDom;
  CLElement contBottom;

  Message(
      {this.id,
      this.type,
      this.member,
      this.seen,
      this.room_id,
      this.context,
      this.content,
      this.timestamp});

  factory Message.fromMap(Map data) => new Message(
      id: data['id'],
      type: data['type'],
      member: new Member.fromMap(data['member']),
      seen: (data['seen'] as List)
          ?.map<Member>((m) => new Member.fromMap(m))
          ?.toList(),
      room_id: data['room_id'],
      context: data['context'],
      content: data['content'],
      timestamp: DateTime.parse(data['timestamp']));

  Container render({bool renderImage = true}) {
    dom = new Container()..addClass('message-box');
    final contTop = new CLElement(new DivElement())..addClass('message-top');
    if (member.isMe) contTop.addClass('reverse');
    contBottom = new CLElement(new DivElement())
      ..addClass('message-bottom profile');
    final contP = new CLElement(new DivElement())..addClass('profile');
    final contM = new CLElement(new DivElement())..addClass('message');
    messageDom = new CLElement(new DivElement())..addClass('inner');
    contM.append(messageDom);
    final contB = new CLElement(new DivElement())..addClass('action');
    timestampDom = new CLElement(new DivElement())..addClass('time');
    _renderMessageContent();
    contB..append(timestampDom)..append(contP);
    if (member.isMe && controller.messageUpdate != null) {
      if (type == typeMessage) {
        final edit = action.Button()
          ..setIcon(Icon.edit)
          ..addClass('light')
          ..addAction((e) {
            messageDom.dom
              ..text = content
              ..contentEditable = 'true'
              ..focus();
            messageDom.addAction((e) {
              messageDom.dom.contentEditable = 'false';
              if (content == messageDom.dom.text) {
                _renderMessageContent();
                return;
              }
              content =
                  messageDom.dom.text.isEmpty ? null : messageDom.dom.text;
              controller.messageUpdate(this);
            }, 'blur');
          });
        contB.append(edit);
      } else {
        final delete = action.Button()
          ..setIcon(Icon.delete)
          ..addClass('light')
          ..addAction((e) {
            content = null;
            controller.messageUpdate(this);
          });
        contB.append(delete);
      }
    }
    contM.append(contB);
    if (renderImage) member.renderProfile(contP);
    seen?.forEach((m) => (!m.isMe && m.user_id != member.user_id)
        ? m.renderProfileSmall(contBottom)
        : null);
    dom..append(contTop..append(contP)..append(contM))..append(contBottom);
    return dom;
  }

  void _renderMessageContent() {
    final decorated = new MessageDecoratorManager().decorate(type, content);
    if (decorated is String) {
      final v = NodeValidatorBuilder()
        ..allowNavigation(new form.MyUriPolicy())
        ..allowImages(new form.MyUriPolicy())
        ..allowHtml5(uriPolicy: new form.MyUriPolicy())
        ..allowInlineStyles()
        ..allowSvg();
      messageDom.dom.setInnerHtml(decorated, validator: v);
    } else {
      messageDom
        ..removeChilds()
        ..append(decorated);
    }
    timestampDom.setText(utils.Calendar.stringWithTime(timestamp.toLocal()));
  }

  Map toJson() => {
        'id': id,
        'type': type,
        'member': member.toJson(),
        'seen': seen,
        'room_id': room_id,
        'context': context,
        'content': content,
        'timestamp': timestamp.toIso8601String()
      };
}
