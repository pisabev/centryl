part of chat;

class Member {
  int user_id;
  String? name;
  String? picture;
  bool status;

  Member({required this.user_id, this.name, this.picture, this.status = false});

  factory Member.fromDto(dto.Member d) => new Member(
      user_id: d.user_id,
      name: d.name,
      picture: d.picture,
      status: d.status ?? false);

  factory Member.fromMap(Map data) =>
      new Member.fromDto(new dto.Member.fromMap(data));

  bool get isMe => Chat.me_user_id == user_id;

  CLElement createDom({bool showStatus = true}) {
    final contU = new CLElement(new DivElement())..addClass('member');
    if (picture != null) {
      contU.setStyle({'background-image': 'url(${Chat.baseurl}$picture)'});
    } else
      contU.append(new Icon(Icon.person).dom);
    if (!isMe && showStatus) {
      final contStatus = new CLElement(new DivElement())
        ..addClass('status')
        ..addClass(status ? 'online' : 'offline');
      contU.append(contStatus);
    }
    return contU..dom.title = name;
  }

  void renderProfile(CLElement cont) => cont.append(createDom());

  void renderProfileSmall(CLElement cont) {
    final uniqueId = 'chat-member-$user_id';
    document.body?.querySelector('#$uniqueId')?.remove();
    cont.append(createDom(showStatus: false)..dom.id = uniqueId);
  }

  dto.Member toDto() => new dto.Member()
    ..user_id = user_id
    ..name = name
    ..picture = picture;

  Map toJson() => toDto().toJson();
}
