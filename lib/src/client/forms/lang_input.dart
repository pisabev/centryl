part of forms;

class LangInput extends DataElement<Map, html.DivElement> with Lang<Input> {
  LangInput(List lang) : super() {
    dom = new html.DivElement();
    self = this;
    builder = () => new Input();
    createDom(this, lang);
    Lang.objects.add(this);
    showSingleValue(Lang.current);
  }

  void setPlaceHolder(String text) {
    langs.forEach((v) => v.setPlaceHolder(text));
  }
}
