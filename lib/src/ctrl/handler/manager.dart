part of cl_base.ctrl;

class FileManager extends Base {
  FileManager(req) : super(req);

  Future getDirs() => getData().then((data) async {
        final base = data['base'];
        final dirname = data['object'];
        final dirs = await listDirs(joinAll([path, base, dirname]));
        final result = await Future.wait(dirs.map((dir) => listDirs(dir.path)));
        var i = 0;
        return response(dirs
            .map((d) => {
                  'value': basename(d.path),
                  'id': d.path.replaceAll(new RegExp('$path/$base/'), ''),
                  'parentId': dirname,
                  'type': 'folder',
                  'hasChilds': result[i++].isNotEmpty,
                })
            .toList());
      });

  Future getDirsAll() => getData().then((data) async {
        final base = data['base'];
        final dirname = data['object'];
        final dirs = await listAll(joinAll([path, base, dirname]));
        final result = await Future.wait(dirs.map((dir) =>
            (dir is Directory) ? listAll(dir.path) : new Future.value([])));
        var i = 0;
        return response(dirs
            .map((d) => {
                  'value': basename(d.path),
                  'id': d.path.replaceAll(new RegExp('$path/$base/'), ''),
                  'parentId': dirname,
                  'type': (d is Directory)
                      ? 'folder'
                      : 'file${extension(d.path).toLowerCase()}',
                  'hasChilds': result[i++].isNotEmpty,
                })
            .toList());
      });

  Future getFiles() => getData().then((data) {
        final base = data['base'];
        final dirname = data['object'];
        return listFiles(joinAll([path, base, dirname])).then((dirs) =>
            response(dirs
                .map((file) =>
                    file.path.replaceAll(new RegExp('$path/$base/'), ''))
                .toList()));
      });

  Future dirAdd() => getData().then((data) {
        final base = data['base'];
        final dirname = data['object'];
        final parent = data['parent'];
        return new Directory(joinAll([path, base, parent, dirname]))
            .create(recursive: true)
            .then((_) => response({}));
      });

  Future dirRen() => getData().then((data) {
        final base = data['base'];
        final dir = data['object'];
        final name = data['name'];
        final dirname = joinAll([path, base, dir]);
        final newname = joinAll([path, base, name]);
        return new Directory(dirname).rename(newname).then((_) => response({}));
      });

  Future dirDel() => getData().then((data) {
        final base = data['base'];
        final dir = data['object'];
        final dirname = joinAll([path, base, dir]);
        return new Directory(dirname)
            .delete(recursive: true)
            .then((_) => response({}));
      });

  Future dirMove() => getData().then((data) {
        final base = data['base'];
        final dir = data['object'];
        final to = data['to'];
        final dirname = joinAll([path, base, dir]);
        final dirname_to = joinAll([path, base, to]);
        return copyDirectory(dirname, dirname_to)
            .then((_) => new Directory(dirname).delete(recursive: true))
            .then((_) => response({}));
      });

  Future fileMove() => getData().then((data) {
        final base = data['base'];
        final dir = data['object'];
        final to = data['to'];
        final dirname = joinAll([path, base, dir]);
        final dirname_to = joinAll([path, base, to]);
        return copyDirectory(dirname, dirname_to)
            .then((_) => new Directory(dirname).delete(recursive: true))
            .then((_) => response({}));
      });

  Future fileDel() => getData().then((data) {
        final base = data['base'];
        final file = data['object'];
        final filename = joinAll([path, base, file]);
        return new File(filename)
            .delete(recursive: true)
            .then((_) => response({}));
      });

  Future fileRen() => getData().then((data) {
        final base = data['base'];
        final file = data['object'];
        final name = data['name'];
        final dirname = joinAll([path, base, file]);
        final newname = joinAll([path, base, name]);
        return new File(dirname).rename(newname).then((_) => response({}));
      });

  Future fileRead() => getData().then((data) =>
      new File(joinAll([path, data['base'], data['object']]))
          .readAsString()
          .then((content) => response({'content': content})));

  Future fileCreate() => getData().then((data) {
        final filename = joinAll([path, data['base'], data['object']]);
        return new File(filename)
            .create(recursive: true)
            .then((f) => response({'create': filename}));
      });

  Future fileWrite() => getData().then((data) {
        final content = data['content'];
        final filename = joinAll([path, data['base'], data['object']]);
        return new File(filename)
            .create(recursive: true)
            .then((f) => f.writeAsString(content))
            .then((content) => response({'write': filename}));
      });

  Future fileUpload() => getData().then((data) {
        final content = data['content'];
        final filename = joinAll([path, data['base'], data['object']]);
        return new File(filename)
            .create(recursive: true)
            .then((f) =>
                f.writeAsBytes(content != null ? base64.decode(content) : []))
            .then((content) => response({'upload': filename}));
      });
}
