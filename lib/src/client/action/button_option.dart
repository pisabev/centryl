part of action;

class ButtonOption extends Button {
  Button buttonDefault;
  Button buttonOption;
  CLElement domList;
  utils.UISlider slider;
  CLElement _scrollContainer;
  utils.CLscroll _scroll;
  String customClass;

  ButtonOption({this.customClass}) : super();

  void createDom() {
    inner = new CLElement(new SpanElement()..classes.add('inner'));
    append(inner);
    setClass('ui-button-option');
    if (customClass != null)
      addClass(customClass);
    buttonOption = new Button()
      ..appendTo(inner)
      ..setIcon(Icon.more_vert)
      ..addClass('ui-option')
      ..addAction((e) {
        e.stopPropagation();
        _showL();
        CLElement doc;
        doc = new CLElement(document.body)
          ..addAction((e) {
            _hideL();
            doc.removeAction('mousedown.select');
          }, 'mousedown.select');
      })
      ..addAction(_onBlur, 'blur');
    domList = new CLElement(new UListElement())..appendTo(this);
    _scrollContainer = new CLElement(new DivElement())
      ..hide()
      ..addClass(dom.classes.join(' '))
      ..append(domList)
      ..appendTo(this);
    _scroll = new utils.CLscroll(_scrollContainer.dom);
    slider = new utils.UISlider(_scrollContainer, this);
    setState(true);
  }

  void setName(String name) => _name = name;

  String getName() => _name;

  void setDefault(Button button) {
    buttonDefault = button..addClass('ui-main');
    inner.insertBefore(buttonDefault, buttonOption);
  }

  CLElement addSub(Button button) {
    sub.add(button);
    button
      ..addAction((e) => e.stopPropagation(), 'mousedown')
      ..addAction((e) => _hideL(), 'click');
    return new CLElement(new LIElement())
      ..append(button)
      ..setAttribute('title', button.getTitle())
      ..appendTo(domList);
  }

  void _showL() {
    slider.show();
    _scroll.flashScrollbar();
  }

  void _hideL() => slider.hide();

  void setIcon(String icon) {}

  void setTitle(String title) {}

  void disable() => setState(false);

  void enable() => setState(true);

  void setState(bool state) {
    _hideL();
    buttonDefault?.setState(state);
    buttonOption.setState(state);
    sub.forEach((b) => b.setState(state));
  }

  void addAction<E extends Event>(EventFunction<E> func,
      [String event_space = 'click']) {}
}
