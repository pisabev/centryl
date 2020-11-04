part of forms;

class _InputTypeString implements _InputTypeBase<String> {
  List<int> range;
  String value;

  _InputTypeString([this.range]);

  void set(dynamic v) => value = v;

  String toString() => value == null ? '' : value.toString();

  FutureOr<bool> validateValue(_) {
    if (value != null && range is List && range.length == 2) {
      final min = range[0] ?? 0;
      final max = range[1] ?? value.length + 1;
      return value.length <= max && value.length >= min;
    }
    return true;
  }

  FutureOr<bool> validateInput(html.Event e) => true;
}
