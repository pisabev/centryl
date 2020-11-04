part of forms;

class RowEditCell<T extends DataElement> extends RowDataCell<T> {
  CLElement el;
  bool _rendering = false;

  RowEditCell(GridColumn column, html.TableRowElement row,
      html.TableCellElement cell, T object)
      : super(column, row, cell, object) {
    el = new CLElement(this.cell);
    enable();
    setElement();
  }

  dynamic getValue() => object.getValue();

  void setValue(dynamic value) => object.setValue(value);

  void setObject(dynamic obj) {
    object = obj;
    enable();
    setElement();
    render();
  }

  void disable() {
    el
      ..setAttribute('tabindex', '-1')
      ..removeClass('editable')
      ..removeAction('focus');
  }

  void enable() {
    if (object.existClass('disabled')) return;
    el
      ..removeAction('focus')
      ..setAttribute('tabindex', '0')
      ..addClass('editable')
      ..addAction(swap, 'focus');
  }

  Future render() async {
    if (_rendering) return;
    _rendering = true;
    final tEl = await object.getRepresentationElement();
    final t = await object.getRepresentation();
    final representation = tEl ?? (new html.SpanElement()..text = t);
    el
      ..removeChilds()
      ..addClass('edit')
      ..setAttribute('title', t)
      ..setStyle({'padding': null})
      ..append(representation);
    if (tEl == null) el.addClass('text');
    _rendering = false;
  }

  void setElement() {
    object
      ..onValueChanged.listen((e) {
        render();
        if (column.send) column.grid.rowChanged(row);
        column.grid.observer.execHooks(GridList.hook_render);
      })
      ..onReadyChanged.listen((e) {
        if (e.isReady())
          el.removeClass('error');
        else
          el.addClass('error');
        render();
        column.grid.observer.execHooks(GridList.hook_render);
      })
      ..addAction((e) => e.stopPropagation(), 'mousedown')
      ..addAction((e) => e.stopPropagation(), 'click');
  }

  void swap([html.Event e]) {
    el
      ..removeChilds()
      ..removeClass('edit')
      ..removeClass('text')
      ..removeClass('error')
      ..setStyle({'padding': '0'})
      ..setAttribute('tabindex', '-1') // Fix for tab + shift
      ..append(object);
    object
      ..setHeight(new Dimension.px(el.getHeightInner()))
      ..focus()
      ..select()
      ..addAction<html.FocusEvent>((e) {
        if (object.dom.contains(e.relatedTarget)) return;
        object.removeAction('focusout.swap');
        render();
        el.setAttribute('tabindex', '0'); // Fix for tab + shift
      }, 'focusout.swap');
  }
}
