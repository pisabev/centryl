part of forms;

class TextArea<T> extends TextAreaField<T> {
  TextArea() : super();

  @override
  void setValue(T? value) => setValueDynamic(value);

  void setValueDynamic(dynamic value) {
    dynamic val;
    if (input_type != null) {
      input_type!.set(value);
      field.dom.value = input_type.toString();
      val = input_type!.value;
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
