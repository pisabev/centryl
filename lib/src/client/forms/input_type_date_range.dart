part of forms;

class _InputTypeDateRange implements _InputTypeBase<List<DateTime?>> {
  List<DateTime?>? value;
  String sep = ' - ';

  _InputTypeDateRange();

  void set(dynamic v) {
    if (v is String) {
      final dates = v.split(sep);
      value = [
        utils.Calendar.parse(dates.first)?.toLocal(),
        utils.Calendar.parse(dates.last)?.toLocal()
      ];
      if (value!.every((e) => e == null)) value = null;
    } else if (v is List && v.length == 2) {
      DateTime date1 = (v.first is String)
          ? utils.Calendar.parse(v.first)?.toLocal()
          : v.first?.toLocal();
      if (date1 is DateTime)
        date1 = new DateTime(date1.year, date1.month, date1.day);

      DateTime date2 = (v.last is String)
          ? utils.Calendar.parse(v.last)?.toLocal()
          : v.last?.toLocal();
      if (date2 is DateTime)
        date2 = new DateTime(date2.year, date2.month, date2.day);
      value = [date1, date2];
      if (value!.every((e) => e == null)) value = null;
    } else {
      value = null;
    }
  }

  String toString() {
    if (value == null) return '';
    if (value![0] == null && value![1] == null) return '';
    return value!
        .map((v) => v == null ? '' : utils.Calendar.string(v.toLocal()))
        .join(sep);
  }

  FutureOr<bool> validateValue(_) => true;

  bool validateInput(html.KeyboardEvent e) =>
      utils.KeyValidator.isNum(e) || utils.KeyValidator.isSlash(e);
}
