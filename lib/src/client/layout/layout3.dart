part of layout;

/// +------------------------------------------+
/// |contMenu (fixed)                          |
/// |                                          |
/// |------------------------------------------+
/// |contMiddle (auto)                         |
/// |                                          |
/// |                                          |
/// |                                          |
/// +------------------------------------------+
/// |contBottom (fixed)                        |
/// |                                          |
/// +------------------------------------------+
///
class LayoutContainer3 extends Container {
  Container contMenu, contMiddle, contBottom;

  LayoutContainer3() : super() {
    contMenu = new Container();
    contMiddle = new Container()..auto = true;
    contBottom = new Container();

    addRow(contMenu);
    addRow(contMiddle);
    addRow(contBottom);
  }
}
