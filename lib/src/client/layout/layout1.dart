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
  TabContainer contBottom;
  Container contMenu;

  LayoutContainer1() : super() {
    contBottom = new TabContainer()..auto = true;
    contMenu = new Container();

    addRow(contBottom);
    addRow(contMenu);
  }
}
