part of forms;

class InputDateRange extends Input<List<dynamic>> {
  final StreamController _contrOpen = new StreamController.broadcast();
  final StreamController _contrClose = new StreamController.broadcast();

  late CLElement domAction;
  late gui.DatePickerRange picker;
  late utils.UISlider _slider;

  InputDateRange() : super(new InputTypeDateRange()) {
    addClass('ui-field-input date');
    domAction = new CLElement(new Icon(Icon.date_range).dom)
      ..addAction(getDatePicker)
      ..addClass('suffix')
      ..addClass('clickable')
      ..appendTo(inner);
    picker = new gui.DatePickerRange(this)
      ..appendTo(this)
      ..addAction<html.Event>((e) => e.stopPropagation(), 'mousedown');
    _slider = new utils.UISlider(picker, this)..autoWidth = false;
    addAction<html.KeyboardEvent>((e) {
      if (e.keyCode == 8) {
        if (field.dom.value!.endsWith(':') || field.dom.value!.endsWith('/'))
          field.dom.value =
              field.dom.value!.substring(0, field.dom.value!.length - 1);
        else if (field.dom.value!.endsWith(' - '))
          field.dom.value =
              field.dom.value!.substring(0, field.dom.value!.length - 3);
      }
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
      } else if (field.dom.value!
          .startsWith(new RegExp(r'^\d\d\/\d\d\/\d\d\d\d$'))) {
        field.dom.value = '${field.dom.value!} - ';
      } else if (field.dom.value!
              .startsWith(new RegExp(r'^\d\d\/\d\d\/\d\d\d\d - \d\d$')) ||
          field.dom.value!
              .startsWith(new RegExp(r'^\d\d\/\d\d\/\d\d\d\d - \d\d\/\d\d$'))) {
        final firstPart = field.dom.value!.split(' - ');
        final parts = firstPart.last.split('/');
        var str = '';
        if (parts.length == 1)
          str = '${_maxPad(31, parts[0])}';
        else if (parts.length == 2)
          str = '${_maxPad(31, parts[0])}'
              '/${_maxPad(12, parts[1])}';
        str += '/';
        field.dom.value = '${firstPart.first} - $str';
      }
    }, 'keyup');
  }

  String _maxPad(int max, String value) =>
      math.min(max, int.parse(value)).toString().padLeft(2, '0');

  Stream<void> get onPickerOpen => _contrOpen.stream;

  Stream<void> get onPickerClose => _contrClose.stream;

  @override
  List<String?>? getValue() {
    final d = super.getValue();
    if (d == null) return null;
    return d.map((d) => d?.toString()).toList();
  }

  bool hasValue() {
    final val = getValue();
    return val != null && val.any((e) => e != null);
  }

  List<DateTime?>? getValue_() => super.getValue() as List<DateTime?>?;

  void setValue(List? value) {
    super.setValue(value);
    // Explicitly calling change (does not work by default logic)
    contrValue.add(this);
  }

  String getRepresentation() => input_type.toString();

  void onPickerDone() {
    _slider.hide();
    _contrClose.add(null);
  }

  void getDatePicker(html.Event e) {
    picker
      ..init()
      ..set(getValue_());

    late CLElement doc;
    doc = new CLElement(html.document.body)
      ..addAction((e) {
        onPickerDone();
        doc.removeAction('mousedown.daterange');
      }, 'mousedown.daterange');

    _slider.show();
    _contrOpen.add(null);
  }
}
