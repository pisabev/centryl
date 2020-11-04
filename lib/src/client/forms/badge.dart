part of forms;

class Badge extends DataElement<String, html.SpanElement>
    with DataLoader<String> {
  List<Form> forms = [];

  Badge() : super() {
    createDom();
  }

  void createDom() {
    dom = new html.SpanElement();
    setClass('ui-badge');
    initDataLoader(this);
    _onLoadEndInner.listen((_) {
      setValue(data);
      setText(data);
      loadEnd();
    });
  }
}
