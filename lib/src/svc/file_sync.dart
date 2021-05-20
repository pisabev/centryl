part of cl_base.svc.server;

class FileSync {
  String path_from;
  String path_to;
  String file_name;

  /// Base64 encoded string (used for syncByContent)
  String content;

  bool destroy_source = false;

  FileSync();

  // Returns filename;
  Future<String> sync() {
    if (path_from != null) {
      if (path_from.startsWith('http')) return syncByUrl();
      return syncByPath();
    }
    if (content != null) return syncByContent();
    throw new Exception('FileSync is misconfigured');
  }

  // Returns filename;
  Future<String> syncByUrl() {
    String file;
    if (file_name == null) {
      file = path_from.split('/').last;
      if (file.split('.').length == 1) file = 'url_file';
    } else {
      file = file_name;
    }
    return http
        .get(Uri.parse(path_from))
        .then((response) => _writeAsBytes(file, response.bodyBytes));
  }

  // Returns filename;
  Future<String> syncByContent() =>
      _writeAsBytes(file_name, base64.decode(content));

  Future<String> _writeAsBytes(String fileName, List<int> bytes) =>
      new File(joinAll([path_to, fileName]))
          .create(recursive: true)
          .then((file) => file.writeAsBytes(bytes))
          .then((_) => fileName);

  // Returns filename;
  Future<String> syncByPath() {
    if (destroy_source) return moveFileCheck(path_from, path_to, file_name);
    return copyFileCheck(path_from, path_to, file_name);
  }
}
