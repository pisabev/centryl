part of utils;

// TODO remove this and 'import dart:js' too when native fullscreen works
void fullscreenWorkaround([bool full]) {
  if (!full) {
    final elem = new JsObject.fromBrowserObject(document);
    final vendors = <String>[
      'exitFullscreen',
      'mozCancelFullScreen',
      'webkitExitFullscreen',
      'msExitFullscreen',
      'oExitFullscreen'
    ];
    for (final vendor in vendors) {
      if (elem.hasProperty(vendor)) {
        elem.callMethod(vendor);
        return;
      }
    }
  } else {
    final elem = new JsObject.fromBrowserObject(document.body);
    final vendors = <String>[
      'requestFullscreen',
      'mozRequestFullScreen',
      'webkitRequestFullscreen',
      'msRequestFullscreen',
      'oRequestFullscreen'
    ];
    for (final vendor in vendors) {
      if (elem.hasProperty(vendor)) {
        elem.callMethod(vendor);
        return;
      }
    }
  }
}
