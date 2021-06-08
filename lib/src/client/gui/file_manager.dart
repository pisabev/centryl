part of gui;

class FileManagerLayout extends cl.Container {
  late Container leftOptionsTop;
  late Container leftInner;
  late Container rightOptionsTop;
  late Container rightInner;

  FileManagerLayout() {
    leftOptionsTop = new Container();
    leftInner = new Container();
    rightOptionsTop = new Container();
    rightInner = new Container();

    final col1 = new Container()
      ..setWidth(new cl.Dimension.px(400))
      ..addRow(leftOptionsTop)
      ..addRow(leftInner..auto = true);
    final col2 = new Container()
      ..auto = true
      ..addRow(rightOptionsTop)
      ..addRow(rightInner..auto = true);

    addCol(col1);
    addSlider();
    addCol(col2);
  }
}

class Thumb extends cl.CLElement<DivElement> {
  String file;
  bool rendered = false;

  Thumb(this.file, this.rendered) : super(new DivElement()) {
    addClass('ui-filemanager-image');
  }
}

class FileManager extends FileManagerBase {
  late FileManagerLayout layout;
  late WinApp wapi;
  WinMeta meta = new WinMeta()
    ..title = intl.File_manager()
    ..icon = cl.Icon.folder
    ..type = 'bound';

  final StreamController<Thumb> _contr = new StreamController.broadcast();

  Thumb? currentThumb;
  late action.Menu menuTop;
  late action.Menu menu;
  late List<Thumb> list;

  FileManager(Application ap, String path)
      : super(ap, path, {'folder': cl.Icon.folder}) {
    wapi = new WinApp(ap);
    initInterface();
    initTree(layout.leftInner);
    wapi.render();
    initLeftMenuTop();
    initRightMenuTop();
  }

  Stream<Thumb> get onDblClick => _contr.stream;

  void initInterface() {
    layout = new FileManagerLayout();
    wapi.load(meta, this);
    wapi.win.getContent().append(layout);
  }

  void renderView() {
    if (list.isEmpty) return;
    final first = list.first;
    final dim = first.getRectangle(),
        boxWidth = dim.width + first.getWidthOuterShift(),
        boxHeight = dim.height + first.getHeightOuterShift(),
        viewDim = layout.rightInner.getRectangle(),
        countLeft = (viewDim.width / boxWidth).round(),
        countTop = (viewDim.height / boxHeight).round(),
        scrollTop = layout.rightInner.dom.scrollTop,
        shift = ((scrollTop / dim.height) * countLeft).round(),
        start = 0 + shift,
        stop = countTop * countLeft + shift;
    var i = 0;
    list.forEach((thumb) {
      if (!thumb.rendered && i >= start && i < stop) {
        thumb
          ..setStyle({
            'background-image': 'url(${ap.baseurl}media/'
                'image${dim.width.floor()}x${dim.height.floor()}/'
                '${Uri.encodeComponent(thumb.file)})'
          })
          ..rendered = true;
        i++;
      }
    });
  }

  Future<bool> clickedNode(Tree object) async {
    if (object.node.id != main) {
      menuTop.initButtons(
          ['folderadd', 'folderedit', 'foldermove', 'folderdelete']);
      menu.initButtons(['fileadd']);
    } else {
      menuTop.initButtons(['folderadd']);
      menu.initButtons(['fileadd']);
    }
    current = object;
    currentThumb = null;
    list = [];
    final data = await ap.serverCall<List>(FileManagerBase.rfileList,
        {'base': base, 'object': current.node.id}, layout.rightInner);
    layout.rightInner.removeChilds();
    data!.forEach((f) {
      final thumb = new Thumb(f, false);
      thumb
        ..appendTo(layout.rightInner)
        ..addAction((e) => clickedFile(thumb), 'click')
        ..addAction((e) => _contr.add(thumb), 'dblclick');
      list.add(thumb);
    });
    renderView();
    return true;
  }

  FutureOr<bool> clickedFile(Thumb thumb) async {
    currentThumb?.removeClass('ui-file-clicked');
    currentThumb = thumb..addClass('ui-file-clicked');
    menu.initButtons(['fileadd', 'filedelete']);
    return true;
  }

  Future<void> deleteFile(_) async {
    await ap.serverCall(FileManagerBase.rfileDelete,
        {'base': base, 'object': currentThumb?.file}, treeDom);
    await clickedNode(current);
  }

  void initLeftMenuTop() {
    menuTop = new action.Menu(layout.leftOptionsTop)
      ..add(new action.Button()
        ..setName('folderadd')
        ..addClass('light')
        ..setState(false)
        ..setTip(intl.Add_folder())
        ..setIcon(cl.Icon.folder)
        ..addAction(folderAdd))
      ..add(new action.Button()
        ..setName('folderedit')
        ..addClass('light')
        ..setState(false)
        ..setTip(intl.Edit_folder())
        ..setIcon(cl.Icon.edit)
        ..addAction(edit))
      ..add(new action.Button()
        ..setName('foldermove')
        ..addClass('light')
        ..setState(false)
        ..setTip(intl.Move_folder())
        ..setIcon(cl.Icon.redo)
        ..addAction(move))
      ..add(new action.Button()
        ..setName('folderdelete')
        ..addClass('light')
        ..setState(false)
        ..setTip(intl.Delete_folder())
        ..setIcon(cl.Icon.delete)
        ..addAction(delete));
  }

  void initRightMenuTop() {
    menu = new action.Menu(layout.rightOptionsTop);
    final uploader = new action.FileUploader(ap)
      ..setName('fileadd')
      ..addClass('important')
      ..setTitle(intl.Add_file())
      ..setState(false)
      ..setIcon(cl.Icon.add);
    uploader.observer.addHook(action.FileUploader.hookLoaded, (files) {
      clickedNode(current);
      return true;
    });
    menu
      ..add(uploader
        ..addAction((e) => uploader.setUpload('$base/${current.node.id}')))
      ..add(new action.Button()
        ..setName('filedelete')
        ..addClass('warning')
        ..setTitle(intl.Delete_file())
        ..setState(false)
        ..setIcon(cl.Icon.delete)
        ..addAction(deleteFile));
  }
}
