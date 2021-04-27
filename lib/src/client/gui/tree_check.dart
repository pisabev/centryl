part of gui;

class TreeCheck extends Tree {
  covariant TreeCheck? parent;
  covariant List<TreeCheck> childs = [];
  bool checked = false;
  late form.Check domInput;

  TreeCheck(TreeNode node) : super(node);

  void createHTML() {
    dom = new DivElement()..className = 'ui-tree';
    domNode = new AnchorElement();
    folderNode();
    domNode.onClick.listen((e) => operateNode(true));
    domValue = new AnchorElement();
    final icon = folderImage();
    if (icon != null) domValue.append(new Icon(icon).dom);
    if (node.clas != null) domValue.classes.add(node.clas!);
    domValue.append(node.value is String
        ? (new SpanElement()
          ..text = node.value
          ..classes.add('text'))
        : node.value);
    domValue.onClick.listen((e) => clickedFolder());
    if (treeBuilder.actionDblClick != null)
      domValue.onDoubleClick.listen((e) => treeBuilder.actionDblClick!(this));
    domInput = getCheck();
    initChecked();
    dom
      ..append(folderSide())
      ..append(domNode)
      ..append(domInput.dom)
      ..append(domValue);
  }

  form.Check getCheck() => new form.Check()..addAction((e) => checkOperate());

  void initChecked() {
    final checkObj = treeBuilder.checkObj;
    if ((checkObj != null && checkObj.contains(node.id)) ||
        (parent != null && parent!.checked)) {
      domInput.setChecked(true);
      checked = true;
    }
  }

  void checkOperate() {
    if (!checked) {
      addCheck();
    } else {
      removeParentCheck();
      removeCheck();
    }
    if (treeBuilder.actionCheck != null) treeBuilder.actionCheck!(this);
  }

  void addCheck() {
    checked = true;
    if (isRendered) domInput.setChecked(true);
    if (childs.isNotEmpty)
      for (var i = 0; i < childs.length; i++) childs[i].addCheck();
  }

  void removeParentCheck() {
    if (parent != null) {
      parent!.checked = false;
      if (parent!.isRendered) parent!.domInput.setChecked(false);
      parent!.removeParentCheck();
    }
  }

  void removeCheck() {
    checked = false;
    if (isRendered) domInput.setChecked(false);
    if (childs.isNotEmpty)
      for (var i = 0; i < childs.length; i++) childs[i].removeCheck();
  }

  TreeCheck add(TreeNode node) {
    final tr = new TreeCheck(node);
    childs.add(tr);
    tr
      ..parent = this
      ..treeBuilder = treeBuilder;
    return tr;
  }
}
