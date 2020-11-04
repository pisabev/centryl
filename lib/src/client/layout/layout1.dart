part of layout;

/// +---------------------------------+
/// |contMenu (fixed)                 |
/// |                                 |
/// |---------------------------------+
/// |contBottom (auto)                |
/// |                                 |
/// |                                 |
/// |                                 |
/// |                                 |
/// +---------------------------------+
///
class LayoutContainer1 extends Container {
  Container contMenu;
  TabContainer contBottom;

  LayoutContainer1() : super() {
    contMenu = new Container();
    contBottom = new TabContainer()..auto = true;

    addRow(contMenu);
    addRow(contBottom);
  }
}
