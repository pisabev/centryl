part of forms;

class _InputTimeField<T, E extends html.InputElement>
    extends DataElement<int, html.InputElement> with Validator {
  _InputTimeField(InputType type) {
    set(type);
    dom = new html.InputElement();

    addAction(_onFocus, 'focus');
    addAction(_onBlur, 'blur');
    addAction(_onKeyDown, 'keydown');
    addAction<html.Event>((e) {
      if (!validateInput(e)) e.preventDefault();
    }, 'keypress');
    onReadyChanged.listen((e) {
      if (e.isReady())
        removeClass('error');
      else
        addClass('error');
    });
  }

  void setValue(int? value) => setValueDynamic(value);

  void setValueDynamic(dynamic value) {
    dynamic val;
    if (input_type != null) {
      input_type!.set(value);
      if (input_type!.value != null)
        dom.value = input_type.toString().padLeft(2, '0');
      else
        dom.value = '';
      val = input_type!.value;
    } else {
      dom.value = (value == null) ? '' : value.toString();
      val = value;
    }
    super.setValue(val);
    if (val == null)
      setValid(true);
    else
      validateValue(val).then(setValid);
  }

  void focus() {
    dom.focus();
    select();
  }

  void blur() {
    dom.blur();
  }

  void _onFocus(html.Event e) {
    select();
  }

  void _onBlur(html.Event e) =>
      setValueDynamic(dom.value!.isEmpty ? null : dom.value);

  void _onKeyDown(html.KeyboardEvent e) {
    if (e.keyCode == 13) setValueDynamic(dom.value!.isEmpty ? null : dom.value);
  }

  void setPlaceHolder(String value) {
    dom.placeholder = value;
  }

  void select() {
    dom.select();
  }

  void disable() {
    state = false;
    addClass('disabled');
    dom..setAttribute('tabindex', '-1')..setAttribute('disabled', 'true');
  }

  void enable() {
    state = true;
    removeClass('disabled');
    dom
      ..setAttribute('tabindex', '0')
      ..attributes.remove('disabled');
  }
}

class InputTime extends DataElement<int, html.SpanElement> with Validator {
  late html.SpanElement inner, input;
  late _InputTimeField field_hours, field_minutes;
  bool canBeNull;

  InputTime({int? maxHours = 23, this.canBeNull = false}) : super() {
    dom = new html.SpanElement();
    setAttribute('tabindex', '0');
    inner = new html.SpanElement()..classes.add('inner');
    input = new html.SpanElement()..classes.add('input');
    inner.append(input);
    append(inner);
    addClass('ui-field-input time');

    final hoursRange = maxHours != null ? [0, maxHours] : null;
    final hourFieldLength =
        (hoursRange != null) ? maxHours.toString().length : null;
    final minutesRange = [0, 59];
    const minuteFieldLength = 2;
    field_hours = new _InputTimeField(new InputTypeInt(range: hoursRange))
      ..addAction<html.KeyboardEvent>((e) {
        if (field_hours.dom.value!.length == hourFieldLength &&
            utils.KeyValidator.isNum(e)) field_minutes.focus();
      }, 'keyup')
      ..addKeyAction((e) => _keyNavigate(e, field_hours, hoursRange))
      ..addAction((e) => addClass('focus'), 'focus')
      ..setPlaceHolder('--');
    if (hourFieldLength != null) field_hours.dom.maxLength = hourFieldLength;
    field_minutes = new _InputTimeField(new InputTypeInt(range: minutesRange))
      ..addKeyAction((e) => _keyNavigate(e, field_minutes, minutesRange))
      ..addAction((e) => addClass('focus'), 'focus')
      ..dom.maxLength = minuteFieldLength
      ..setPlaceHolder('--');
    input
      ..append(field_hours.dom)
      ..append(new html.SpanElement()
        ..text = ':'
        ..classes.add('delimiter'))
      ..append(field_minutes.dom)
      ..append(new html.SpanElement()..classes.add('separator'));
    addAction((e) {
      if (field_hours.dom == html.document.activeElement ||
          field_minutes.dom == html.document.activeElement) return;
      focus();
    }, 'focusin');
    addAction<html.FocusEvent>((e) {
      if (dom.contains(e.relatedTarget as html.Node?)) return;
      removeClass('focus');
      _checkValue();
    }, 'focusout');

    onReadyChanged.listen((e) {
      if (e.isReady())
        removeClass('error');
      else
        addClass('error');
    });
  }

  void setValue(int? value) {
    int? hours;
    int? minutes;
    super.setValue(value);
    if (value == null) {
      hours = null;
      minutes = null;
    } else {
      hours = (value / 60).floor();
      minutes = value - hours * 60;
    }
    field_hours.setValue(hours);
    field_minutes.setValue(minutes);
  }

  void setFromDateTime(DateTime date) {
    final d = date.toLocal();
    setValue(d.hour * 60 + d.minute);
  }

  int? getHours() => field_hours.getValue();

  int? getMinutes() => field_minutes.getValue();

  void _checkValue() {
    final vh = field_hours.getValue();
    final vm = field_minutes.getValue();
    if (canBeNull && vh == null && vm == null) {
      setValue(null);
      return;
    }
    setValue((vh ?? 0) * 60 + (vm ?? 0));
  }

  bool _keyNavigate(e, _InputTimeField f, List? range) {
    var v = f.getValue() ?? -1;
    if (utils.KeyValidator.isKeyUp(e))
      v++;
    else if (utils.KeyValidator.isKeyDown(e))
      v--;
    else
      return false;
    if (range != null) {
      if (v > range[1]) v = range[0];
      if (v < range[0]) v = range[1];
    }
    f.setValue(v);
    return false;
  }

  Future<String> getRepresentation() async => (getValue() != null)
      ? '${field_hours.dom.value}:${field_minutes.dom.value}'
      : '';

  void disable() {
    state = false;
    addClass('disabled');
    field_hours.disable();
    field_minutes.disable();
  }

  void focus() {
    addClass('focus');
    field_hours.focus();
  }

  void enable() {
    state = true;
    removeClass('disabled');
    field_hours.enable();
    field_minutes.enable();
  }
}
