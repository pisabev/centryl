part of forms;

class Paginator extends DataElement<Map, html.DivElement> {
  int _page = 1;
  int _limit = 50;
  int _total = 0;

  late action.Button contr_p, contr_n, contr_l, contr_f;
  late Input contr_i;
  late Select contr_c;
  late Text contr_t;

  Paginator() : super() {
    dom = new html.DivElement();
    setClass('ui-paginator');
    contr_f = new action.Button()
      ..setIcon(Icon.first_page)
      ..addAction(firstPage, 'click');
    contr_p = new action.Button()
      ..setIcon(Icon.chevron_left)
      ..addAction(previousPage, 'click');
    contr_n = new action.Button()
      ..setIcon(Icon.chevron_right)
      ..addAction(nextPage, 'click');
    contr_l = new action.Button()
      ..setIcon(Icon.last_page)
      ..addAction(lastPage, 'click');

    contr_i = new Input(new InputTypeInt())
      ..setValue(1)
      ..addClass('s')
      ..onValueChanged.listen((_) => curPage());

    contr_c = new Select()
      ..addOption(50, 50)
      ..addOption(100, 100)
      ..addOption(500, 500)
      ..addOption(1000, 1000)
      ..onValueChanged.listen((_) => firstPage());

    contr_t = new Text()..addClass('text');

    append(contr_f);
    append(contr_p);
    append(contr_i);
    append(contr_n);
    append(contr_l);
    append(contr_c);
    append(contr_t);
  }

  void firstPage([_]) {
    setPage(1);
  }

  void previousPage([_]) {
    setPage(_page - 1);
  }

  void nextPage([_]) {
    setPage(_page + 1);
  }

  void lastPage([_]) => setPage((_total / _limit).ceil());

  void curPage([_]) {
    setPage(contr_i.getValue());
  }

  void setPage([int? page]) {
    page = (page == null) ? _page : page;
    final limit = contr_c.getValue();
    final pages = (limit != null) ? (_total / limit).ceil() : 1;
    page = math.max(math.min(page, pages), 1);
    contr_i.setValue(page);
    final right_state = (limit != null) && (page * limit < _total);
    contr_l.setState(right_state);
    contr_n.setState(right_state);
    final left_state = (limit != null) && (page != 1);
    contr_f.setState(left_state);
    contr_p.setState(left_state);
    if (_page == page && _limit == limit) return;
    _page = page;
    _limit = limit;
    contrValue.add(this);
  }

  void setTotal(int total) {
    _total = total;
    var from = (_page - 1) * _limit + 1;
    from = (from < 0) ? 0 : from;
    var to = _page * _limit;
    to = (to > _total) ? _total : to;
    contr_t.setValue(intl.pages(from, to, _total));
    setPage(null);
  }

  Map getValue() => {'page': _page, 'limit': _limit};

  void focus() {}

  void blur() {}

  void disable() {}

  void enable() {}
}
