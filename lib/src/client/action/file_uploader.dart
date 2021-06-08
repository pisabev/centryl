part of action;

class FileUploader extends Button {
  app.Application ap;

  static const String hookBefore = 'hook_before';
  static const String hookLoading = 'hook_loading';
  static const String hookLoaded = 'hook_loaded';

  CLElement<InputElement>? input;
  dynamic id;
  late utils.Observer observer;

  int fileToLoad = 0;

  String uploadPath;
  String contr;

  FileUploader(this.ap, [this.uploadPath = 'tmp', this.contr = '/file/upload'])
      : super() {
    observer = new utils.Observer();
    _initInput();
  }

  void _initInput() {
    fileToLoad = 0;
    createInput();
    setStyle({'position': 'relative', 'overflow': 'hidden'});
    append(input);
  }

  void setUpload(String upload) {
    uploadPath = upload;
  }

  void enable() {
    super.enable();
    if (input != null) append(input);
  }

  void disable() {
    super.disable();
    input?.remove();
  }

  void createInput() {
    input = new CLElement(new InputElement());
    input!.dom
      ..type = 'file'
      ..name = 'filename[]'
      ..multiple = true;
    input!
      ..setStyle({
        'opacity': '0',
        'position': 'absolute',
        'top': '-100px',
        'right': '0px',
        'font-size': '200px',
        'cursor': 'pointer',
        'text-align': 'right'
      })
      ..addAction((e) {
        if (input!.dom.files!.isNotEmpty) {
          fileToLoad = input!.dom.files!.length;
          input!.dom.files!.forEach((f) {
            final fr = new FileReader();
            fr.onLoad.listen((e) {
              final parts = (fr.result as String).split(',');
              if (parts.length > 1)
                _upload(f.name, parts.last);
              else
                _upload(f.name, null);
            });
            fr.readAsDataUrl(f);
          });
        }
      }, 'change');
  }

//  void _uploadMulti(name, String content) {
//    int length = content.length;
//    int step = 10000;
//    int cur = 0;
//    List parts = [];
//    for (;;) {
//      var nextOffset = math.min(cur + step, length);
//      parts.add(content.substring(cur, nextOffset));
//      if (nextOffset == length) break;
//      cur += nextOffset - cur;
//    }
//  }

  void _upload(name, content) {
    observer.execHooks(hookLoading, name);
    ap.serverCall(contr,
        {'object': name, 'base': uploadPath, 'content': content}).then((data) {
      fileToLoad--;
      if (fileToLoad == 0) _initInput();
      observer.execHooks(hookLoaded, name);
    });
  }
}
