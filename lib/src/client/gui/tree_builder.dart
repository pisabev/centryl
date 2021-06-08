part of gui;

typedef TreeClickFunction = FutureOr<bool> Function(Tree);
typedef TreeDblClickFunction = FutureOr<bool> Function(Tree);
typedef TreeCheckFunction = FutureOr<bool> Function(Tree);
typedef TreeLoadFunction = Future Function(Tree);
typedef TreeValueFunction = TreeNode Function(TreeNode);

class TreeBuilder<E extends Tree> extends CLElement {
  E? main, current;
  Map<String, Tree> indexOfObjects = {};
  List<String>? checkObj;
  bool checkSingle;
  bool startOpen = false;
  Map<String, String> icons = {};

  TreeClickFunction? actionClick;
  TreeDblClickFunction? actionDblClick;
  TreeCheckFunction? actionCheck;
  TreeLoadFunction? actionLoad;
  TreeValueFunction? valueTransform = (d) => d;

  Completer? _completer;

  TreeBuilder(
      {TreeNode? node,
      Map<String, String>? icons,
      this.actionClick,
      this.actionDblClick,
      this.actionCheck,
      this.actionLoad,
      TreeValueFunction? valueTransform,
      this.checkSingle = false,
      this.checkObj})
      : super(new DivElement()) {
    this.icons = icons ?? this.icons;
    this.valueTransform = valueTransform ?? this.valueTransform;
    main = ((checkObj != null)
        ? ((checkObj is List && !checkSingle)
        ? new TreeCheck(node!)
        : new TreeChoice(node!))
        : new Tree(node!)
      ..treeBuilder = this
      ..initialize(0, true, '')
      ..renderObj()) as E;
  }

  String? getIcon(Tree item) {
    if (icons.containsKey(item.node.type)) return icons[item.node.type];
    return null;
  }

  List getChecked() {
    checkObj = [];
    setChecked(main as TreeCheck);
    return checkObj!;
  }

  void setChecked(TreeCheck folder) {
    if (folder.checked) {
      checkObj!.add(folder.node.id!);
      return;
    }
    for (var i = 0; i < folder.childs.length; i++)
      if (folder.childs[i].checked)
        checkObj!.add(folder.childs[i].node.id!);
      else
        setChecked(folder.childs[i]);
  }

  void initChecked() {
    (main as TreeCheck).initChecked();
  }

  Future<void> loadTree(Tree item) {
    _completer = new Completer();
    item
      ..isLoading = true
      ..folderNode();
    actionLoad!(item);
    return _completer!.future;
  }

  Tree? findByRef(dynamic ref) => indexOfObjects[ref];

  void select(Tree item) {
    item.clickedFolder();
  }

  Future<void> smartOpen() async {
    List<Tree> children = main!.childs;
    while (children.length == 1) {
      await children.first.openChilds();
      children = children.first.childs;
    }
  }

  /// Nodes - list of serialized TreeNode objects
  void renderTree(Tree item, List<Map> nodes, {bool startOpen = false}) {
    this.startOpen = startOpen;
    item.removeChilds();
    if (nodes.isNotEmpty) {
      final temp = <String, Tree>{item.node.id ?? 'item': item};
      for (var i = 0; i < nodes.length; i++) {
        final cur = new TreeNode.fromMap(nodes[i]);
        final pId = cur.parentId ?? 'item';
        final parentFolder = (temp.containsKey(pId)) ? temp[pId] : temp['item'];
        temp[cur.id!] = parentFolder!.add(valueTransform!(cur));
      }
    }
    item
      ..initialize(item.level, item.isLast, item.leftSide)
      ..isLoading = false
      ..node.hasChilds = false
      ..isOpen = false
      ..operateNode();
    if (_completer != null && !_completer!.isCompleted) _completer!.complete();
  }

  void refreshTree([Tree? item]) {
    item = item ?? main;
    if (item!.isLoading) return;
    startOpen = false;
    loadTree(item);
  }
}
