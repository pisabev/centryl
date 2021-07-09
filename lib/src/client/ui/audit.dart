part of ui;

class Audit {
  cl_app.Application ap;
  cl_app.WinMeta meta = new cl_app.WinMeta()
    ..title = intl.Changelog()
    ..icon = cl.Icon.format_list_bulleted
    ..width = 600
    ..height = 600
    ..type = 'bound';

  late cl_app.WinApp wapi;

  late cl_action.Menu menuBottom;
  late ItemBuilderContainerBase layout;

  dynamic choice;

  Audit(this.ap, AuditDTO dto) {
    winApi();
    initHTML();
    setUI();
    ap
        .serverCall(Routes.audit.reverse([]), dto, wapi.win.getContent())
        .then((value) {
      print(value);
    });
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
