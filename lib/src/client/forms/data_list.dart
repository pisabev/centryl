part of forms;

class DataList extends Data<List> {
  List<Form> arr_data = [];

  void setValue(List value) {
    if (value != null && value.isNotEmpty) {
      final form = new Form();
      value.forEach((el) {
        el.onValueChanged.listen(contrValue.add);
        form.add(el);
      });
      arr_data.add(form);
    } else
      arr_data = [];
    contrValue.add(this);
  }

  List getValue() => arr_data.map((form) => form.getValue()).toList();
}
