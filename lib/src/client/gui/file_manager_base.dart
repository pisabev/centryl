part of gui;

abstract class FileManagerBase {
  Application ap;
  String path;
  String main;
  String base;
  Map<String, String> icons;
  TreeBuilder tree;
  CLElement treeDom;
  Tree current;

  static const String rfolderList = '/folder/list';
  static const String rfolderAdd = '/folder/add';
  static const String rfolderRename = '/folder/rename';
  static const String rfolderDelete = '/folder/delete';
  static const String rfolderMove = '/folder/move';
  static const String rfileList = '/file/list';
  static const String rfileAdd = '/file/add';
  static const String rfileEdit = '/file/edit';
  static const String rfileMove = '/file/move';
  static const String rfileRename = '/file/rename';
  static const String rfileDelete = '/file/delete';

  FileManagerBase(this.ap, this.path, this.icons) {
    final parts = path.split('/');
    main = parts.removeLast();
    base = parts.join('/');
  }

  void initTree(Container treeDom, [String call = rfolderList]) {
    this.treeDom = treeDom;
    tree = new TreeBuilder(
        node: new TreeNode(value: '[ $main ]', id: main),
        icons: icons,
        actionClick: clickedNode,
        actionLoad: (item) async {
          final data = await ap.serverCall<List>(
              call, {'base': base, 'object': item.node.id}, treeDom);
          tree.renderTree(item, data.cast<Map>());
        });
    treeDom.append(tree, scrollable: true);
    tree.loadTree(tree.main);
  }

  FutureOr<bool> clickedNode(Tree object);

  void folderAdd(_) {
    final parent = current..closeChilds(true);
    final newfolder = parent.add(new TreeNode(value: '', type: 'folder'));
    parent
      ..initialize(parent.level, parent.isLast, parent.leftSide)
      ..isLoading = false;
    parent.node.hasChilds = false;
    parent
      ..isOpen = false
      ..operateNode();
    final input = new form.Input();
    var called = false;
    Future<void> addCatRefresh(Event e) async {
      if ((e is FocusEvent && e.type == 'blur') ||
          (e is KeyboardEvent && (e.keyCode == 13 || e.keyCode == 27))) {
        if (called) return;
        called = true;
        await ap.serverCall(
            rfolderAdd,
            {
              'base': base,
              'parent': parent.node.id,
              'object': input.getValue()
            },
            treeDom);
        parent.treeBuilder.refreshTree(parent);
      }
    }

    input
      ..setValue(intl.New_folder())
      ..appendTo(newfolder.domValue)
      ..focus()
      ..select()
      ..addAction(addCatRefresh, 'blur')
      ..addAction(addCatRefresh, 'keydown');
  }

  void edit(_) {
    final field = current.domValue;
    final input = new form.Input();
    new CLElement(field)
      ..setHtml('')
      ..removeClass('active')
      ..append(input);
    input
      ..setValue(current.node.value)
      ..focus()
      ..select();
    var called = false;
    Future<void> addCatRefresh(Event e) async {
      if (e is KeyboardEvent && e.keyCode == 27) {
        field.innerHtml = current.node.value;
      }
      if ((e is FocusEvent && e.type == 'blur') ||
          (e is KeyboardEvent && e.keyCode == 13)) {
        if (called) return;
        called = true;
        await ap.serverCall(
            (current.node.type == 'folder') ? rfolderRename : rfileRename,
            {
              'base': base,
              'object': current.node.id,
              'name': '${current.parent.node.id}/${input.getValue()}'
            },
            treeDom);
        current.treeBuilder.refreshTree(current.parent);
      }
    }

    input
      ..addAction(addCatRefresh, 'blur')
      ..addAction(addCatRefresh, 'keydown');
  }

  Future<void> delete(_) async {
    await ap.serverCall(
        (current.node.type == 'folder') ? rfolderDelete : rfileDelete,
        {'base': base, 'object': current.node.id},
        treeDom);
    current.treeBuilder.refreshTree(current.parent);
  }

  void move(_) {
    final inner = new Container();
    final win =
        ap.winmanager.loadBoundWin(title: intl.Move_to(), icon: cl.Icon.redo);
    win.getContent().addRow(inner);
    final container = new CLElement(new DivElement())..setClass('ui-tree-cont');
    inner.dom.innerHtml = '';
    inner.append(container);
    Future<bool> moveTo(Tree folder) async {
      if (current.node.id != folder.node.id &&
          current.parent.node.id != folder.node.id)
        await ap.serverCall(
            (current.node.type == 'folder') ? rfolderMove : rfileMove,
            {
              'base': base,
              'object': current.node.id,
              'to': '${folder.node.id}/${current.node.value}'
            },
            treeDom);
      current.treeBuilder.refreshTree(current.treeBuilder.main);
      win.close();
      return true;
    }

    tree = new TreeBuilder(
        node: new TreeNode(value: '[ $main ]', id: main),
        icons: icons,
        actionClick: moveTo,
        actionLoad: (item) async {
          final data = await ap.serverCall<List>(
              rfolderList, {'base': base, 'object': item.node.id}, treeDom);
          tree.renderTree(item, data.cast<Map>());
        });
    container.append(tree);
    tree.loadTree(tree.main);
    win.render(300, 350);
  }
}
