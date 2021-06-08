part of forms;

mixin Lang<E extends DataElement<dynamic, html.Element>> {
  late CLElement domInner;
  late CLElement<html.ImageElement> flag;
  List<E> langs = [];
  late DataElement Function() builder;
  late DataElement self;
  Map<String, String> flags = {};

  static List<Lang> objects = [];
  static int current = 0;

  void createDom(CLElementBase dom, List languages) {
    dom.addClass('ui-field-lang');
    final inner = new CLElement(new html.DivElement())..appendTo(dom);
    flag = new CLElement(new html.ImageElement())
      ..appendTo(dom)
      ..addAction(toggleLang, 'click');
    var i = 0;
    languages.forEach((l) {
      final language_id = l['language_id'];
      langs.add(builder() as E
        ..setName(language_id.toString())
        ..onValueChanged.listen((_) => self.contrValue.add(self))
        ..appendTo(inner));
      flags[i.toString()] = l['code'];
      i++;
    });
  }

  List getFields() => langs;

  void toggleLang(_) {
    current++;
    if (current == langs.length) current = 0;
    objects.forEach((l) => l.showSingleValue(current));
  }

  void setSingleValue(dynamic value) {
    langs[current].setValue(value);
    showSingleValue(current);
  }

  void setAllValues(dynamic value) {
    langs.forEach((v) => v.setValue(value));
    showSingleValue(current);
  }

  void showSingleValue(dynamic key) {
    hideAll();
    langs[key].show();
    flag.dom.src = '${Icon.ICON_FLAG_PATH + flags[key.toString()]!}.svg';
  }

  dynamic getSingleValue(int key) => langs[key].getValue();

  Map getValue() {
    final Map<String, String> value = {};
    langs.forEach((v) => value[v.getName()!] = v.getValue());
    return value;
  }

  void setValue(Map? valueObj) {
    if (valueObj != null)
      langs.forEach((v) => v.setValue(valueObj[v.getName()]));
    else
      langs.forEach((v) => v.setValue(null));
  }

  void focus() => langs[current].focus();

  void blur() => langs[current].blur();

  void disable() {
    langs.forEach((v) => v.disable());
  }

  void enable() {
    langs.forEach((v) => v.enable());
  }

  void setClass(String clas) {
    langs.forEach((v) => v.setClass(clas));
  }

  void hideAll() {
    langs.forEach((v) => v.hide());
  }
}
