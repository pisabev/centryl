part of ui;

class Audit {
  cl_app.Application ap;
  cl_app.WinMeta meta = new cl_app.WinMeta()
    ..title = intl.Changelog()
    ..icon = cl.Icon.format_list_bulleted
    ..width = 700
    ..height = 700
    ..type = 'bound';

  late cl_app.WinApp wapi;

  late cl_action.Menu menuBottom;
  late ItemBuilderContainerBase layout;
  late cl_gui.Accordion accordion;
  late Map<String, String> fieldDecorators;
  late Map<String, String> tableDecorators;
  late Map<String, FutureOr<String> Function(dynamic)> valueDecorators;

  dynamic choice;

  Audit(this.ap, List<AuditDTO> dtos,
      {Map<String, String>? fieldDecorators,
      Map<String, String>? tableDecorators,
      Map<String, FutureOr<String> Function(dynamic)>? valueDecorators}) {
    this.fieldDecorators = fieldDecorators ?? {};
    this.tableDecorators = tableDecorators ?? {};
    this.valueDecorators = valueDecorators ?? {};
    winApi();
    initHTML();
    setUI();
    ap.loadExecute(
        wapi.win.getContent(),
        () => Future.wait(dtos.map(
                    (d) => ap.serverCall<List>(Routes.audit.reverse([]), d)))
                .then((value) {
              final l = <entity.Audit>[];
              value.forEach((data) {
                final i = data
                    ?.map<entity.Audit>((e) => new entity.Audit()..init(e))
                    .toList();
                if (i != null) l.addAll(i);
              });
              render(l);
            }));
  }

  Future<void> render(List<entity.Audit> col) async {
    accordion = new cl_gui.Accordion();
    layout.contInner.append(accordion);
    for (final r in col) {
      late String icon;
      if (r.operation == 'INSERT')
        icon = cl.Icon.add;
      else if (r.operation == 'UPDATE')
        icon = cl.Icon.edit;
      else if (r.operation == 'DELETE') icon = cl.Icon.delete;

      r.before?.remove('modified_by');
      final who = r.after?.remove('modified_by');

      final title = new cl.CLElement(new SpanElement())
        ..setStyle({'display': 'flex', 'align-items': 'center'})
        ..append(new cl.Icon(icon).dom
          ..style.height = '2.5rem'
          ..style.width = '2.5rem')
        ..append(new SpanElement()
          ..text = cl_util.Calendar.stringWithTimeFull(r.audit_ts?.toLocal()));

      if (who != null) {
        title
          ..append(new cl.Icon(cl.Icon.person).dom
            ..style.height = '2.5rem'
            ..style.width = '2.5rem')
          ..append(new SpanElement()
            ..text = await _decorateValue('modified_by', who));
      }

      title.append(new SpanElement()
        ..text = _decorateTable(r.table_name!)
        ..style.marginLeft = 'auto');

      final n = accordion.createNode(title);

      final grid = new cl_form.GridList();
      final col1 = new cl_form.GridColumn('field')..title = 'Поле';
      final col2 = new cl_form.GridColumn('before')..title = 'Преди';
      final col3 = new cl_form.GridColumn('after')..title = 'След';

      grid.initGridHeader([col1, col2, col3]);

      n.contentDom.append(grid);

      if (r.before != null || r.after != null) {
        final keys = <dynamic>{};
        if (r.before != null) keys.addAll(r.before!.keys);
        if (r.after != null) keys.addAll(r.after!.keys);
        for (final key in keys) {
          dynamic valueBefore;
          dynamic valueAfter;
          if (r.before != null) valueBefore = r.before![key];
          if (r.after != null) valueAfter = r.after![key];
          if (valueBefore != valueAfter)
            grid.rowAdd({
              'field': _decorateField(key),
              'before': await _decorateValue(key, valueBefore),
              'after': await _decorateValue(key, valueAfter)
            });
        }
      }
    }
  }

  FutureOr<String> _decorateValue(String key, dynamic value) {
    if (valueDecorators.containsKey(key)) return valueDecorators[key]!(value);
    return value?.toString() ?? '';
  }

  String _decorateField(String key) {
    if (fieldDecorators.containsKey(key)) return fieldDecorators[key]!;
    return key;
  }

  String _decorateTable(String key) {
    if (tableDecorators.containsKey(key)) return tableDecorators[key]!;
    return key;
  }

  void winApi() {
    wapi = new cl_app.WinApp(ap)..load(meta, this);
  }

  void initHTML() {
    layout = new ItemBuilderContainerBase();
    menuBottom = new cl_action.Menu(layout.contMenu);
    wapi.win.getContent().append(layout, scrollable: true);
    wapi.render();
  }

  void setUI() {}
}
