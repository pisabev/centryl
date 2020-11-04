part of action;

class ButtonGroup extends Button {
  Button current;
  CLElement domList;

  ButtonGroup() : super();

  void createDom() {
    setClass('ui-button-group');
    domList = new CLElement(new UListElement())
      ..addClass('ui-button-ul')
      ..appendTo(this);
  }

  CLElement addSub(Button button) {
    sub.add(button);
    final num = sub.length - 1;
    button.addAction((e) => setCurrent(num), 'click');
    return new CLElement(new LIElement())
      ..append(button)
      ..appendTo(domList);
  }

  void setCurrent([int num]) {
    sub.forEach((b) => b.removeClass('current'));
    if (num != null) {
      sub[num].addClass('current');
      current = sub[num];
    }
  }
}
