part of app;

typedef SearchF = void Function();

class Notify {
  Application ap;

  CLElement outer, inner;

  SpanElement count;

  List<NotificationMessage> notifications = [];

  int unread = 0;

  bool visible = false;

  StreamSubscription down;

  List<DateTime> Function() range_get =
      () => utils.Calendar.getWeeksBackRange(1);
  Future<void> Function(NotificationMessage) persist = (m) async {};
  Future<List> Function(dynamic, DateTime, DateTime) load_archive =
      (v1, d1, d2) async => [];
  Future<List> Function(dynamic) load_recent = (v) async => null;
  Future<int> Function(dynamic) load_unread = (v) async => null;
  Future<void> Function(NotificationMessage) mark_read = (v) async {};
  Future<void> Function(NotificationMessage) mark_unread = (v) async {};
  Function remove;

  Timer timer_remove;
  Duration autoclose;
  Timer timer_remove_auto;

  action.Button bottom_dom;
  SearchF searchNotify = () {};

  Notify(this.ap);

  void init() {
    if (load_unread == null) return;
    refreshUnread();
  }

  void refreshUnread() {
    load_unread(null).then((res) {
      unread = res ?? 0;
      _showUnread();
    });
  }

  action.Button messageDom() => bottom_dom = new action.Button()
    ..setIcon(Icon.notifications)
    ..addAction((e) {
      e.stopPropagation();
      renderAll();
    })
    ..setTip(intl.Notifications(), 'bottom')
    ..append(count = new SpanElement()..classes.add('note'));

  void _addMessage(NotificationMessage el,
      [bool animate = false, CLElement append]) {
    append ??= inner;
    final cont = new Container()..setClass('message');
    if (el.priority.isNotEmpty) cont.addClass(el.priority);

    if (el.icon != null) {
      cont
        ..addClass('has-icon')
        ..append(new Icon(el.icon).dom);
    }
    CLElement dateCont;
    cont.append(dateCont = new CLElement(new DivElement())
      ..addClass('date')
      ..append(new Icon(Icon.today).dom)
      ..append(new SpanElement()
        ..text = utils.Calendar.stringWithTimeFull(el.date)));

    action.Button visible;
    void markRead(Event e) {
      e.stopPropagation();
      if (el.read) {
        mark_unread(el);
        el.read = false;
        cont.removeClass('read');
        visible.removeClass('light');
        unread++;
        _showUnread();
      } else {
        mark_read(el);
        el.read = true;
        cont.addClass('read');
        visible.addClass('light');
        unread--;
        _showUnread();
      }
    }

    if (el.id != null) {
      dateCont
        ..append(visible = new action.Button()
          ..setIcon(Icon.visibility)
          ..setStyle({'margin-left': 'auto'})
          ..addAction(markRead))
        ..append(new action.Button()
          ..setIcon(Icon.delete)
          ..setTip(intl.Delete(), 'top')
          ..addAction((e) {
            e.stopPropagation();
            cont.remove();
            if (!el.read) {
              unread--;
              _showUnread();
            }
            if (remove is Function) remove(el);
          }));

      cont.addAction((e) {
        if (!el.read) markRead(e);
      });

      if (el.read) {
        visible.addClass('light');
        cont.addClass('read');
      }
    }

    const int maxLen = 90;
    final o = new forms.Text();
    if (el.textFunction != null) {
      el.textFunction(o);
    } else {
      String text = el.text != null
          ? el.text
              .replaceAll(new RegExp(r'\s+'), ' ')
              .replaceAll(new RegExp(r'\r?\n|\r'), '')
          : '';
      if (text.length > maxLen) {
        text = text.substring(0, maxLen);
        o
          ..setText('$text ...')
          ..dom.title = el.text;
      } else
        o.setText(text);
    }

    if (el.action is Function)
      cont
        ..addClass('action')
        ..addAction((_) => el.action());
    cont.append(o);

    if (animate) {
      append.prepend(cont);
      cont.addClass('new');
      new Timer(
          const Duration(milliseconds: 100 * 1), () => cont.addClass('show'));
    } else {
      append.append(cont);
      cont.addClass('show');
    }
  }

