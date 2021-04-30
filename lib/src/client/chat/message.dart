part of chat;

class Message {
  static int typeMessage = 0;
  static int typeFile = 1;
  late ChatController controller;

  int? id;
  int type;
  Member member;
  List<Member> seen;
  int? room_id;
  String? context;
  String? content;
  DateTime timestamp;

  late CLElement dom;
  late CLElement messageDom;
  late CLElement timestampDom;
  late CLElement contBottom;

  Message(
      {required this.type,
      required this.member,
      required this.room_id,
      required this.timestamp,
      this.context,
      this.id,
      this.content,
      List<Member>? seen})
      : this.seen = seen ?? [];

  factory Message.fromDto(dto.Message d) => new Message(
      id: d.id,
      type: d.type!,
      member: new Member.fromDto(d.member!),
      seen: d.seen.map<Member>((m) => new Member.fromDto(m)).toList(),
      room_id: d.room_id,
      context: d.context,
      content: d.content,
      timestamp: d.timestamp!);

  factory Message.fromMap(Map data) =>
      new Message.fromDto(new dto.Message.fromMap(data));

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
                  messageDom.dom.text!.isEmpty ? null : messageDom.dom.text!;
              controller.messageUpdate!(this);
            }, 'blur');
          });
        contB.append(edit);
      } else {
        final delete = action.Button()
          ..setIcon(Icon.delete)
          ..addClass('light')
          ..addAction((e) {
            content = null;
            controller.messageUpdate!(this);
          });
        contB.append(delete);
      }
    }
    contM.append(contB);
    if (renderImage) member.renderProfile(contP);
    seen.forEach((m) => (!m.isMe && m.user_id != member.user_id)
        ? m.renderProfileSmall(contBottom)
        : null);
    dom..append(contTop..append(contP)..append(contM))..append(contBottom);
    return dom as Container;
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

  dto.Message toDto() => new dto.Message()
    ..id = id
    ..type = type
    ..member = member.toDto()
    ..seen = seen.map((e) => e.toDto()).toList()
    ..room_id = room_id
    ..context = context
    ..content = content
    ..timestamp = timestamp;

  Map toJson() => toDto().toJson();
}
