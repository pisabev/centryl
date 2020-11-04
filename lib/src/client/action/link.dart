part of action;

class Link extends CLElement {
  CLElement domAction;

  Link() : super(new SpanElement()) {
    domAction = new CLElement(new AnchorElement())..appendTo(this);
  }

  void setIcon(String icon, [String pos]) {
    //domAction.setClass(icon + ' icon');
    //if (pos) domAction.setStyle({'backgroundPosition': pos});
  }

  void setTitle(String title) {
    domAction.dom.text = title;
    domAction.setStyle({'paddingRight': '3px'});
  }
}