  void _renderAttention(NotificationMessage message) {
    if (visible) return _addMessage(message, true);
    if (timer_remove != null) timer_remove.cancel();
    _createFlyingContainer();
    new Timer(const Duration(milliseconds: 10), () => outer.addClass('show'));
    _addMessage(message, false);
    down?.cancel();
    down = document.onMouseDown.listen((e) => _close());
    if (autoclose != null) timer_remove_auto = new Timer(autoclose, _close);
  }

  void _createFlyingContainer() {
    outer?.remove();
    outer = new CLElement(new DivElement())..addClass('ui-notify');
    inner = new CLElement(new DivElement())..appendTo(outer);
    ap.page.append(outer);
    outer
      ..addAction((e) => e.stopPropagation(), 'mousedown')
      ..show();
  }

  void renderAll() {
    ap.fieldRight.removeChilds();

    visible = ap.toggleAside(this);
    if (!visible) return;

    forms.InputDateRange date;
    final titleDom = new Container(new HeadingElement.h2())
      ..append(new Icon(Icon.notifications).dom)
      ..append(date = new forms.InputDateRange())
      ..append(action.Button()
        ..setIcon(Icon.chevron_left)
        ..addClass('light')
        ..addAction((e) {
          final dates = date.getValue_();
          date.setValue([
            dates.first.subtract(dates.last.difference(dates.first)),
            dates.first
          ]);
        }))
      ..append(action.Button()
        ..setIcon(Icon.chevron_right)
        ..addClass('light')
        ..addAction((e) {
          final dates = date.getValue_();
          date.setValue(
              [dates.last, dates.last.add(dates.last.difference(dates.first))]);
        }))
      ..append(action.Button()
        ..setIcon(Icon.search)
        ..setStyle({'margin-left': 'auto'})
        ..setTip(intl.See_all())
        ..addClass('light')
        ..addAction((_) => searchNotify()));

    final outer = new Container()
      ..addClass('ui-notify-container')
      ..addAction((e) => e.stopPropagation(), 'mousedown');

    final cont2 = new Container()..addClass('ui-message-box-current');
    inner = new Container()..addClass('ui-message-box');
    cont2.append(inner, scrollable: true);

    final cont1 = new Container()..auto = true;
    final cont = new Container()..addClass('ui-message-box');
    cont1.append(cont, scrollable: true);

    ap.fieldRight.append(outer);
    outer..addRow(titleDom)..addRow(cont2)..addRow(cont1);

    final range = range_get();
    range.last = range.last.add(const Duration(days: 1));
    date
      ..onValueChanged.listen((_) {
        final start = date.getValue_().first;
        final end = date.getValue_().last;
        if (start == null || end == null) return;
        load_archive(outer, start, end).then((data) {
          inner.removeChilds();
          cont.removeChilds();
          if (data is List)
            data.forEach((r) {
              _addMessage(new NotificationMessage.fromMap(r), false, cont);
              if (data.isEmpty)
                _addMessage(
                    new NotificationMessage('')..text = intl.No_new_messages(),
                    false,
                    cont);
            });

          refreshUnread();
        });
      })
      ..setValue(range);
  }

  void _close() {
    outer.removeClass('show');
    timer_remove_auto?.cancel();
    timer_remove =
        new Timer(const Duration(milliseconds: 500), () => outer.remove());
    down.cancel();
  }

  void add(NotificationMessage n) {
    if (n.id == null && n.persist) persist(n);
    if (n.persist) unread++;

    _renderAttention(n);
    notifications.add(n);
    _showUnread();
    _beep();
    try {
      Notification.requestPermission().then((permission) {
        if (permission == 'granted' && document.hidden)
          new Notification(intl.Notifications(),
              body: n.text, icon: '${ap.baseurl}images/logo.png');
      });
    } catch (e) {}
  }

  void _showUnread() {
    if (unread > 0) {
      count?.style?.display = 'block';
      count?.text = '${unread > 99 ? '99+' : unread}';
    } else
      count?.style?.display = 'none';
  }

  void _beep() {
    bottom_dom.append(new AudioElement()
      ..src = '${ap.baseurl}packages/centryl/sound/chime_bell_ding.wav'
      ..play().catchError((e) => null));
  }
}
