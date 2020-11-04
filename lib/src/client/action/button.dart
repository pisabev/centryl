part of action;

class Button extends CLElement {
  CLElement<SpanElement> inner;
  List<Button> sub = [];
  List<DataWarning> _warnings = [];
  app.Bubble _bubble;
  Icon _icon;
  Element warningIcon;
  String _tip;
  String _tipPos;
  String _name;
  Timer _timerWrn;

  Button() : super(new SpanElement()) {
    createDom();
  }

  void createDom() {
    setClass('ui-button');
    inner = new CLElement(new SpanElement())
      ..setClass('inner')
      ..appendTo(this);
    setAttribute('tabindex', '0');
    addAction(_onFocus, 'focus');
    addAction(_onBlur, 'blur');
    setState(true);
  }

  void setName(String name) {
    _name = name;
  }

  String getName() => _name;

  CLElement addSub(Button button) {
    sub.add(button);
    final ul = new CLElement(new UListElement())..appendTo(this);
    return new CLElement(new LIElement())
      ..appendTo(ul)
      ..append(button);
  }

  void setIcon(String icon) {
    if (_icon != null) _icon.dom.remove();
    if (icon != null) {
      _icon = new Icon(icon);
      dom.insertBefore(_icon.dom, inner.dom);
    }
  }

  void setWarning(DataWarning wrn, {bool show = true}) {
    if (wrn == null) return;
    if (!_warnings.any((w) => w.key == wrn.key)) _warnings.add(wrn);
    warningIcon?.remove();
    warningIcon = new Icon(Icon.warning).dom..classes.add('warning');
    final warningsHtml = _warnings.map((w) => w.message).join('</br>');
    _bubble = new app.Bubble(new CLElement(warningIcon))..setHtml(warningsHtml);
    _bubble.cont
      ..addAction((e) => _bubble.showBubble(), 'mouseover')
      ..addAction((e) => _bubble.hideBubble(), 'mouseout');
    append(warningIcon);

    if (show) {
      _timerWrn?.cancel();
      _timerWrn = new Timer(const Duration(seconds: 1), () {
        showWarnings(const Duration(seconds: 5));
        _timerWrn = null;
      });
    }
  }

  void showWarnings([Duration duration]) {
    if (!hasWarnings()) return;
    if (duration != null) new Timer(duration, _bubble.hideBubble);
    _bubble.showBubble();
  }

  void removeWarning(String wrnKey) {
    if (wrnKey == null) return;
    _warnings.removeWhere((wrn) => wrn.key == wrnKey);
    if (!hasWarnings()) {
      _bubble = null;
      warningIcon?.remove();
    }
  }

  void removeWarnings() {
    _warnings = [];
    _bubble = null;
    warningIcon?.remove();
  }

  bool hasWarnings() => _warnings.isNotEmpty;

  void setTip(String text, [String pos = 'bottom']) {
    if (_tip == null) _initTip();
    _tip = text;
    _tipPos = pos;
  }

  void _initTip() {
    CLElement tip;
    Timer timer;
    void _remove(e) {
      if (state) {
        timer.cancel();
        tip.remove();
      }
    }

    addAction((e) {
      if (state) {
        var offset_top = false;
        var offset_left = false;
        switch (_tipPos) {
          case 'top':
            offset_top = false;
            break;
          case 'bottom':
            offset_top = true;
            break;
          case 'left':
            offset_left = false;
            break;
          case 'right':
            offset_left = true;
            break;
        }
        final rect = getRectangle();
        final top = rect.top + (offset_top ? rect.height : 0);
        final left = rect.left + (offset_left ? rect.width : 0);
        var reversed = '';
        if (left > document.body.getBoundingClientRect().width / 2)
          reversed = ' reversed';
        tip = new CLElement(new DivElement())
          ..addClass('ui-data-tip $_tipPos-tip$reversed')
          ..setAttribute('data-tips', _tip)
          ..setStyle({'top': '${top}px', 'left': '${left}px'})
          ..appendTo(document.body);
        timer = new Timer(
            const Duration(milliseconds: 100), () => tip.addClass('show'));
      }
    }, 'mouseover.tip');
    addAction(_remove, 'mouseout.tip');
    addAction(_remove, 'mousedown.tip');
  }

  void setTitle(String title) {
    if (title != null) {
      inner.dom.text = title;
      inner.addClass('button-title');
    } else
      inner.removeClass('button-title');
  }

  String getTitle() => inner.dom.text;

  void disable() {
    state = false;
    addClass('disabled');
    setAttribute('tabindex', '-1');
  }

  void enable() {
    state = true;
    removeClass('disabled');
    setAttribute('tabindex', '0');
  }

  void _onFocus(e) {
    addAction((e) {
      if (utils.KeyValidator.isKeyEnter(e)) dom.click();
    }, 'keydown.select');
  }

  void _onBlur(e) {
    removeAction('keydown.select');
  }

  void focus() {
    dom.focus();
  }

  void blur() {
    dom.blur();
  }

  void setState(bool state) {
    if (state)
      enable();
    else
      disable();
  }
}
