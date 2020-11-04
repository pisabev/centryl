part of layout;

/// +-----------------+-----------------------+
/// |contLeft (fixed) | contRight (auto)      |
/// |                 |                       |
/// |                 |                       |
/// |                 |                       |
/// |                 |<- slider              |
/// |                 |                       |
/// |                 |                       |
/// |                 |                       |
/// +-----------------+-----------------------+
///
class LayoutContainer4 extends Container {
  Container contLeft, contRight;

  LayoutContainer4({Dimension leftWidth}) : super() {
    leftWidth = leftWidth ?? new Dimension.px(400);
    contLeft = new Container()..setWidth(leftWidth);
    contRight = new Container()..auto = true;

    addCol(contLeft);
    addSlider();
    addCol(contRight);
  }
}
