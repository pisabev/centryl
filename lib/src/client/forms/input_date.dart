part of forms;

class InputDate extends Input {
  final StreamController<void> _contrOpen = new StreamController.broadcast();
  final StreamController<void> _contrClose = new StreamController.broadcast();

  late CLElement domAction;
  late gui.DatePicker picker;
  late utils.UISlider _slider;

  InputDate({List<DateTime>? range, bool inclusive = false})
      : super(new InputTypeDate(range: range, inclusive: inclusive)) {
    addClass('date');
    domAction = new CLElement(new Icon(Icon.today).dom)
      ..addAction(showDatePicker)
      ..addClass('suffix')
      ..addClass('clickable')
      ..appendTo(inner);
    picker = new gui.DatePicker()
      ..onSet.listen((_) {
        if(picker.getDate() != null)
          fieldUpdate(picker.getDate()!);
      })
      ..appendTo(this)
      ..addAction<html.Event>((e) => e.stopPropagation(), 'mousedown');
    addAction(showDatePicker, 'dblclick');
    picker.filter = validateValue;
    _slider = new utils.UISlider(picker, this)..autoWidth = false;
    addAction<html.KeyboardEvent>((e) {
      if (e.keyCode == 8 && field.dom.value!.endsWith('/'))
        field.dom.value =
            field.dom.value!.substring(0, field.dom.value!.length - 1);
    }, 'keydown');
    addAction<html.KeyboardEvent>((e) {
      if (e.keyCode == 8) return;
      if (field.dom.value!.startsWith(new RegExp(r'^\d\d$')) ||
          field.dom.value!.startsWith(new RegExp(r'^\d\d\/\d\d$'))) {
        final parts = field.dom.value!.split('/');
        if (parts.length == 1)
          field.dom.value = '${_maxPad(31, parts[0])}';
        else if (parts.length == 2)
          field.dom.value = '${_maxPad(31, parts[0])}'
              '/${_maxPad(12, parts[1])}';
        field.dom.value = '${field.dom.value!}/';
      }
    }, 'keyup');
  }

  String _maxPad(int max, String value) =>
      math.min(max, int.parse(value)).toString().padLeft(2, '0');

  Stream<void> get onPickerOpen => _contrOpen.stream;

  Stream<void> get onPickerClose => _contrClose.stream;

  void noAction() {
    domAction.remove();
    removeClass('icon');
  }

  void fieldUpdate(DateTime value) {
    blur();
    setValue(value);
    hideDatePicker();
  }

  @override
  void disable() {
    super.disable();
    domAction.hide();
  }

  @override
  void enable() {
    super.enable();
    domAction.show();
  }

  @override
  String? getValue() {
    final d = super.getValue();
    return (d is DateTime) ? d.toString() : d;
  }

  String getRepresentation() => input_type.toString();

  DateTime? getValue_() => super.getValue();

  void hideDatePicker() {
    _slider.hide();
    _contrClose.add(null);
  }

  void showDatePicker(html.Event e) {
    picker
      ..init()
      ..setDate(getValue_());
    late CLElement doc;
    doc = new CLElement(html.document.body)
      ..addAction((e) {
        hideDatePicker();
        doc.removeAction('mousedown.date');
      }, 'mousedown.date');

    _slider.show();
    _contrOpen.add(null);
  }
}
