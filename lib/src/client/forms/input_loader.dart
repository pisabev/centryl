part of forms;

class InputLoader<T> extends InputFunction<T> with DataLoader<List<Map>> {
  late CLElement domList;
  List list = [];
  final String fieldKey = 'k';
  final String fieldValue = 'v';
  final String fieldList = 'v';
  Timer? _timerLoading;
  late utils.CLscroll _scroll;
  late utils.UISlider _slider;
  late CLElement scrollContainer;
  int currentIndex = -1;
  late String _lastVisibleValue;
  bool isListVisible = false;
  bool _userAction = false;
  bool _tryValueLater = false;

  InputLoader() : super() {
    domList = new CLElement(new html.UListElement())..addClass('ui-list');
    scrollContainer = new CLElement(new html.DivElement())
      ..hide()
      ..append(domList)
      ..appendTo(this);
    _scroll = new utils.CLscroll(scrollContainer.dom);
    _slider = new utils.UISlider(scrollContainer, this);
    field..addAction(_navAction, 'keyup')..addAction(_leave, 'blur');
    initDataLoader(this);
    _onLoadEndInner.listen((_) {
      _setOptions(data);
      if (_userAction) _showList();
      _userAction = false;
      final v = getValue();
      if (v != null &&
          list is List &&
          list.length == 1 &&
          v == list.first.first) {
        final text = list.first[1];
        setValueDynamic(text);
        _lastVisibleValue = text;
      }
      if (_tryValueLater) {
        _tryValueLater = false;
        _tryValue();
      }
      loadEnd();
    });
  }

  void _moveIndex(int p) {
    if (list.isEmpty || !state) return;
    final cur_indx = currentIndex;
    if (cur_indx >= 0) list[cur_indx][2].removeClass('current');
    int next_indx = cur_indx + p;
    if (next_indx > list.length - 1) next_indx = 0;
    if (next_indx < 0) next_indx = list.length - 1;
    list[next_indx][2].addClass('current');
    currentIndex = next_indx;
    if (isListVisible) {
      _moveView();
    }
  }

  void _navAction(html.Event e) {
    if (!state) return;
    if (utils.KeyValidator.isKeyDown(e as html.KeyboardEvent))
      _moveIndex(1);
    else if (utils.KeyValidator.isKeyUp(e))
      _moveIndex(-1);
    else if (utils.KeyValidator.isKeyEnter(e)) {
      _tryValue();
    } else
      _proceedLoad();
  }

  void _tryValue() {
    final sug = getSuggestion();
    if (sug.isEmpty)
      setValue([null, null]);
    else if (list.length == 1)
      setValue(list[0]);
    else if (list.length > 1 &&
        list[currentIndex > -1 ? currentIndex : 0][2].existClass('current'))
      setValue(list[currentIndex > -1 ? currentIndex : 0]);
    else
      setValue([null, null]);
  }

  void _moveView() {
    _scroll.flashScrollbar();
    final view_height = scrollContainer.getHeight();
    final cell_height =
        new CLElement(domList.dom.children.first).getHeightComputed();
    final current_top = cell_height * currentIndex;
    if (_scroll.containerEl.scrollTop > current_top)
      _scroll.containerEl.scrollTop = current_top.toInt();
    if (_scroll.containerEl.scrollTop + view_height <= current_top)
      _scroll.containerEl.scrollTop =
          (current_top - view_height + cell_height).toInt();
  }

  void addOption(Map row) {
    final li = new CLElement(new html.LIElement());
    final value = row[fieldKey];
    final title = row[fieldValue];
    final listv = row[fieldList];
    list.add([value, title, li, row]);
    li
      ..addAction<html.Event>((e) {
        e.preventDefault();
        setValue([value, title]);
        new Timer(const Duration(milliseconds: 0), focus);
      }, 'mousedown')
      ..setAttribute('title', listv)
      ..setHtml(listv);
    domList.append(li);
  }

  void _setOptions(List<Map>? arr) {
    list = [];
    currentIndex = -1;
    domList.removeChilds();
    if (arr == null) return;
    arr.forEach(addOption);
    if (!_userAction && arr.isEmpty) setValue([null, null]);
  }

  String getSuggestion() => field.dom.value!;

  Future<String> getRepresentation() {
    final completer = new Completer<String>();
    if (isLoading)
      onLoadEnd.first.then((_) => completer.complete(getSuggestion()));
    else
      completer.complete(getSuggestion());
    return completer.future;
  }

  void setValue(dynamic value) {
    var v = value;
    dynamic t;
    if (value is List) {
      v = value[0];
      t = value[1];
    }

    if (list.isNotEmpty) {
      var ind = -1;
      if (v != null) {
        for (var i = 0; i < list.length; i++) {
          if (list[i][0] == v) {
            ind = i;
            break;
          }
        }
      }
      currentIndex = ind;
    }

    _lastVisibleValue = t;
    super.setValue([v, t]);
    if (isListVisible) _hideList();

    void _loadVisiblePart() {
      if (value != List && v != null && t == null) {
        loadStart();
        _executing = execute!().asStream().listen((d) {
          if (d != null && d.length == 1) {
            final v = d.first;
            _lastVisibleValue = v[fieldValue];
            setValueDynamic(_lastVisibleValue);
          } else {
            setValue(null);
          }
          loadEnd();
        });
      } else if (value != List && v == null && t == null && isLoading) {
        loadEnd();
      }
    }

    if (isLoading) {
      _cancel()?.then((_) => _loadVisiblePart());
    } else {
      _loadVisiblePart();
    }
  }

  void _showList() {
    isListVisible = true;
    _slider.el.dom.classes
      ..removeWhere((c) => c.startsWith('size-'))
      ..add('size-${list.length}');
    _slider.show();
    _scroll.flashScrollbar();
  }

  void _hideList() {
    isListVisible = false;
    _slider.hide();
  }

  void _leave(e) {
    _hideList();
    _userAction = false;
    if (_timerLoading != null && _timerLoading!.isActive)
      _tryValueLater = true;
    else if (getSuggestion() != _lastVisibleValue) _tryValue();
  }

  void _proceedLoad() {
    _hideList();
    _userAction = false;
    _timerLoading?.cancel();
    if (getSuggestion().isNotEmpty)
      _timerLoading = new Timer(const Duration(milliseconds: 300), () {
        _userAction = true;
        load();
      });
  }
}
