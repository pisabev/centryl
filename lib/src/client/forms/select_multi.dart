part of forms;

class SelectMulti<T> extends _SelectBase<List<T>> {
  SelectMulti() : super() {
    _defaultValue = false;
  }

  bool _testAgainstList(List<T> v) =>
      v.every((val) => list.any((r) => r[0] == val));

  /// Responds to key arrows and sets the currentIndex
  void _moveIndex(int p) {
    if (list.isEmpty || !state || isLoading) return;
    if (!isListVisible) return;
    final cur_indx = currentIndex;
    list[cur_indx][1].removeClass('hover');
    int next_indx = cur_indx + p;
    if (next_indx > list.length - 1) next_indx = 0;
    if (next_indx < 0) next_indx = list.length - 1;
    list[next_indx][1].addClass('hover');
    currentIndex = next_indx;
    _moveView();
  }

  void navAction(html.KeyboardEvent e) {
    if (utils.KeyValidator.isKeyDown(e)) {
      e.preventDefault();
      _moveIndex(1);
    } else if (utils.KeyValidator.isKeyUp(e)) {
      e.preventDefault();
      _moveIndex(-1);
    } else if (utils.KeyValidator.isKeyEnter(e) ||
        utils.KeyValidator.isKeySpace(e)) {
      e.preventDefault();
      _addRemoveValue(list[currentIndex][0]);
    } else if (utils.KeyValidator.isESC(e)) {
      hideList();
    }
  }

  CLElement addOption(dynamic value, dynamic title, [bool initValue = true]) {
    final li = new CLElement(new html.LIElement())
      ..addAction<html.Event>((e) {
        e
          ..stopPropagation()
          ..preventDefault();
        _addRemoveValue(value);
      }, 'mousedown')
      ..addAction<html.Event>((e) {
        e
          ..stopPropagation()
          ..preventDefault();
      }, 'click')
      ..setAttribute('title', '$title')
      ..setHtml('$title');
    domList.append(li);
    list.add([value, li, title]);
    return li;
  }

  int getOptionsCount() => list.length;

  ///TODO
  void addOptionGroup(String group) {}

  void setValue(List<T>? value) => _setValue(value);

  void _manageValue(dynamic value) {
    var newIndex = 0;
    if (value != null) {
      for (var i = 0; i < list.length; i++) {
        if (value.contains(list[i][0])) {
          newIndex = i;
          break;
        }
      }
    }
    list.forEach((l) {
      if (value != null && value.contains(l[0]))
        l[1].addClass('current');
      else
        l[1].removeClass('current');
    });
    currentIndex = newIndex;
    setShadowValue();
  }

  void _addRemoveValue(dynamic value) {
    final current = new List.from(getValue() ?? []) as List<T>;
    if (current.contains(value))
      current.remove(value);
    else
      current.add(value);

    super.setValue(current.isEmpty ? null : current);

    if (list.isNotEmpty) {
      list.forEach((l) {
        if (current.contains(l[0]))
          l[1].addClass('current');
        else
          l[1].removeClass('current');
      });
      setShadowValue();
    }
  }

  void _onBlur(e) {
    if (list.isNotEmpty) setValue(getValue());
    removeAction('keydown.select');
    hideList();
  }

  String getText() {
    if (list.isNotEmpty) {
      final d = [];
      list.forEach((l) {
        if (l[1].existClass('current')) d.add(l[2]);
      });
      return d.join(', ');
    }
    return '';
  }
}
