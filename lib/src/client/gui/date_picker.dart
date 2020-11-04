part of gui;

class DatePicker extends CLElement {
  final StreamController<DatePicker> _contrSet =
      new StreamController.broadcast();

  static List month_days = [31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  CLElement<TableSectionElement> domTbody;

  CLElement domMonth, domYear;

  CLElement clicked;

  bool time;
  bool doClose = false;

  form.InputTime timeField;

  FutureOr<bool> Function(DateTime date) filter;

  DateTime _currentDate;
  DateTime _viewDate;
  DateTime _choosedDate;

  DatePicker({this.time = false}) : super(new DivElement()) {
    setClass('ui-calendar');
  }

  Stream<DatePicker> get onSet => _contrSet.stream;

  void init() {
    doClose = false;
    removeChilds();
    _currentDate = new DateTime.now();
    _viewDate =
        new DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
    _choosedDate = new DateTime(_currentDate.year, _currentDate.month,
        _currentDate.day, _currentDate.hour, _currentDate.minute);
    createHTML();
  }

  void createHTML() {
    final nav = new CLElement(new DivElement())
          ..setClass('ui-cal-navigation')
          ..appendTo(this),
        nav_left = new CLElement(new DivElement())
          ..setClass('ui-cal-nav-left')
          ..appendTo(nav),
        nav_right = new CLElement(new DivElement())
          ..setClass('ui-cal-nav-right')
          ..appendTo(nav);

    new action.Button()
      ..setIcon(Icon.chevron_left)
      ..addAction((e) {
        _set(new DateTime(_viewDate.year, _viewDate.month - 1, _viewDate.day));
      }, 'click')
      ..appendTo(nav_left);
    final label_month = new CLElement(new ParagraphElement())
      ..appendTo(nav_left);
    new action.Button()
      ..setIcon(Icon.chevron_right)
      ..addAction((e) {
        _set(new DateTime(_viewDate.year, _viewDate.month + 1, _viewDate.day));
      }, 'click')
      ..appendTo(nav_left);

    new action.Button()
      ..setIcon(Icon.chevron_left)
      ..addAction((e) {
        _set(new DateTime(_viewDate.year - 1, _viewDate.month, _viewDate.day));
      }, 'click')
      ..appendTo(nav_right);
    final label_year = new CLElement(new ParagraphElement())
      ..appendTo(nav_right);
    new action.Button()
      ..setIcon(Icon.chevron_right)
      ..addAction((e) {
        _set(new DateTime(_viewDate.year + 1, _viewDate.month, _viewDate.day));
      }, 'click')
      ..appendTo(nav_right);

    final table = new CLElement<TableElement>(new TableElement())
      ..appendTo(this);
    final thead = new CLElement<TableSectionElement>(table.dom.createTHead())
          ..appendTo(table),
        tbody = new CLElement<TableSectionElement>(table.dom.createTBody())
          ..appendTo(table);

    var row = thead.dom.insertRow(-1);
    for (var day = 0; day < 7; day++) {
      row.insertCell(-1)
        ..className = Calendar.isWeekend(day) ? 'weekend' : ''
        ..innerHtml = Calendar.getDayStringVeryShortByNum(day);
    }
    for (var cell = 0; cell < 42; cell++) {
      row = (cell % 7 == 0) ? tbody.dom.insertRow(-1) : row;
      final c = row.insertCell(-1);
      final mod = cell % 7;
      c
        ..className = Calendar.isWeekend(mod) ? 'weekend' : ''
        ..append(new SpanElement());
    }

    final opt = new CLElement(new DivElement())
      ..setClass('ui-calendar-option')
      ..appendTo(this);

    if (time) {
      timeField = new form.InputTime()
        ..appendTo(opt)
        ..setStyle({'margin-right': 'auto'});
      new action.Button()
        ..setStyle({'margin-right': 'auto'})
        ..setIcon(cl.Icon.check)
        ..appendTo(opt)
        ..addAction((e) => _chooseCurrent());
    }

    final opt_cur = new action.Button()
      ..setTitle(Calendar.textToday())
      ..appendTo(opt);

    final opt_empty = new action.Button()
      ..setTitle(Calendar.textEmpty())
      ..appendTo(opt);

    opt_cur.addAction((e) => _setDate(new DateTime.fromMillisecondsSinceEpoch(
        _currentDate.millisecondsSinceEpoch)));
    opt_empty.addAction((e) => _setDate(null));

    domMonth = label_month;
    domYear = label_year;
    domTbody = tbody;
  }

  void _chooseCurrent([day_sel]) {
    day_sel ??= (_viewDate.year == _choosedDate.year &&
            _viewDate.month == _choosedDate.month)
        ? _choosedDate.day
        : null;
    if (day_sel == null) return;
    _setDate(new DateTime(_viewDate.year, _viewDate.month, day_sel,
        timeField.getHours() ?? 0, timeField.getMinutes() ?? 0));
    doClose = true;
  }

  DateTime getDate() => _choosedDate;

  void _setDate(DateTime date) {
    _choosedDate = date;
    _contrSet.add(this);
  }

  void setDate(DateTime date) {
    if (date != null) {
      _viewDate = new DateTime(date.year, date.month, date.day);
      _choosedDate =
          new DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch);
    }
    render();
  }

