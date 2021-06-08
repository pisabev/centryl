part of gui;

class LabelState extends action.Button {
  late final List<String> states;
  final List<String>? colors;
  late int _current;
  List<int>? _clickables;
  List<StreamSubscription> _subs = [];
  final StreamController<int> _contr = new StreamController.broadcast();

  LabelState(this.states, [this.colors]) : super();

  Stream<int> get onChange => _contr.stream;

  int get current => _current;

  void createDom() {
    addClass('ui-state');
    for (var i = states.length - 1; i >= 0; i--) {
      final cont = new DivElement();
      final span = new SpanElement()..text = states[i];
      cont.append(span);
      append(cont);
    }
  }

  void setActive(int index, [String? clas]) {
    clas ??= (colors != null) ? colors![index] : 'state1';
    dom.children.forEach((e) => e.classes.remove('current'));
    dom.children.elementAt((dom.children.length - 1) - index)
      ..classes.add('current')
      ..classes.add(clas);
    if (_current != index) {
      _current = index;
      _contr.add(_current);
    }
  }

  void setClickable(List<int> clickables) {
    _clickables = clickables;
    addClass('action-click');
    dom.children.forEach((e) => e.classes.remove('clickable'));
    _subs.forEach((s) => s.cancel());
    _subs = [];
    _clickables!.forEach((indx) {
      final el = dom.children.elementAt((dom.children.length - 1) - indx)
        ..classes.add('clickable');
      _subs.add(el.onClick.listen((e) => setActive(indx)));
    });
  }

  void disable() {
    removeClass('action-click');
    dom.children.forEach((e) => e.classes.remove('clickable'));
    _subs.forEach((s) => s.cancel());
  }

  void enable() {
    if (_clickables != null) setClickable(_clickables!);
  }
}
