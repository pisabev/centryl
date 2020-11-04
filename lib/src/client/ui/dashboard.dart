part of ui;

abstract class DashBoard implements cl_app.Item {
  cl_app.Application ap;
  cl_app.WinApp wapi;
  cl_app.WinMeta meta;
  cl_layout.LayoutContainer1 layout;
  cl_form.Form form;
  cl_action.Menu apply;
  @Deprecated('Use WinMeta instead')
  Map w;
  dynamic contr;

  DashBoard(this.ap) {
    contr = contr.reverse([]);
    wapi = new cl_app.WinApp(ap);
    if (w != null) {
      wapi.load(
          new cl_app.WinMeta()
            ..title = w['title']
            ..width = w['width']
            ..height = w['height']
            ..icon = w['icon'],
          this);
    } else {
      wapi.load(meta, this);
    }
    layout = new cl_layout.LayoutContainer1();
    wapi.win.getContent().append(layout, scrollable: true);
  }

  Future getStats() => ap
      .serverCall(contr, form.getValue(), layout)
      .then(handleStatisticsResult);

  dynamic handleStatisticsResult(dynamic data);
}
