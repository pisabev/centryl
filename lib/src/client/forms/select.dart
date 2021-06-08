part of forms;

class Select<T> extends _SelectBase<T> {
  bool _testAgainstList(T v) => list.any((r) => r[0] == v);

  Select();

  factory Select.fromOptions(List options) =>
      new Select()..setOptions(options);

  void setValue(T? value) => _setValue(value);

  void _manageValue(dynamic value) {
    var newIndex = 0;
    for (var i = 0; i < list.length; i++) {
      if (list[i][0] == value) {
        newIndex = i;
        break;
      }
    }
    list[currentIndex][1].removeClass('current');
    list[newIndex][1].addClass('current');
    currentIndex = newIndex;
    final v = list[currentIndex][0];
    super.setValue(v);
    setShadowValue();
  }
}
