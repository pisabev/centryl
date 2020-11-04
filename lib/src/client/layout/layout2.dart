part of layout;

/// +------------------------------------------+
/// |contMenu (fixed)                          |
/// |                                          |
/// |--------------------+---------------------+
/// |contTopLeft (fixed) |contTopRight (fixed) |
/// |                    |                     |
/// |                    |                     |
/// |                    |                     |
/// +--------------------+---------------------+
/// |contBottom (auto)                         |
/// |                                          |
/// |                                          |
/// |                                          |
/// +------------------------------------------+
///
class LayoutContainer2 extends Container {
  Container contMenu, contTop, contTopLeft, contTopRight;
  TabContainer contBottom;

  LayoutContainer2() : super() {
    contMenu = new Container();
    contTop = new Container();
    contBottom = new TabContainer()..auto = true;

    contTopLeft = new Container()..auto = true;
    contTopRight = new Container()..auto = true;

    contTop..addCol(contTopLeft)..addCol(contTopRight);

    addRow(contMenu);
    addRow(contTop);
    addRow(contBottom);
  }
}
