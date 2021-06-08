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
  late Container contMenu, contTop, contTopLeft, contTopRight;
  late TabContainer contBottom;

  LayoutContainer2() : super() {
    contTop = new Container();
    contBottom = new TabContainer()..auto = true;
    contMenu = new Container();

    contTopLeft = new Container()..auto = true;
    contTopRight = new Container()..auto = true;

    contTop..addCol(contTopLeft)..addCol(contTopRight);

    addRow(contTop);
    addRow(contBottom);
    addRow(contMenu);
  }
}
