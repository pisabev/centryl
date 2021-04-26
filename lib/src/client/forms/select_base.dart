part of forms;

abstract class _SelectBase<T> extends DataElement<T, html.Element>
    with DataLoader<List> {
  late html.SpanElement inner;
  late CLElement domValue;
  late CLElement domList;
  List list = [];
  late utils.CLscroll _scroll;
  late utils.UISlider _slider;
  late CLElement _scrollContainer;
  int currentIndex = 0;
  bool isListVisible = false;
  bool _defaultValue = true;
  late action.Warning warning;

  //StreamSubscription _valueSub;
  //dynamic _value_cached;

  _SelectBase() : super() {
    dom = new html.SpanElement();
    inner = new html.SpanElement()..classes.add('inner');
    append(inner);
    domValue = new CLElement(new html.SpanElement())
      ..setClass('ui-select')
      ..appendTo(inner);
    inner.append(
        new Icon(Icon.keyboard_arrow_down).dom..classes.add('drop-down'));
    domList = new CLElement(new html.UListElement())..addClass('ui-list');
    _scrollContainer = new CLElement(new html.DivElement())
      ..hide()
      ..append(domList)
      ..appendTo(this);
    _scroll = new utils.CLscroll(_scrollContainer.dom);
    _slider = new utils.UISlider(_scrollContainer, this);
    setClass('ui-field-select');
    setAttribute('tabindex', '0');
    addAction(_onFocus, 'focus');
    addAction(_onBlur, 'blur');
    addAction<html.Event>((e){
      e.stopPropagation();
      if (list.isNotEmpty && state) showList();
      late CLElement doc;
      doc = new CLElement(html.document.body)
        ..addAction((e) {
          hideList();
          doc.removeAction('mousedown.select');
        }, 'mousedown.select');
    });
    initDataLoader(this);
    _onLoadEndInner.listen((_) {
      final v = getValue();
      setOptions(data ?? [], false);
      if (list.isNotEmpty) {
        if (v != null && _testAgainstList(v))
          _setValue(v);
        else if (_defaultValue)
          _setValue(list.first[0]);
      } else {
        _setValue(null);
      }
      loadEnd();
    });
    onReadyChanged.listen((e) {
      if (e.isReady())
        removeClass('error');
      else
        addClass('error');
    });

    warning = new action.Warning(new CLElement(inner));
  }

  bool _testAgainstList(T v);

  void _setValue(T? value) {
    // Loading data
    super.setValue(value);
    if (list.isEmpty && execute is Function) {
      if (!isLoading) load();
      return;
    }

    if (list.isNotEmpty) _manageValue(value);
  }

  void _manageValue(dynamic value);

  /// Responds to key arrows and sets the currentIndex
  void _moveIndex(int p) {
    if (list.isEmpty || !state || isLoading) return;
    final cur_indx = currentIndex;
    list[cur_indx][1].removeClass('current');
    var next_indx = cur_indx + p;
    if (next_indx > list.length - 1) next_indx = 0;
    if (next_indx < 0) next_indx = list.length - 1;
    list[next_indx][1].addClass('current');
    currentIndex = next_indx;
    if (isListVisible) {
      _moveView();
    } else {
      setShadowValue();
    }
  }

  void navAction(html.KeyboardEvent e) {
    if (utils.KeyValidator.isKeyDown(e)) {
      e.preventDefault();
      _moveIndex(1);
    } else if (utils.KeyValidator.isKeyUp(e)) {
      e.preventDefault();
      _moveIndex(-1);
    } else if (utils.KeyValidator.isKeyEnter(e)) {
      _setValue(list[currentIndex][0]);
      hideList();
    }
  }

  void load() {
    list = [];
    super.load();
  }

  /// Scrolling the list window
  void _moveView() {
    _scroll.flashScrollbar();
    final view_height = _scrollContainer.getHeight();
    final cell_height =
        new CLElement(domList.dom.children.first).getHeightComputed();
    final current_top = cell_height * currentIndex;
    if (_scroll.containerEl.scrollTop > current_top)
      _scroll.containerEl.scrollTop = current_top.toInt();
    if (_scroll.containerEl.scrollTop + view_height <= current_top)
      _scroll.containerEl.scrollTop =
          (current_top - view_height + cell_height).toInt();
  }

  CLElement addOption(dynamic value, dynamic title, [bool initValue = true]) {
    final li = new CLElement(new html.LIElement())
      ..addAction<html.Event>((e) {
        e
          ..stopPropagation()
          ..preventDefault();
        hideList();
        _setValue(value);
      }, 'mousedown')
      ..setAttribute('title', '$title')
      ..setHtml('$title');
    domList.append(li);
    list.add([value, li, title]);
    if (initValue && getValue() == null && list.length == 1) _setValue(value);
    return li;
  }

  CLElement getOptionElement(dynamic value) {
    final r = list.firstWhere((r) => r[0] == value, orElse: () => null);
    return (r != null) ? r[1] : null;
  }

  void removeOption(dynamic value) {
    final r = list.firstWhere((r) => r[0] == value, orElse: () => null);
    if (r != null) {
      list.remove(r);
      r[1].remove();
      if (getValue() == value) _setValue(null);
    }
  }

  void setOptions(List list, [bool initValue = true]) {
    cleanOptions();
    list.forEach((v) => addOption(v['k'], v['v'], initValue));
  }

  void cleanOptions() {
    list = [];
    currentIndex = 0;
    domList.removeChilds();
    setShadowValue();
  }

  int getOptionsCount() => list.length;

  ///TODO
  void addOptionGroup(String group) {}

  String getText() => (list.isNotEmpty) ? '${list[currentIndex][2]}' : '';

  Future<String> getRepresentation() {
    final completer = new Completer<String>();
    if (isLoading)
      onLoadEnd.first.then((_) => completer.complete(getText()));
    else
      completer.complete(getText());
    return completer.future;
  }

  void setShadowValue() => domValue.setText(getText());

  void showList([CLElementBase? relativeTo]) {
    isListVisible = true;
    _slider.el.dom.classes
      ..removeWhere((c) => c.startsWith('size-'))
      ..add('size-${list.length}');
    _slider.show(relativeTo);
    _scroll.flashScrollbar();
  }

  void _onFocus(e) => addAction(navAction, 'keydown.select');

  void _onBlur(e) {
    if (list.isNotEmpty && getValue() != list[currentIndex][0])
      _setValue(list[currentIndex][0]);
    removeAction('keydown.select');
    //hideList();
  }

  void focus() {
    dom.focus();
  }

  void blur() {
    dom.blur();
  }

  void hideList() {
    isListVisible = false;
    _slider.hide();
  }

  void setWarning(DataWarning? wrn, {bool show = true}) {
    if (wrn == null) return;
    super.setWarning(wrn);
    warning.init(getWarnings(), showAuto: show);
  }

  void showWarnings([Duration? duration]) {
    warning.show(duration);
  }

  void removeWarning(String? wrnKey) {
    if (wrnKey == null) return;
    super.removeWarning(wrnKey);
    warning.remove();
  }

  void removeWarnings() {
    super.removeWarnings();
    warning.remove();
  }

  void disable() {
    state = false;
    setAttribute('tabindex', '-1');
    addClass('disabled');
  }

  void enable() {
    state = true;
    setAttribute('tabindex', '0');
    removeClass('disabled');
  }
}
