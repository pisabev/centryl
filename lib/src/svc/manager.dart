part of cl_base.svc.server;

Future<String> copyFileCheck(String from, String to, String file, [int i = 0]) {
  final name = basenameWithoutExtension(file);
  final ext = extension(file);
  final check = (i > 0) ? '${name}_$i$ext' : file;
  final found = new File(joinAll([to, check])).existsSync();
  if (found)
    return copyFileCheck(from, to, file, ++i);
  else {
    return new Directory(to).create(recursive: true).then((_) {
      final inStream = new File(joinAll([from, file])).openRead();
      final outStream =
          new File(joinAll([to, check])).openWrite(mode: FileMode.write);
      return inStream.pipe(outStream).then((_) => check);
    });
  }
}

Future<String> moveFileCheck(String from, String to, String file,
    [int i = 0]) async {
  final file1 = await copyFileCheck(from, to, file, i);
  await new File(joinAll([from, file])).delete();
  return file1;
}

Future<String> moveImageCompressed(String from, String to, String file,
        [int resize = 1000, int quality = 90]) =>
    Process.run('convert', [
      joinAll([from, file]),
      '-resize',
      '$resize>',
      '-strip',
      '-quality',
      '$quality',
      joinAll([from, file])
    ])
        .then((_) => moveFileCheck(from, to, file))
        .catchError((e) => moveFileCheck(from, to, file));

Future<List> listAll(String path, {bool recursive = false}) async {
  final objs = <Object>[];
  final files = <Object>[];
  await for (final obj in new Directory(path).list(recursive: recursive)) {
    if (obj is Directory)
      objs.add(obj);
    else
      files.add(obj);
  }
  objs.addAll(files);
  return objs;
}

Future<List> listDirs(String path, {bool recursive = false}) async {
  final dirs = <Directory>[];
  await for (final d in new Directory(path).list(recursive: recursive))
    if (d is Directory) dirs.add(d);
  return dirs;
}

Future<List<File>> listFiles(String path, {bool recursive = false}) async {
  final files = <File>[];
  await for (final f in new Directory(path).list(recursive: recursive))
    if (f is File) files.add(f);
  return files;
}

Future copyDirectory(String from, String to) async {
  await new Directory(to).create();
  final dirs = await listDirs(from, recursive: true);
  await Future.wait(dirs.map((dir) {
    final p = dir.path.replaceFirst(new RegExp(from), '');
    return (p.isNotEmpty)
        ? new Directory(to + p).create(recursive: true)
        : new Future.value();
  }));
  final files = await listFiles(from, recursive: true);
  await Future.wait(files.map((file) => new File(file.path)
      .copy(joinAll([to, file.path.replaceAll(new RegExp('$from/'), '')]))));
}

Future emptyDirectory(String path, {bool recursive = false}) async {
  final files = await listFiles(path, recursive: recursive);
  await Future.wait(files.map((file) => file.delete()));
  return true;
}

Future deleteDirectory(String path, {bool recursive = false}) async {
  final dir = new Directory(path);
  if (await dir.exists()) await dir.delete(recursive: recursive);
  return true;
}
