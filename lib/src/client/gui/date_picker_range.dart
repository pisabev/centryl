part of gui;

class DatePickerRange extends CLElement {
  //form.InputDate inputFrom, inputTo;
  form.Select choice;

  form.InputDateRange dateRange;
  DatePicker c1, c2;

  DatePickerRange(this.dateRange) : super(new DivElement()) {
    setClass('ui-calendar-picker-range');
  }

  void init() {
    removeChilds();
    final domOption = new CLElement(new DivElement())
          ..setClass('ui-calendar-picker-range-option')
          ..appendTo(this),
        domTop = new CLElement(new DivElement())
          ..setClass('ui-calendar-picker-range-top')
          ..appendTo(this);

    choice = new form.Select();
    final done = new action.Button()
      ..setTitle(Calendar.textDone())
      ..addAction((e) {
        dateRange.onPickerDone();
      });

    c1 = new DatePicker()
      ..onSet.listen((_) {
        final value = dateRange.getValue_() ?? [null, null];
        value[0] = c1.getDate();
        dateRange.setValue(value);
      })
      ..init()
      ..appendTo(domTop);
    c2 = new DatePicker()
      ..onSet.listen((_) {
        final value = dateRange.getValue_() ?? [null, null];
        value[1] = c2.getDate();
        dateRange.setValue(value);
      })
      ..init()
      ..appendTo(domTop);

    choice.addOption(0, Calendar.textChoosePeriod());
    var i = 1;
    Calendar.ranges.forEach((r) {
      choice.addOption(i, r['title']);
      i++;
    });
    choice.onValueChanged.listen((v) => setRange());

    domOption..append(choice)..append(done);
  }

  void setRange() {
    final i = choice.getValue();
    if (i > 0) set(Calendar.ranges[i - 1]['method']());
  }

  void set(List<DateTime> arr) {
    DateTime date1;
    DateTime date2;
    if (arr is List && arr.isNotEmpty && arr.length == 2) {
      date1 = arr[0]?.toLocal();
      date2 = arr[1]?.toLocal();
    }
    dateRange.setValue(arr);
    c1.setDate(date1 ?? new DateTime.now());
    c2.setDate(date2 ?? new DateTime.now());
  }
}
