part of forms;

class GridListContainer extends Container {
  late GridList gridList;

  late Container contHead;
  late Container contBody;
  late Container contFoot;

  html.Element? _focusEl;
  var _scrollTop = 0;
  late bool fixedFooter;

  GridListContainer(this.gridList,
      {bool auto = false, this.fixedFooter = false})
      : super() {
    addClass('ui-grid-list-container');
    contHead = new Container()..setStyle({'width': '0'});
    contBody = new Container()..auto = auto;
    addRow(contHead);
    addRow(contBody);
    if (fixedFooter) {
      contFoot = new Container()..setStyle({'width': '0'});
      addRow(contFoot);
    }
    gridList.addHookRender((_) {
      initLayout();
      return true;
    });
  }

  void fixTable() {
    if (gridList.tbody.dom.children.isEmpty) {
      if (_focusEl != null) _focusEl!.focus();
      return;
    }

    final width = gridList.dom.offsetWidth;

    late CLElement tableInF;
    if (fixedFooter) {
      tableInF = new CLElement(new html.TableElement())
        ..setClass(gridList.dom.classes.join(' '));
      gridList.renderer.calcTfootWidths();
      contFoot
        ..removeChilds()
        ..append(new CLElement(new html.DivElement())
          ..append(tableInF)
          ..setStyle({'min-width': '100%'}));
      tableInF.append(gridList.tfoot);
      gridList.renderer.setTfootWidths();
      tableInF.setWidth(new Dimension.px(width));
    }

    final tableInH = new CLElement(new html.TableElement())
      ..setClass(gridList.dom.classes.join(' '))
      ..addClass('shadow');

    gridList.renderer.calcTheadWidths();
    gridList.renderer.calcTbodyWidths();

    contHead
      ..removeChilds()
      ..append(new CLElement(new html.DivElement())
        ..append(tableInH)
        ..setStyle({'min-width': '100%'}));
    tableInH.append(gridList.thead);

    gridList.renderer.setTheadWidths();
    gridList.renderer.setTbodyWidths();

    tableInH.setWidth(new Dimension.px(width));
    gridList.setWidth(new Dimension.px(width));

    // Fix fast bottom scroll on chrome
    contBody.scroll!.containerEl.style.setProperty('overflow-anchor', 'none');

    contBody.scroll!.containerEl.onScroll.listen((e) {
      tableInH.dom.style.marginLeft =
          '${-contBody.scroll!.containerEl.scrollLeft}px';
      if (fixedFooter) {
        tableInF.dom.style.marginLeft =
            '${-contBody.scroll!.containerEl.scrollLeft}px';
      }
      e.stopPropagation();
      gridList.renderer.onScroll(scrollTop);
    });

    if (_focusEl != null) _focusEl!.focus();

    scrollTop = _scrollTop;

    gridList.renderer.setRowHeight();
    gridList.renderer.onScroll(_scrollTop, false);
    gridList.addClass('fixed-layout');
  }

  void fixReset() {
    gridList.removeClass('fixed-layout');
    _scrollTop = scrollTop;
    _focusEl = html.document.activeElement;
    contHead.removeChilds();
    contBody.removeChilds();
    gridList.append(gridList.thead);
    if (fixedFooter) {
      contFoot.removeChilds();
      gridList.append(gridList.tfoot);
    }
    final wrap = new CLElement(new html.DivElement())
      ..append(gridList)
      ..setStyle({'min-width': '100%'});
    contBody.append(wrap, scrollable: true);
    gridList.setStyle({'width': null});
    gridList.map.forEach((k, v) => v._setWidth());
    gridList.renderer.setTbodyWidths(true);
    if (fixedFooter) gridList.renderer.setTfootWidths(true);
  }

  void empty() {
    fixReset();
    gridList.empty();
    _scrollTop = 0;
  }

  int get scrollTop => contBody.scroll!.containerEl.scrollTop ?? 0;

  set scrollTop(int scrollTop) =>
      contBody.scroll!.scrollTo(_scrollTop = scrollTop);

  void initLayout() {
    fixReset();
    fixTable();
    super.initLayout();
  }
}
