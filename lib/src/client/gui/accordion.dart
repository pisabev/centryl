part of gui;

abstract class AccordionNode extends CLElement {
  CLElement titleDom;
  CLElement contentDom;

  final StreamController<AccordionNode> _contrOpen =
      new StreamController.broadcast();

  AccordionNode() : super(new DivElement());

  Stream<AccordionNode> get onOpen => _contrOpen.stream;

  void toggle([_]);

  void open();

  void close();
}

class _AccordionNode extends AccordionNode {
  final Accordion _ref;

  _AccordionNode(this._ref, dynamic title) : super() {
    addClass('ui-accordion-node');
    createDom();
    if (title is String)
      titleDom.setText(title);
    else if (title is CLElementBase) titleDom.append(title);
    append(titleDom);
    append(contentDom);
  }

  void createDom() {
    titleDom = new CLElement(new SpanElement())
      ..addKeyAction(keyNavigate)
      ..addAction(toggle);
    contentDom = new CLElement(new DivElement());
  }

  void keyNavigate(Event e) {
    if (KeyValidator.isKeyUp(e)) {
      getPrevElement().titleDom.dom.focus();
    } else if (KeyValidator.isKeyDown(e)) {
      getNextElement().titleDom.dom.focus();
    } else if (KeyValidator.isKeyLeft(e) ||
        KeyValidator.isKeyRight(e) ||
        KeyValidator.isKeyEnter(e)) {
      toggle();
    }
  }

  AccordionNode getPrevElement() {
    final ind = _ref.nodes.indexOf(this);
    final prevInd = ind == 0 ? _ref.nodes.length - 1 : ind - 1;
    return _ref.nodes[prevInd];
  }

  AccordionNode getNextElement() {
    final ind = _ref.nodes.indexOf(this);
    final nextInd = ind == _ref.nodes.length - 1 ? 0 : ind + 1;
    return _ref.nodes[nextInd];
  }

  void toggle([_]) {
    if (_ref.autoclose)
      _ref.nodes.forEach((el) {
        if (!_ref.closeback || el != this) el.close();
      });
    toggleClass('active');
    _contrOpen.add(this);
  }

  void open() {
    addClass('active');
    _contrOpen.add(this);
  }

  void close() {
    removeClass('active');
  }
}

class Accordion extends CLElement {
  bool autoclose = true;
  bool closeback = true;

  List<AccordionNode> nodes = [];

  Accordion() : super(new DivElement()) {
    addClass('ui-accordion');
  }

  AccordionNode createNode(dynamic title) {
    final view = new _AccordionNode(this, title)..appendTo(this);
    nodes.add(view);
    return view;
  }

  void openNode(AccordionNode node) => node.open();

  void toggleNode(AccordionNode node) => node.toggle();

  void closeNode(AccordionNode node) => node.close();

  void openAll() => nodes.forEach((node) => node.open());

  void closeAll() => nodes.forEach((node) => node.close());

  void openNodeByNum(int num) {
    if (nodes.length > num) nodes[num].toggle();
  }
}
