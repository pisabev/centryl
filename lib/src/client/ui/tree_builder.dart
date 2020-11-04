part of ui;

class TreeBuilder {
  cl.Container search_container, tree_container;
  cl_form.Input filter;
  cl_action.Menu menu;
  cl_gui.TreeBuilder tree;

  TreeBuilder(this.search_container, this.tree_container) {
    initFilter();
  }

  void initFilter() {
    menu = new cl_action.Menu(search_container);
    filter = new cl_form.Input()
      ..addAction(searchFilter, 'keyup')
      ..setStyle({'width': '100%'})
      ..setPrefixElement(new cl.CLElement(new cl.Icon(cl.Icon.search).dom));
    menu.add(filter);
  }

  void initTree(cl_gui.TreeBuilder tb, {bool scrollable = true}) {
    tree = tb;
    tree_container
      ..removeChilds()
      ..append(tree, scrollable: scrollable);
    tree.main.openChilds();
  }

  void searchFilter([KeyboardEvent e]) {
    if (e?.which == 13) refreshTree();
  }

  String getFilterValue() => filter.getValue();

  void refreshTree() => tree.refreshTree();
}
