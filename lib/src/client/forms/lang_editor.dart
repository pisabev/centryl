part of forms;

class LangEditor extends DataElement<Map, html.DivElement> with Lang<Editor> {
  app.Application ap;

  LangEditor(this.ap, List lang) : super() {
    dom = new html.DivElement();
    self = this;
    builder = () => new Editor(ap);
    createDom(this, lang);
    Lang.objects.add(this);
    showSingleValue(Lang.current);
  }
}
