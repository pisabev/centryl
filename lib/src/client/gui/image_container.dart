part of gui;

class ImageContainer extends form.DataElement {
  Map? image;
  int? dataState;
  action.FileUploader? uploader;
  String Function()? path_tmp, path_media;

  ImageContainer(this.uploader, this.path_tmp, this.path_media) : super() {
    dom = new DivElement();
    addClass('ui-image-container');
    if (uploader != null) {
      uploader!.observer
        ..addHook(action.FileUploader.hookLoading, onFileLoadStart)
        ..addHook(action.FileUploader.hookLoaded, onFileLoadEnd);
      append(uploader);
    }
  }

  bool onFileLoadStart(String fileName) => true;

  bool onFileLoadEnd(String fileName) {
    setImage(path_tmp!, fileName);
    dataState = 1;
    contrValue.add(this);
    return true;
  }

  void setImage(String Function() path, String? fileName) {
    image = {'source': fileName};
    if (fileName != null)
      setStyle({'background-image': 'url(${path()}/$fileName)'});
    else
      dom.style.removeProperty('background-image');
  }

  Map? getImage() => image;

  void disable() {
    //conts.forEach((k, cont) => cont.disable());
    //setState(false);
  }

  void setValue(dynamic value) {
    setImage(path_media!, value);
    contrValue.add(this);
  }

  Map getValue() {
    final r = <String, Object?>{'insert': null, 'update': null, 'delete': null};
    if (dataState == 1)
      r['insert'] = getImage();
    else if (dataState == 2)
      r['update'] = getImage();
    else if (dataState == 3) r['delete'] = getImage();
    return r;
  }

  void focus() {}

  void blur() {}

  void enable() {}
}
