part of utils;

class UISlider {
  bool autoWidth = true;
  late Boxing boxing;
  bool appendDom;
  CLElementBase parent;
  CLElementBase el;

  UISlider(this.el, this.parent,
      {this.appendDom = false, List<BoxingPosition>? positions}) {
    el.addClass('ui-slide');
    boxing = new Boxing(positions);
  }

  void show([CLElementBase? relativeTo, String? zIndex]) {
    final body = (zIndex != null)
        ? (document.getElementsByClassName('ui-desktop').first as Element)
            .getBoundingClientRect()
        : document.body!.getBoundingClientRect();

    relativeTo ??= parent;
    document.body!.append(el.dom);

    final ref = relativeTo.getMutableRectangle();
    if (autoWidth) el.setStyle({'width': '${ref.width}px'});
    el.show();

    var r = el.getRectangle();
    Function? func = boxing.runTest(ref, r, body);
    if (func == null) {
      // TODO check if element's position is nearer to the bottom of the screen
      el.setStyle({
        'max-height':
            '${r.height - ref.height - (ref.top + r.height - body.height)}px'
      });
      r = el.getRectangle();
      func = boxing.runTest(ref, r, body);
    }

    // Execute changes of ref's bounding box
    if (func != null) {
      if (boxing.topLeft != null || boxing.topRight != null) el.addClass('top');
      func();
    }

    el.setStyle({'left': '${ref.left}px', 'top': '${ref.top}px'});
    if (zIndex != null) el.setStyle({'z-index': zIndex});
    new Timer(const Duration(milliseconds: 0), () => el.addClass('show'));
  }

  void hide() {
    el
      ..hide()
      ..setStyle({'left': 'initial', 'top': 'initial'})
      ..removeClass('show'); //..removeClass('top');
    if (!appendDom)
      parent.append(el);
    else
      el.remove();
  }
}
