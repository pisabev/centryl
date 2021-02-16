part of forms;

abstract class Aggregator<T> {
  T total;
  html.TableCellElement dom;
  Selector selector;

  Aggregator([this.selector]);

  void add(RowDataCell object);

  void remove(RowDataCell object);

  void render();

  void reset();
}

class NumAggregator extends Aggregator<num> {
  num total = 0;

  NumAggregator() : super(null);

  void add(RowDataCell object) => total += object.object;

  void remove(RowDataCell object) => total -= object.object;

  void render() {
    dom
      ..innerHtml = ''
      ..append(new html.SpanElement()..text = total.toString());
  }

  void reset() => total = 0;
}

class CountAggregator extends Aggregator<num> {
  num total = 0;

  CountAggregator() : super(null);

  void add(RowDataCell object) => total++;

  void remove(RowDataCell object) => total--;

  void render() {
    dom
      ..innerHtml = ''
      ..append(new html.SpanElement()..text = total.toString());
  }

  void reset() => total = 0;
}

class GridColumn {
  GridList grid;

  dynamic title = '';

  dynamic width;

  dynamic minWidth;

  String key;

  int cell_index;

  dynamic filter;

  bool sortable = false;

  bool visible = true;

  bool send = true;

  String group;

  RowDataCell Function(
      GridColumn, html.TableRowElement, html.TableCellElement, dynamic) type;

  Aggregator aggregator;

  CLElement contDom;

  CLElement orderDom;

  CLElement filterDom;

  CLElement currentFilterDom;

  utils.UISlider slider;

  static GridColumn _gc;

  html.TableCellElement headerCell, footerCell;

  GridColumn(this.key);

  void renderTitle() {
    contDom = new CLElement(new html.DivElement())
      ..addClass('head')
      ..appendTo(headerCell);
    if (title is String)
      contDom.append(new CLElement(new html.SpanElement())..setText(title));
    else if (title is List) {
      title.forEach((el) {
        if (el is String)
          contDom.append(new CLElement(new html.SpanElement())..setText(el));
        else
          contDom.append(el);
      });
    } else
      contDom.append(title);
    headerCell.append(contDom.dom);
    filterDom = new CLElement(new html.DivElement())
      ..addClass('grid-filter-slide')
      ..addAction((e) => e.stopPropagation());
    slider =
        new utils.UISlider(filterDom, contDom, appendDom: true, positions: [
      utils.BoxingPosition.bottomRight,
      utils.BoxingPosition.bottomLeft,
      utils.BoxingPosition.topRight,
      utils.BoxingPosition.topLeft,
    ])
          ..autoWidth = false;
    if (filter != null) renderFilter();
    if (sortable) _setOrder(null);
    _setWidth();
  }

  void _setOrder(String way) {
    if (orderDom != null) orderDom.remove();

    ///clear other columns order
    if (way != null) {
      grid.map.forEach((currentKey, currentCol) {
        if (currentKey != key) currentCol._setOrder(null);
      });
    }

    orderDom = new CLElement(new html.AnchorElement())
      ..addClass('sort')
      ..appendTo(contDom)
      ..addAction((e) {
        if (grid.order == null) {
          grid.setOrder(new GridOrder(key, 'ASC'));
          _setOrder('ASC');
        } else if (grid.order?.way == 'ASC') {
          grid.setOrder(new GridOrder(key, 'DESC'));
          _setOrder('DESC');
        } else {
          grid.setOrder(null);
          _setOrder(null);
        }
      });
    var icon1 = new Icon(Icon.arrow_drop_up);
    var icon2 = new Icon(Icon.arrow_drop_down);
    if (way == 'ASC') {
      icon1 = new Icon('');
    } else if (way == 'DESC') {
      icon2 = new Icon('');
    }
    orderDom..append(icon1.dom)..append(icon2.dom);
  }

  void _setWidth() {
    if (minWidth != null)
      headerCell.style.minWidth = '$minWidth';
    else if (width != null) headerCell.style.width = '$width';
  }

  void renderFilter() {
    final f = new CLElement(new html.AnchorElement())
      ..addClass('filter')
      ..addAction(filterClick)
      ..append(new Icon(Icon.filter_list).dom);
    contDom.append(f);
    currentFilterDom = new CLElement(new html.Element.tag('em'));
    headerCell.append(currentFilterDom.dom);
    if (filter is List) {
      filter.forEach((f) {
        filterDom.append(f.dom);
        filterSetup(f);
      });
    } else {
      filterDom.append(filter.dom);
      filterSetup(filter);
    }
  }

  void renderAggregator(List<html.TableRowElement> rows) {
    if (aggregator == null) return;
    aggregator
      ..dom = footerCell
      ..render();
    if (aggregator.selector != null) {
      headerCell.classes.add('highlighted');
      aggregator.selector.init(this, rows);
    }
  }

  void resetAggregator() => aggregator?.reset();

  void filterSetup(DataElement filter) {
    filter.addAction((e) {
      if (utils.KeyValidator.isKeyEnter(e)) {
        filterHide();
      }
    }, 'keyup');
    filter.onValueChanged.listen((e) async {
      final text = await getFilterValue();
      currentFilterDom.setText(text);
      if (text.isNotEmpty) {
        currentFilterDom.append(new Icon(Icon.clear).dom
          ..onClick.listen((e) {
            filterReset();
          }));
      }
    });
  }

  void filterReset() {
    if (filter is List) {
      filter.forEach((f) => f.setValue(null));
    } else {
      filter.setValue(null);
    }
  }

  void filterClick([html.Event e]) {
    e.stopPropagation();
    filterShow();
  }

  void filterShow() {
    if (_gc != null) {
      _gc.filterHide();
      _gc = null;
    }
    currentFilterDom.hide(useVisibility: true);
    contDom.addClass('filtered');
    slider.show(null, _findZIndex());
    if (filter is List) {
      filter.first.focus();
    } else
      filter.focus();
    _gc = this;
    CLElement doc;
    doc = new CLElement(html.document.body)
      ..addAction((e) {
        if (_gc != null) _gc.filterHide();
        doc.removeAction('click.filter');
      }, 'click.filter');
  }

  String _findZIndex() {
    String zIndex;
    var parent = grid.dom.parent;
    while (parent != null && zIndex == null) {
      if (parent.style.zIndex.isNotEmpty) zIndex = parent.style.zIndex;
      parent = parent.parent;
    }
    return zIndex;
  }

  void filterHide() {
    contDom.removeClass('filtered');
    currentFilterDom.show();
    if (filter is List) {
      filter.forEach((f) => f.blur());
    } else
      filter.blur();
    slider.hide();
    _gc = null;
  }

  Future<String> getFilterValue() async {
    if (filter is List) {
      if (filter.every((f) => f.getValue() == null)) return '';
      final pres = <String>[];
      for (final f in filter) pres.add(await f.getRepresentation());
      return pres.join(' <-> ');
    } else {
      if (filter.getValue() == null) return '';
      return filter.getRepresentation();
    }
  }
}
