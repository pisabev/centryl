part of forms;

class _InputTypeInt implements _InputTypeBase<int> {
  List<num?>? range;
  int? value;

  _InputTypeInt([this.range]);

  void set(dynamic v) {
    value = (v is String) ? int.tryParse(v) : v;
    if (value != null && range is List && range!.length == 2) {
      if (range![0] != null) value = math.max(value!, range![0]!.toInt());
      if (range![1] != null) value = math.min(value!, range![1]!.toInt());
    }
  }

  String toString() => value == null ? '' : value.toString();

  FutureOr<bool> validateValue(_) => true;

  FutureOr<bool> validateInput(html.Event e) =>
      utils.KeyValidator.isNum(e as html.KeyboardEvent) ||
      utils.KeyValidator.isPlus(e) ||
      utils.KeyValidator.isMinus(e);
}
