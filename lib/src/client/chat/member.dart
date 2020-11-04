part of chat;

class Member {
  int user_id;
  String name;
  String picture;
  bool status;

  Member({this.user_id, this.name, this.picture, this.status = false});

  factory Member.fromMap(Map data) => new Member(
      user_id: data['user_id'],
      name: data['name'],
      picture: data['picture'],
      status: data['status'] ?? false);

  bool get isMe => Chat.me_user_id == user_id;

  CLElement createDom({bool status = true}) {
    final contU = new CLElement(new DivElement())..addClass('member');
    if (picture != null) {
      contU.setStyle({'background-image': 'url(${Chat.baseurl}$picture)'});
    } else
      contU.append(new Icon(Icon.person).dom);
    if (!isMe && status) {
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
    document.body.querySelector('#$uniqueId')?.remove();
    cont.append(createDom(status: false)..dom.id = uniqueId);
  }

  Map toJson() => {'user_id': user_id, 'name': name, 'picture': picture};
}
