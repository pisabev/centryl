part of chat;

class PeerManager {
  app.Application ap;
  final ChatController controller;
  int userId;
  List<PeerConnection> connections = [];
  CallView? callView;
  CallStartView? callStartView;
  StreamSubscription? _sub;

  PeerManager(this.ap, this.controller, this.userId) {
    controller.onNotifyOffer.listen((offer) {
      if (callView == null && callStartView == null) return;
      final conn = getConnection(offer.from);
      if (offer.isAnswer)
        conn.handleOfferAnswer(offer);
      else {
        conn.handleOffer(offer);
        if (callStartView != null) initCallView(callStartView!.room);
      }
    });
    controller.onNotifyIce.listen((ice) {
      if (callView == null) return;
      getConnection(ice.from).handleNewICECandidateMsg(ice);
    });
    controller.onCallAnswer.listen((room) {
      if (callStartView == null) return;
      initCallView(room);
    });
    controller.onCallStart.listen((room) {
      initCallStartView(room,
          caller: false,
          onAnswer: () => controller.callAnswer!(room)).answer.enable();
    });
    controller.onCallHangup.listen((room) {
      if (callStartView != null) closeCallStartView();
      if (callView != null) closeCallView();
    });
  }

  void removeConnection(int targetUserId) {
    final exist = connections.firstWhereOrNull(
        (c) => c.userId == userId && c.targetUserId == targetUserId);
    if (exist == null) return;
    exist._conn.close();
    connections.remove(exist);
  }

  PeerConnection getConnection(int targetUserId) {
    final exist = connections.firstWhereOrNull(
        (c) => c.userId == userId && c.targetUserId == targetUserId);
    if (exist != null) return exist;
    final con = new PeerConnection(controller, userId, targetUserId);
    con.onRemoteStream.listen((stream) {
      callView!.videoRemote.dom
        ..autoplay = true
        ..srcObject = stream;
      callView!.analyzer();
    });
    connections.add(con);
    return con;
  }

  CallStartView initCallStartView(Room room,
          {bool caller = true, void Function()? onAnswer}) =>
      callStartView = new CallStartView(ap, room, onHangup: () {
        closeCallStartView();
        controller.callHangup!(room);
      }, onAnswer: onAnswer, caller: caller);

  void initCallView(Room room) {
    closeCallStartView();
    if (callView != null) return;
    _sub?.cancel();
    getConnection(room.members.firstWhere((r) => !r.isMe).user_id);
    callView = new CallView(ap, room, onHangup: () {
      closeCallView();
      controller.callHangup!(room);
    });
    _sub = callView!.localView.onLocalStreamChange
        .listen((s) => connections.forEach((c) => c.setLocalStream(s)));
  }

  void closeCallStartView() {
    if (callStartView == null) return;
    callStartView!.close();
    callStartView = null;
  }

  void closeCallView() {
    if (callView == null) return;
    _sub?.cancel();
    removeConnection(
        callView!.room.members.firstWhere((r) => !r.isMe).user_id);
    callView!.close();
    callView = null;
  }

  Future<void> doCall(Room room) async {
    controller.closeChat!();
    initCallStartView(room);
    controller.callStart!(room);
  }
}
