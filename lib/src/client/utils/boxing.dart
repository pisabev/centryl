part of utils;

enum BoxingPosition {
  bottomLeft,
  topLeft,
  bottomRight,
  topRight,
  leftTop,
  leftBottom,
  rightTop,
  rightBottom,
  finalPosition
}

class Boxing {
  Function bottomLeft;
  Function bottomRight;
  Function topLeft;
  Function topRight;
  Function leftTop;
  Function leftBottom;
  Function rightTop;
  Function rightBottom;
  Function finalPosition;
  int offset;
  bool verticalAlignContent;

  List<BoxingPosition> order;

  Boxing(this.order, {this.offset = 0, this.verticalAlignContent = false}) {
    order ??= [
      BoxingPosition.bottomLeft,
      BoxingPosition.topLeft,
      BoxingPosition.bottomRight,
      BoxingPosition.topRight,
    ];
  }

  Function runTest(
      math.MutableRectangle ref, math.Rectangle el, math.Rectangle body) {
    bottomLeft = null;
    bottomRight = null;
    topLeft = null;
    topRight = null;
    leftTop = null;
    leftBottom = null;
    rightTop = null;
    rightBottom = null;
    Function found;
    for (final o in order) {
      if (found != null) break;
      switch (o) {
        case BoxingPosition.bottomLeft:
          if (tryBottomLeft(ref, el, body)) found = bottomLeft;
          break;
        case BoxingPosition.bottomRight:
          if (tryBottomRight(ref, el, body)) found = bottomRight;
          break;
        case BoxingPosition.topLeft:
          if (tryTopLeft(ref, el, body)) found = topLeft;
          break;
        case BoxingPosition.topRight:
          if (tryTopRight(ref, el, body)) found = topRight;
          break;
        case BoxingPosition.leftTop:
          if (tryLeftTop(ref, el, body)) found = leftTop;
          break;
        case BoxingPosition.leftBottom:
          if (tryLeftBottom(ref, el, body)) found = leftBottom;
          break;
        case BoxingPosition.rightTop:
          if (tryRightTop(ref, el, body)) found = rightTop;
          break;
        case BoxingPosition.rightBottom:
          if (tryRightBottom(ref, el, body)) found = rightBottom;
          break;
        case BoxingPosition.finalPosition:
          if (tryFinalPosition(ref, el, body)) found = finalPosition;
          break;
      }
    }
    return found;
  }

  ///
  /// --------
  /// |      |
  /// |      |
  /// --------
  /// □□□
  bool tryBottomLeft(
      math.MutableRectangle ref, math.Rectangle el, math.Rectangle body) {
    final testRect = new Rectangle(
        ref.left, ref.top + offset, el.width, ref.height + el.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      bottomLeft = () => ref..top += ref.height + offset;
    }
    return res;
  }

  ///
  /// --------
  /// |      |
  /// |      |
  /// --------
  ///      □□□
  bool tryBottomRight(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    final testRect = new Rectangle(ref.left + ref.width - r.width,
        ref.top + offset, r.width, ref.height + r.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      bottomRight = () => ref
        ..top += ref.height + offset
        ..left = ref.left + ref.width - r.width;
    }
    return res;
  }

  /// □□□
  /// --------
  /// |      |
  /// |      |
  /// --------
  bool tryTopLeft(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    final testRect = new Rectangle(ref.left, ref.top - (r.height + offset),
        r.width, ref.height + r.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      topLeft = () => ref..top -= r.height + offset;
    }
    return res;
  }

  ///      □□□
  /// --------
  /// |      |
  /// |      |
  /// --------
  bool tryTopRight(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    final testRect = new Rectangle(ref.left + ref.width - r.width,
        ref.top - (r.height + offset), r.width, ref.height + r.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      topRight = () => ref
        ..top -= r.height + offset
        ..left = ref.left + ref.width - r.width;
    }
    return res;
  }

  /// □
  /// □
  /// □ --------
  /// □ |      |
  /// □ |      |
  /// □ --------
  bool tryLeftTop(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    final testRect = new Rectangle(ref.left - r.width - offset,
        ref.top - (r.height - ref.height), r.width, ref.height + r.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      leftTop = () => ref
        ..left = ref.left - r.width - offset
        ..top -= r.height - ref.height;
    }
    return res;
  }

  ///
  /// □ --------
  /// □ |      |
  /// □ |      |
  /// □ --------
  /// □
  /// □
  bool tryLeftBottom(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    final testRect = new Rectangle(
        ref.left - r.width - offset,
        verticalAlignContent ? (ref.top - r.height / 2) : ref.top,
        r.width,
        ref.height + r.height);
    final c = new DivElement()..style.background = 'red';
    final d = new CLElement(c)..setRectangle(testRect);
    document.body.append(d.dom);
    final res = body.containsRectangle(testRect);
    if (res) {
      leftBottom = () => ref
        ..left = ref.left - r.width - offset
        ..top = verticalAlignContent ? (ref.top - r.height / 2) : ref.top;
    }
    return res;
  }

  ///          □
  ///          □
  /// -------- □
  /// |      | □
  /// |      | □
  /// -------- □
  bool tryRightTop(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    final testRect = new Rectangle(ref.left - ref.width + offset,
        ref.top - (r.height - ref.height), r.width, ref.height + r.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      rightTop = () => ref
        ..left = ref.left + ref.width + offset
        ..top -= r.height - ref.height;
    }
    return res;
  }

  ///
  /// -------- □
  /// |      | □
  /// |      | □
  /// -------- □
  ///          □
  ///          □
  bool tryRightBottom(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    final testRect = new Rectangle(
        ref.left - ref.width + offset,
        verticalAlignContent ? (ref.top - r.height / 2) : ref.top,
        r.width,
        ref.height + r.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      rightBottom = () => ref
        ..left = ref.left + ref.width + offset
        ..top = verticalAlignContent ? (ref.top - r.height / 2) : ref.top;
    }
    return res;
  }

  bool tryFinalPosition(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    if (ref.left + r.width >= document.body.clientWidth) {
      finalPosition = () => ref
        ..left = ref.left - r.width - offset
        ..top = offset; //maybe something else
    } else {
      finalPosition = () => ref
        ..left = ref.left + ref.width + offset
        ..top = offset;
    }
    return true;
  }
}