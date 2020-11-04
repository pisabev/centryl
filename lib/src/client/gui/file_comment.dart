part of gui;

typedef FDFunc = String Function(String date);
typedef UFunc = String Function();

class FileComment extends _FileContainer<FileAttach> {
  static const String $comment = 'comment';
  static const String $date = 'date';
  static const String $creator = 'creator';

  static FDFunc formatDate = (s) => s;
  static UFunc getUser = () => '';

  DivElement cont = new DivElement()
    ..style.display = 'block';
  form.TextArea<String> ta = new form.TextArea();
  SpanElement cspan = new SpanElement()
    ..style.display = 'block';
  SpanElement dspan = new SpanElement()
    ..style.display = 'block';

  String get comment => ta.getValue() ?? '';
  set comment(String c) => ta.setValue(c ?? '');
  String get creator => cspan.innerHtml;
  set creator(String c) => cspan.innerHtml = c;
  String get date => dspan.innerHtml;
  set date(String d) => dspan.innerHtml = d;

  FileComment(parent) : super(parent) {
    dom.style.flexDirection = 'column';
    insertBefore(cont, link);
    cont
      ..append(ta.dom)
      ..append(cspan)
      ..append(dspan);
    ta.onReadyChanged
        .listen((e) => dataState = (dataState == 0) ? 2 : dataState);
  }

  void setData(String Function() path, Map data) {
    super.setData(path, data);
    comment = data[$comment];
    date = formatDate(data[$date] ?? new DateTime.now().toString());
    creator = data[$creator] ?? getUser();
  }

  Map getData() {
    data[$comment] = comment;
    data[$creator] = creator;
    data[$date] = date;
    return data;
  }

  void remove() {
    ta.remove();
    cspan.remove();
    dspan.remove();
    super.remove();
  }

  void enable() {
    super.enable();
    ta.enable();
  }

  void disable() {
    super.disable();
    ta.disable();
  }
}

class FileCommentAttach extends FileAttach<FileComment> {
  FileCommentAttach(action.FileUploader uploader, String Function() path_tmp,
      String Function() path_media,
      [bool delete = true])
      : super(uploader, path_tmp, path_media, null, delete) {
    genContainer = (p) {
      final fc = new FileComment(p)
        ..ta.onValueChanged.listen((_) => contrValue.add(this))
        ..ta.onReadyChanged.listen((_) => contrReady.add(this))
        ..ta.onWarning.listen((_) => contrWarning.add(this));
      return fc;
    };
  }
}
