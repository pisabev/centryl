part of utils;

class CLscroll {
  Element el;
  Element trackX, trackY;
  Element scrollbarX, scrollbarY;
  Element contentEl;
  Element containerEl;
  Timer flashTimeout;
  Map<String, num> dragOffset = {'x': 0, 'y': 0};
  Map<String, bool> isVisible = {'x': true, 'y': true};
  MutationObserver observer;
  String currentAxis;
  bool enabled = true;
  bool autoHide = true;
  bool forceEnabled = false;
  num scrollbarMinSize = 40;
  num _cor = 1;

  StreamSubscription _el_enter;
  StreamSubscription _doc_mousemove;
  StreamSubscription _doc_mouseup;
  StreamSubscription _scrbX_mousemove;
  StreamSubscription _scrbY_mousemove;
  StreamSubscription _scr_content;

  //Function recalculate;

  Map classNames = {
    'content': 'content',
    'container': 'container',
    'track': 'track'
  };

  CLscroll([this.el]) {
    el.classes.add('ui-scroll');
    //recalculate = debounce(_recalculate, new Duration(milliseconds: 100));
    init();
  }

  //recalculate () => debounce(_recalculate, new Duration(milliseconds: 100));

  void init() {
    // If scrollbar is a floating scrollbar, disable the plugin
    enabled = getScrollbarWidth() != 0;

    if (!enabled && !forceEnabled) {
      el.style.overflow = 'auto';
      //return;
    }

    initDOM();

    // Calculate content size
    //recalculate();

    if (!autoHide) {
      showScrollbar('x');
      showScrollbar('y');
    }

    initListeners();
  }

  void initDOM() {
    if (el.querySelectorAll('.${classNames['content']}').isNotEmpty) return;

    // Prepare DOM
    containerEl = document.createElement('div');
    //contentEl = document.createElement('div');
    contentEl = el.children.first;

    containerEl.classes.add(classNames['container']);
    //contentEl.classes.add(classNames['content']);

    //while (el.hasChildNodes()) contentEl.append(el.firstChild);

    final _scrollbarWidth = getScrollbarWidth();
    containerEl.style
      ..overflow = 'scroll'
      ..marginRight = '${-_scrollbarWidth}px'
      ..marginBottom = '${-_scrollbarWidth}px';
    containerEl.append(contentEl);
    el.append(containerEl);

    final track = document.createElement('div');
    final scrollbar = document.createElement('div');

    track.classes.add(classNames['track']);
    track.append(scrollbar);

    trackX = track.clone(true);
    trackX.classes.add('horizontal');
    scrollbarX = trackX.firstChild;

    trackY = track.clone(true);
    trackY.classes.add('vertical');
    scrollbarY = trackY.firstChild;

    el
      ..insertBefore(trackX, el.firstChild)
      ..insertBefore(trackY, el.firstChild);
  }

  void initListeners() {
    // Event listeners
    if (autoHide) _el_enter = el.onMouseEnter.listen(flashScrollbar);

    scrollbarX
      ..onFocus.listen((e) => e.stopPropagation())
      ..onClick.listen((e) => e.stopPropagation());
    scrollbarY
      ..onFocus.listen((e) => e.stopPropagation())
      ..onClick.listen((e) => e.stopPropagation());

    _scrbX_mousemove = scrollbarX.onMouseDown.listen((e) => startDrag(e, 'x'));
    _scrbY_mousemove = scrollbarY.onMouseDown.listen((e) => startDrag(e, 'y'));
    scrollbarX.onMouseOver.listen((e) => scrollbarX.classes.add('over'));
    scrollbarY.onMouseOver.listen((e) => scrollbarY.classes.add('over'));

    _scr_content = containerEl.onScroll.listen(onScroll);

    // MutationObserver is IE11+
    /*observer = new MutationObserver(
        (List<MutationRecord> mutations, MutationObserver obs) {
      mutations.forEach((mutation) {
        if (mutation.target == el || mutation.addedNodes.length > 0)
          recalculate();
      });
    });
    observer.observe(el,
      attributes: true, childList: true, characterData: true, subtree: true);*/
  }

  void removeListeners() {
    // Event listeners
    if (autoHide) _el_enter.cancel();

    _scrbX_mousemove.cancel();
    _scrbY_mousemove.cancel();

    _scr_content.cancel();

    if (observer != null) observer.disconnect();
  }

  /// Start scrollbar handle drag
  void startDrag(MouseEvent e, [String axis = 'y']) {
    // Preventing the event's default action stops text being
    // selectable during the drag.
    e
      ..preventDefault()
      ..stopPropagation();

    final scrollbar = axis == 'y' ? scrollbarY : scrollbarX;
    // Measure how far the user's mouse is from the top of the scrollbar
    // drag handle.
    final eventOffset = axis == 'y' ? e.page.y : e.page.x;

    dragOffset[axis] = eventOffset - offset(scrollbar, axis);
    currentAxis = axis;

    _doc_mousemove = document.onMouseMove.listen(drag);
    _doc_mouseup = document.onMouseUp.listen(endDrag);
  }

