library test;

import 'dart:async';
import 'dart:io';

import 'package:centryl/server.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  group('Pdf', () {
    test(
        'Pdf',
        () => new Pdf(
                '<div style="background:red;width:200px;height:200px;border:1px solid red;">Test</div>'
                '<div style="background:blue;width:200px;height:200px;border:1px solid red;">Test 2</div>'
                '<div style="background:blue;width:200px;height:200px;border:1px solid red;">Test 3</div>')
            .toPdfFile('out.pdf', '.'));

    test(
        'Manager',
        () => listDirs('../lib').then((dirs) =>
            Future.wait(dirs.map((dir) => listDirs(dir.path))).then((data) {
              int i = 0;
              dirs = dirs
                  .map((d) => {
                        'value': basename(d.path),
                        'id': d.path,
                        'childs': data[i++].isNotEmpty
                      })
                  .toList();
              print(dirs);
            })));

    test(
        'Send',
        () => new Mail()
          ..from('support@yourcompany.com', 'Petar Sabev')
          ..to('pisabev@gmail.com')
          ..setText('text') //overriden by html
          ..setHtml(new File('test.html').readAsStringSync())
          ..addFile('../pubspec.lock', 'name')
          ..send().then((res) => expect(res, true, reason: 'Send')));

    test('Manager', () {
      const from = '../test/from';
      const to = '../test/to';
      return copyDirectory(from, to);
    });
  });

  group('Test', () {
    test('Sync', () {
      const String key = 'abcdefgh';
      const half = key.length ~/ 2;
      final sync_uuid = key.substring(0, half);
      final meta_uuid = key.substring(half, key.length);
      expect(sync_uuid, 'abcd');
      expect(meta_uuid, 'efgh');
    });
  });
}
