part of forms;

class Input<T> extends InputField<T> {
  num _step;
  CLElement stepDom;

  Input([InputType type]) : super(type) {
    _setSteps();
  }

  void _setSteps() {
    if (_step != null && stepDom == null) {
      stepDom = new CLElement(new html.SpanElement())
        ..addClass('input-steps')
        ..append(new Icon(Icon.arrow_drop_down).dom
          ..onClick.listen(_stepUp)
          ..classes.add('clickable'))
        ..append(new Icon(Icon.arrow_drop_down).dom
          ..onClick.listen(_stepDown)
          ..classes.add('clickable'));
      setSuffixElement(stepDom);
      field.addAction((e) {
        if (utils.KeyValidator.isKeyDown(e))
          _stepDown(e);
        else if (utils.KeyValidator.isKeyUp(e)) _stepUp(e);
      }, 'keyup');
    }
  }

  void setType(InputType type) {
    if (type is InputTypeInt) {
      _step = type.step;
      _setSteps();
    } else if (type is InputTypeDouble) {
      _step = type.step;
      _setSteps();
    }
    set(type);
  }

  void _stepUp(e) {
    if (!state) return;
    var v = (getValue() as num) ?? 0;
    v += _step;
    setValue(v as T);
  }

  void _stepDown(e) {
    if (!state) return;
    var v = (getValue() as num) ?? 0;
    v -= _step;
    setValue(v as T);
  }

  @override
  void setValue(T value) => setValueDynamic(value);

  void setValueDynamic(dynamic value) {
    dynamic val;
    if (input_type != null) {
      input_type.set(value);
      field.dom.value = input_type.toString();
      val = input_type.value;
    } else {
      field.dom.value = (value == null) ? '' : value.toString();
      val = value;
    }
    super.setValue(val);
    if (val == null)
      setValid(true);
    else
      validateValue(val).then(setValid);
  }
}