  Future _set([DateTime date]) async {
    _viewDate = date ?? _viewDate;
    await render();
  }

  Future<void> render() async {
    domMonth.dom.innerHtml = Calendar.getMonthString(_viewDate.month);
    domYear.dom.innerHtml = _viewDate.year.toString();
    final h = new DateTime(_viewDate.year, _viewDate.month, 1);
    final firstDay = h.weekday;
    month_days[1] =
        (((h.year % 100 != 0) && (h.year % 4 == 0)) || (h.year % 400 == 0))
            ? 29
            : 28;

    final today = (_viewDate.year == _currentDate.year &&
            _viewDate.month == _currentDate.month)
        ? _currentDate.day
        : null;
    final day_sel = (_viewDate.year == _choosedDate.year &&
            _viewDate.month == _choosedDate.month)
        ? _choosedDate.day
        : null;

    var k = 0;
    void clicked(DatePicker obj, [CLElement n]) {
      if (obj.clicked != null) obj.clicked.removeClass('selected');
      if (n != null) obj.clicked = n..addClass('selected');
    }

    clicked(this, null);
    if (time) {
      timeField
        ..setValue(_choosedDate.hour * 60 + _choosedDate.minute)
        ..removeActionsAll()
        ..addAction((e) {
          if (KeyValidator.isKeyEnter(e)) _chooseCurrent(day_sel);
        }, 'keyup');
    }
    for (var i = 0; i < 42; i++) {
      final diff = i - (firstDay - Calendar.offset());
      final x =
          (diff > 0 && diff <= month_days[_viewDate.month - 1]) ? diff : null;
      final mod = i % 7;
      if (i != 0 && mod == 0) k++;
      final cell = domTbody.dom.rows[k].cells[mod],
          span = new CLElement(cell.children.first);
      span
        ..removeActionsAll()
        ..removeClass('active today')
        ..setText('');
      if (x is int) {
        span.setText(x.toString());

        final filter2359 = () async =>
            filter(new DateTime(_viewDate.year, _viewDate.month, x, 23, 59));
        final filter0 = () async =>
            filter(new DateTime(_viewDate.year, _viewDate.month, x, 0, 0));

        if (filter == null ||
            (time
                ? (await filter2359() || await filter0())
                : await filter0())) {
          span
            ..addClass('active')
            ..addAction((e) {
              _setDate(new DateTime(
                  _viewDate.year,
                  _viewDate.month,
                  x,
                  time ? (timeField?.getHours() ?? 0) : 0,
                  time ? (timeField?.getMinutes() ?? 0) : 0));
              clicked(this, span);
            });
        }

        if (x == today) span.addClass('today');
        if (x == day_sel) clicked(this, span);
      }
    }
  }
}
