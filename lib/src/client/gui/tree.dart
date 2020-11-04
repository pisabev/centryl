part of gui;

class Tree {
  TreeNode node;
  List<Tree> childs = [];

  int level = 0;
  String leftSide = '0';
  bool isLast = false;
  bool isOpen = false;
  bool isRendered = false;
  bool isLoading = false;

  Tree parent;
  TreeBuilder treeBuilder;

  DivElement dom;
  AnchorElement domNode, domValue;

  Tree(this.node);

  void createHTML() {
    dom = new DivElement()..className = 'ui-tree';
    domNode = new AnchorElement()..className = 'node';
    folderNode();
    domNode.onClick.listen((e) => operateNode(true));
    domValue = new AnchorElement();
    final icon = folderImage();
    if (icon != null) domValue.append(new Icon(icon).dom);
    if (node.clas != null) domValue.classes.add(node.clas);
    domValue.append(node.value is String
        ? (new SpanElement()
          ..text = node.value
          ..classes.add('text'))
        : node.value);
    domValue.onClick.listen((e) => clickedFolder());
    if (treeBuilder.actionDblClick != null)
      domValue.onDoubleClick.listen((e) => treeBuilder.actionDblClick(this));
    dom..append(folderSide())..append(domNode)..append(domValue);
  }

  void setValue(dynamic value) {
    node.value = value;
    domValue
      ..setInnerHtml('')
      ..append(value is String
          ? (new SpanElement()
            ..text = node.value
            ..classes.add('text'))
          : node.value);
  }

  SpanElement folderSide() {
    final sp1 = new SpanElement();
    for (var i = 0; i < leftSide.split('').length; i++) {
      final sp2 = new SpanElement()
        ..className = (leftSide[i] == '1') ? 'vertline' : 'blank';
      sp1.append(sp2);
    }
    return sp1;
  }

  String folderImage() => treeBuilder.getIcon(this);

  void folderNode() {
    final el = domNode..innerHtml = '';
    var clasn = '';
    if (isLoading) {
      clasn = 'loading';
    } else if (childs.isEmpty && parent == null && !node.hasChilds) {
      clasn = 'blank';
    } else if (childs.isNotEmpty || node.hasChilds) {
      el.append(new Icon(Icon.arrow_drop_down).dom);
      if (isLast) {
        if (isOpen) {
          clasn = (parent == null) ? 'mfirstnode' : 'mlastnode';
        } else {
          clasn = (parent == null) ? 'pfirstnode' : 'plastnode';
        }
      } else {
        clasn = isOpen ? 'mnode' : 'pnode';
      }
    } else {
      clasn = isLast ? 'lastnode' : 'nnode';
    }
    el.className = 'node $clasn';
  }

  void operateNode([bool full = false]) {
    if (!isOpen)
      openChilds();
    else if (full)
      closeChilds();
    else
      return;
    setState();
  }

  Future clickedFolder() async {
    if (treeBuilder.actionClick != null) {
      if (await treeBuilder.actionClick(this)) {
        final main = treeBuilder;
        if (main.current != null)
          main.current.domValue.classes.remove('active');
        main.current = this;
        main.current.domValue.classes.add('active');
      }
    }
  }

  void setState() {
    isOpen = !isOpen;
    if (childs.isEmpty) isOpen = false;
    folderNode();
  }

  void openParents() {
    if (parent != null) {
      if (!parent.isOpen) parent.operateNode();
      parent.openParents();
    }
  }

  Future<void> openChilds() async {
    if (childs.isNotEmpty) {
      for (var i = childs.length - 1; i >= 0; i--) {
        if (!childs[i].isRendered)
          childs[i].renderObj();
        else
          childs[i].dom.style.display = '';
        if (childs[i].isOpen) await childs[i].openChilds();
      }
    } else if (node.hasChilds) await treeBuilder.loadTree(this);
  }

  void closeChilds([bool remove = false]) {
    for (var i = 0; i < childs.length; i++) {
      if (childs[i].isRendered && !remove)
        childs[i].dom.style.display = 'none';
      else {
        if (childs[i].isRendered) {
          childs[i].dom.remove();
          childs[i].isRendered = false;
        }
      }
      childs[i].closeChilds(remove);
    }
  }

  void removeChilds() {
    for (var i = 0; i < childs.length; i++) {
      if (childs[i].isRendered) {
        childs[i].dom.remove();
        childs[i].isRendered = false;
      }
      childs[i].removeChilds();
    }
    childs.clear(); // = [];
  }

  void renderObj() {
    createHTML();
    if (parent != null && parent.dom.nextElementSibling != null)
      treeBuilder.dom.insertBefore(dom, parent.dom.nextElementSibling);
    else
      treeBuilder.dom.append(dom);
    isRendered = true;
  }

  Tree add(TreeNode node) {
    final tr = new Tree(node);
    childs.add(tr);
    tr
      ..parent = this
      ..treeBuilder = treeBuilder;
    return tr;
  }

  void initialize(int lev, bool lstNode, String lftSide) {
    level = lev;
    isLast = lstNode;
    leftSide = lftSide;
    treeBuilder.indexOfObjects[node.id] = this;

    if (childs.isNotEmpty) {
      if (treeBuilder.startOpen && level != 0) isOpen = true;
      level++;
      lftSide += isLast ? '0' : '1';
      for (var i = 0; i < childs.length; i++)
        if (i == childs.length - 1)
          childs[i].initialize(level, true, lftSide);
        else
          childs[i].initialize(level, false, lftSide);
    }
  }
}
