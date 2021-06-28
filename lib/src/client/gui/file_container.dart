part of gui;

class FileContainer extends form.DataElement {
  Map? file;
  late int dataState;
  late action.FileUploader uploader;
  late String Function() path_tmp;
  late String Function() path_media;
  Map? dfile;
  AnchorElement span = AnchorElement()..style.display = 'block';

  FileContainer(this.uploader, this.path_tmp, this.path_media) : super() {
    dom = new DivElement()..append(span);
    //addClass('ui-image-container');
    uploader.observer
      ..addHook(action.FileUploader.hookLoading, onFileLoadStart)
      ..addHook(action.FileUploader.hookLoaded, onFileLoadEnd);
    append(uploader);
  }

  bool onFileLoadStart(String fileName) {
    if (file != null && file!['source'] != null) dfile = file;
    return true;
  }

  bool onFileLoadEnd(String fileName) {
    setFile(fileName);
    dataState = 1;
    contrValue.add(this);
    return true;
  }

  void setFile(String? fileName) {
    file = {'source': fileName};
    if (fileName != null)
      span
        ..innerHtml = fileName
        ..href = '${path_media()}/$fileName'
        ..target = '_blank';
    else
      span
        ..innerHtml = ''
        ..href = ''
        ..target = '';
  }

  Map? getFile() => file;

  void enable() => setState(true);

  void disable() => setState(false);

  void setValue(dynamic value) {
    setFile(value);
    contrValue.add(this);
  }

  Map getValue() {
    final r = <String, Object?>{
      'insert': null,
      'update': null,
      'delete': dfile
    };
    if (dataState == 1)
      r['insert'] = getFile();
    else if (dataState == 2)
      r['update'] = getFile();
    else if (dataState == 3) r['delete'] = getFile();
    return r;
  }

  void focus() {}

  void blur() {}
}