  /// Drag scrollbar handle
  void drag(MouseEvent e) {
    e
      ..preventDefault()
      ..stopPropagation();

    final eventOffset = currentAxis == 'y' ? e.page.y : e.page.x;
    final track = currentAxis == 'y' ? trackY : trackX;

    // Calculate how far the user's mouse is from the top/left of the scrollbar (minus the dragOffset).
    final dragPos =
        eventOffset - offset(track, currentAxis) - dragOffset[currentAxis];

    // Convert the mouse position into a percentage of the scrollbar height/width.
    final dragPerc = dragPos / scrollSizeFix(track, currentAxis);

    // Scroll the content by the same percentage.
    final scrollPos = dragPerc * scrollSize(contentEl, currentAxis) * _cor;
    if (scrollPos.isFinite)
      scrollOffsetSet(containerEl, currentAxis, scrollPos.floor());
  }

  /// End scroll handle drag
  void endDrag(MouseEvent e) {
    e
      ..preventDefault()
      ..stopPropagation();
    _doc_mousemove.cancel();
    _doc_mouseup.cancel();
  }

  num offset(Element el, String currentAxis) => (currentAxis == 'y')
      ? el.getBoundingClientRect().top
      : el.getBoundingClientRect().left;

  void scrollOffsetSet(Element el, String currentAxis, num value) {
    if (currentAxis == 'y')
      el.scrollTop = value;
    else
      el.scrollLeft = value;
  }

  num scrollOffsetGet(Element el, String currentAxis) =>
      (currentAxis == 'y') ? el.scrollTop : el.scrollLeft;

  num scrollSize(Element el, String currentAxis) =>
      (currentAxis == 'y') ? el.scrollHeight : el.scrollWidth;

  /// Why does not work with scrollSize method ?
  num scrollSizeFix(Element el, String currentAxis) =>
      (currentAxis == 'y') ? el.clientHeight : el.clientWidth;

  /// Resize scrollbar
  void resizeScrollbar([String axis = 'y']) {
    Element track;
    Element scrollbar;

    if (axis == 'x') {
      track = trackX;
      scrollbar = scrollbarX;
    } else {
      // 'y'
      track = trackY;
      scrollbar = scrollbarY;
    }

    final contentSize = scrollSize(contentEl, axis);
    if (contentSize == 0) {
      isVisible[axis] = false;
      return;
    }
    // Either scrollTop() or scrollLeft().
    final scrollOffset = scrollOffsetGet(containerEl, axis);
    final scrollbarSize = scrollSizeFix(track, axis);
    var handleSize = scrollbarSize * (scrollbarSize / contentSize);
    if (handleSize < scrollbarMinSize) {
      _cor = 1 + (scrollbarMinSize - handleSize) / scrollbarSize;
      handleSize = scrollbarMinSize;
    }
    final scrollPercent = scrollOffset / (contentSize - scrollbarSize);
    // Calculate new height/position of drag handle.
    // Offset of 2px allows for a small top/bottom or left/right margin
    // around handle.
    final handleOffset = (scrollbarSize - handleSize) * scrollPercent;

    // Set isVisible to false if scrollbar is not necessary
    // (content is shorter than wrapper)
    isVisible[axis] = scrollbarSize < contentSize;

    if (isVisible[axis]) {
      track.style.visibility = 'visible';

      if (axis == 'x') {
        scrollbar.style
          ..left = '${handleOffset}px'
          ..width = '${handleSize}px';
      } else {
        scrollbar.style
          ..top = '${handleOffset}px'
          ..height = '${handleSize}px';
      }
    } else {
      track.style.visibility = 'hidden';
    }
  }

  /// Resize content element
  void resizeScrollContent() {
    final _scrollbarWidth = getScrollbarWidth();
    containerEl.style
      ..marginRight = ''
      ..marginBottom = '';
    if (contentEl.scrollHeight > el.clientHeight)
      containerEl.style.marginRight = '${-_scrollbarWidth}px';
    if (contentEl.scrollWidth > el.clientWidth)
      containerEl.style.marginBottom = '${-_scrollbarWidth}px';
  }

  /// On scroll event handling
  void onScroll([_]) {
    flashScrollbar();
  }

  /// Flash scrollbar visibility
  void flashScrollbar([_]) {
    if (!enabled) return;
    resizeScrollbar('x');
    resizeScrollbar('y');
    showScrollbar('x');
    showScrollbar('y');
  }

  /// Show scrollbar
  void showScrollbar([String axis = 'y']) {
    if (!isVisible[axis]) return;

    if (axis == 'x')
      scrollbarX.classes.add('visible');
    else
      scrollbarY.classes.add('visible');

    if (!autoHide) return;

    if (flashTimeout != null) flashTimeout.cancel();

    flashTimeout = new Timer(const Duration(milliseconds: 1000), hideScrollbar);
  }

  /// Hide Scrollbar
  void hideScrollbar() {
    scrollbarX.classes.remove('visible');
    scrollbarY.classes.remove('visible');
    scrollbarX.classes.remove('over');
    scrollbarY.classes.remove('over');

    if (flashTimeout != null) {
      flashTimeout.cancel();
      flashTimeout = null;
    }
  }

  void scrollTo(int to) => containerEl.scrollTop = to;

  void scrollToTop() => containerEl.scrollTop = 0;

  void scrollToBottom() => containerEl.scrollTop =
      containerEl.scrollHeight - containerEl.clientHeight;

  bool isScrolledToBottom() =>
      containerEl.scrollTop ==
      containerEl.scrollHeight - containerEl.clientHeight;

  bool isScrolledToTop() => containerEl.scrollTop == 0;

  /// Recalculate scrollbar
//void _recalculate() {
/*if (!enabled) return;

    resizeScrollContent();
    resizeScrollbar('x');
    resizeScrollbar('y');*/
//}
}
