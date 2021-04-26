part of gui;

class TabElement extends Container {
  late CLElement optionDom;
  late CLElement titleDom;
  late TabContainer _parent;
  Icon? icon;

  void createDom() {
    optionDom = new CLElement(new Element.li())..setClass('ui-tab-link');
    titleDom = new CLElement(new SpanElement())..appendTo(optionDom);
  }

  void setTitle(dynamic title) {
    titleDom.dom.innerHtml = '';
    titleDom.append((title is String) ? new Text(title) : title);
  }

  void changed() {
    if (icon != null) return;
    icon = new Icon(Icon.save);
    optionDom.dom.insertBefore(icon!.dom, titleDom.dom);
  }

  void clean() {
    if (icon != null) {
      icon!.dom.remove();
      icon = null;
    }
  }

  void inactiveTab() {
    optionDom.removeClass('active');
    removeClass('active');
  }

  void activeTab() {
    _parent.views.forEach((t) => t.inactiveTab());
    optionDom.addClass('active');
    addClass('active');
    initLayout();
  }

  void enable() => optionDom
    ..addAction((e) => activeTab())
    ..removeClass('disabled');

  void disable() => optionDom
    ..removeActionsAll()
    ..addClass('disabled');

  void hideTab() {
    optionDom.hide();
    removeClass('active');
  }

  void showTab() => optionDom.show();
}

class TabContainer extends Container {
  late Container tab_options, tab_content;
  late  CLElement options;
  List<TabElement> views = [];

  TabContainer() : super() {
    addClass('ui-tab');
    createDom();
  }

  void createDom() {
    tab_options = new Container()..addClass('ui-tab-options');
    options = new CLElement(new Element.ul())..appendTo(tab_options);
    tab_content = new Container()..addClass('ui-tab-content');
    new CLscroll(tab_options.dom);
    addRow(tab_options);
    addRow(tab_content..auto = true);
  }

  TabElement createTab(dynamic title) {
    final view = new TabElement()..createDom();
    options.append(view.optionDom);
    tab_content.append(view);

    if (title == null) {
      addClass('single');
    } else {
      removeClass('single');
      view.setTitle(title);
    }

    views.add(view);
    containers.add(view);
    view._parent = this;
    enable(view);

    activeTab(view);

    return view;
  }

  bool isTabActive(TabElement tab) => tab.optionDom.existClass('active');

  bool isVisible(TabElement tab) => tab.optionDom.dom.offsetParent != null;

  void activeTab(TabElement tab) => tab.activeTab();

  void inactiveTab(TabElement tab) => tab.inactiveTab();

  void enable(TabElement tab) => tab.enable();

  void disable(TabElement tab) => tab.disable();

  void hideTab(TabElement tab) => tab.hideTab();

  void showTab(TabElement tab) => tab.showTab();

  void clearTabs() => views.forEach((t) => t.clean());
}
