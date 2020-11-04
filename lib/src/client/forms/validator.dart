part of forms;

class InputType {
  const InputType();
}

class InputTypeInt extends InputType {
  final List<int> range;
  final int step;

  InputTypeInt({this.range, this.step});
}

class InputTypeString extends InputType {
  final List<int> length;

  InputTypeString({this.length});
}

class InputTypeDouble extends InputType {
  final List<num> range;
  final num step;

  InputTypeDouble({this.range, this.step});
}

class InputTypeDate extends InputType {
  final List<DateTime> range;
  final bool inclusive;

  InputTypeDate({this.range, this.inclusive = false});
}

class InputTypeDateTime extends InputType {
  final List<DateTime> range;
  final bool inclusive;

  InputTypeDateTime({this.range, this.inclusive = false});
}

class InputTypeDateRange extends InputType {
  InputTypeDateRange();
}

mixin Validator {
  static const String INT = 'int';
  static const String FLOAT = 'float';
  static const String DATE = 'date';
  static const String DATETIME = 'datetime';
  static const String DATERANGE = 'daterange';

  _InputTypeBase input_type;

  utils.Observer observer = new utils.Observer();

  Future<bool> validateValue(dynamic v) => observer.execHooksAsync('value', v);

  bool validateInput(html.Event e) => observer.execHooks('input', e);

  void set(InputType type) {
    if (type is InputTypeInt)
      setTypeInt(type.range);
    else if (type is InputTypeDouble)
      setTypeDouble(type.range);
    else if (type is InputTypeDate)
      setTypeDate(type.range, type.inclusive);
    else if (type is InputTypeDateTime)
      setTypeDateTime(type.range, type.inclusive);
    else if (type is InputTypeDateRange)
      setTypeDateRange();
    else if (type is InputTypeString) setTypeString(type.length);
  }

  void setTypeInt([List<int> range]) {
    if (input_type != null) removeValidationsOnInput(input_type.validateInput);
    input_type = new _InputTypeInt(range);
    addValidationOnInput(input_type.validateInput);
  }

  void setTypeDouble([List<num> range]) {
    if (input_type != null) removeValidationsOnInput(input_type.validateInput);
    input_type = new _InputTypeFloat(range);
    addValidationOnInput(input_type.validateInput);
  }

  void setTypeString([List<int> length]) {
    if (input_type != null) removeValidationsOnValue(input_type.validateValue);
    input_type = new _InputTypeString(length);
    if (length != null) addValidationOnValue(input_type.validateValue);
  }

  void setTypeDate([List<DateTime> range, bool inclusive = false]) {
    if (input_type != null) {
      removeValidationsOnInput(input_type.validateInput);
      removeValidationsOnValue(input_type.validateValue);
    }
    input_type = new _InputTypeDate(range, inclusive);
    addValidationOnInput(input_type.validateInput);
    if (range != null) addValidationOnValue(input_type.validateValue);
  }

  void setTypeDateTime([List<DateTime> range, bool inclusive = false]) {
    if (input_type != null) {
      removeValidationsOnInput(input_type.validateInput);
      removeValidationsOnValue(input_type.validateValue);
    }
    input_type = new _InputTypeDateTime(range, inclusive);
    addValidationOnInput(input_type.validateInput);
    if (range != null) addValidationOnValue(input_type.validateValue);
  }

  void setTypeDateRange() {
    if (input_type != null) removeValidationsOnInput(input_type.validateInput);
    input_type = new _InputTypeDateRange();
    addValidationOnInput(input_type.validateInput);
  }

  void addValidationOnInput(utils.ObserverFunction<html.Event> func) =>
      observer.addHook('input', func);

  void addValidationOnValue<T>(utils.ObserverFunction<T> func) =>
      observer.addHook('value', func);

  void removeValidationsOnValue<T>([utils.ObserverFunction<T> func]) =>
      observer.removeHook('value', func);

  void removeValidationsOnInput([utils.ObserverFunction<html.Event> func]) =>
      observer.removeHook('input', func);
}
