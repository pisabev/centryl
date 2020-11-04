part of forms;

class LangArea extends DataElement<Map, html.DivElement> with Lang<TextArea> {
  LangArea(List lang) : super() {
    dom = new html.DivElement();
    self = this;
    builder = () => new TextArea();
    createDom(this, lang);
    Lang.objects.add(this);
    showSingleValue(Lang.current);
  }
}
