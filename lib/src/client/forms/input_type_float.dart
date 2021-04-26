part of forms;

class _InputTypeFloat implements _InputTypeBase<num> {
  List<num?>? range;
  num? value;

  _InputTypeFloat([this.range]);

  void set(dynamic v) {
    value = (v is String) ? double.tryParse(v.replaceFirst(',', '.')) : v;
    if (value != null && range is List && range!.length == 2) {
      if (range![0] != null) value = math.max(value!, range![0]!);
      if (range![1] != null) value = math.min(value!, range![1]!);
    }
  }

  String toString() => value == null ? '' : value.toString();

  FutureOr<bool> validateValue(_) => true;

  bool validateInput(html.KeyboardEvent e) =>
      utils.KeyValidator.isNum(e) ||
      utils.KeyValidator.isPlus(e) ||
      utils.KeyValidator.isMinus(e) ||
      utils.KeyValidator.isPoint(e) ||
      utils.KeyValidator.isComma(e);
}
