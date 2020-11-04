part of gui;

String getFileExtIcon(String fileName) {
  final ext = fileName.split('.').removeLast().toLowerCase();
  var icon = Icon.file_unknown;
  switch (ext) {
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
      icon = Icon.file_image;
      break;
    case 'xls':
      icon = Icon.file_excel;
      break;
    case 'doc':
      icon = Icon.file_word;
      break;
    case 'pdf':
      icon = Icon.file_pdf;
      break;
    case 'zip':
    case 'rar':
      icon = Icon.file_archive;
      break;
    case 'txt':
      icon = Icon.file_unknown;
      break;
  }
  return icon;
}

abstract class FileContainerBase<E extends form.DataElement> extends CLElement {
  final E parent;
  Map data;
  int dataState = 0;

  FileContainerBase(this.parent) : super(new DivElement());

  void setData(String Function() path, Map data);
  void disable();
  void enable();
  void onDelete();

  Map getData() => data;
}

class _FileContainer<E extends form.DataElement> extends FileContainerBase<E> {
  CLElement<AnchorElement> link;
  CLElement<ImageElement> img;
  CLElement<AnchorElement> del;

  _FileContainer(parent) : super(parent) {
    link = new CLElement(new AnchorElement())
      ..setClass('ui-file-link')
      ..appendTo(this);
    link.dom.target = '_blank';
    img = new CLElement(new ImageElement())..appendTo(link);
    del = new CLElement(new AnchorElement())
      ..setClass('ui-file-remove')
      ..append(new Icon(Icon.delete).dom)
      ..hide(useVisibility: true)
      ..addAction((_) => onDelete())
      ..appendTo(this);
    addAction((e) => del.show(), 'mouseover');
    addAction((e) => del.hide(useVisibility: true), 'mouseout');
  }

  void setData(String Function() path, Map data) {
    this.data = data;
    link.dom.href = '${path()}/${data['source']}';
    link.dom.title = data['source'];
    link.dom.text = data['source'];
  }

  void disable() {
    state = false;
    del.state = false;
  }

  void enable() {
    state = true;
    del.state = true;
  }

  void onDelete() {
    if (dataState == 1) {
      dataState = 0;
    } else {
      dataState = 3;
      parent.contrValue.add(parent);
    }
    remove();
  }
}

class FileAttach<E extends FileContainerBase> extends form.DataElement {
  Map<String, E> conts = {};
  action.FileUploader uploader;
  String Function() path_tmp, path_media;
  bool _delete = true;
  bool get delete => _delete;
  set delete(bool d) {
    _delete = d;
    conts.values.forEach((el) => el.setState(d));
  }

  E Function(FileAttach) genContainer;

  FileAttach(this.uploader, this.path_tmp, this.path_media,
      [this.genContainer, this._delete = true])
      : super() {
    genContainer ??= (p) => new _FileContainer<FileAttach>(p) as E;
    dom = new DivElement();
    addClass('ui-file-container');
    uploader.observer
      ..addHook(action.FileUploader.hookLoading, onFileLoadStart)
      ..addHook(action.FileUploader.hookLoaded, onFileLoadEnd);
  }

  bool onFileLoadStart(String fileName) {
    append(conts[fileName] = genContainer(this)..setState(delete));
    return true;
  }

  bool onFileLoadEnd(String fileName) {
    conts[fileName]
      ..setData(path_tmp, {'source': fileName})
      ..dataState = 1;
    if (uploader.fileToLoad == 0) contrValue.add(this);
    return true;
  }

  void disable() {
    uploader.disable();
    conts.forEach((k, cont) => cont.disable());
    state = false;
  }

  void enable() {
    uploader.enable();
    conts.forEach((k, cont) => cont.enable());
    state = true;
  }

  void setValue(dynamic value) {
    if (conts != null) conts.forEach((k, c) => c.remove());
    conts = {};
    if (value is List) {
      value.forEach((data) {
        conts[data['source']] = genContainer(this)
          ..setData(path_media, data)
          ..appendTo(this)
          ..setState(delete);
      });
    }
    contrValue.add(this);
    //Containers must be disabled if element is disabled on setValue
    if (!state) disable();
  }

  Map getValue() {
    final r = {'insert': [], 'update': [], 'delete': []};
    conts.forEach((k, v) {
      if (v.dataState == 1)
        r['insert'].add(v.getData());
      else if (v.dataState == 2)
        r['update'].add(v.getData());
      else if (v.dataState == 3) r['delete'].add(v.getData());
    });
    return r;
  }

  void focus() {}

  void blur() {}
}
