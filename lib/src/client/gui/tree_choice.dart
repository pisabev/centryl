part of gui;

class TreeChoice extends TreeCheck {
  covariant late TreeBuilder<TreeChoice> treeBuilder;

  TreeChoice(TreeNode node) : super(node);

  form.Check getCheck() {
    final input = new form.Check();
    final checkObj = treeBuilder.checkObj;
    if (checkObj != null) if (checkObj.contains(node.id)) {
      input.setChecked(true);
      checked = true;
    }
    input.addAction((e) => checkOperate());
    return input;
  }

  bool checkOperate() {
    treeBuilder.main!.removeCheck();
    checked = true;
    domInput.setChecked(true);
    if (treeBuilder.actionCheck != null) treeBuilder.actionCheck!(this);
    return true;
  }

  TreeCheck add(TreeNode node) {
    final tr = new TreeChoice(node);
    childs.add(tr);
    tr
      ..parent = this
      ..treeBuilder = treeBuilder;
    return tr;
  }
}
