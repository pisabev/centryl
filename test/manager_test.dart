library test;

@TestOn('vm')
import 'dart:async';
import 'dart:io';
import 'package:centryl/server.dart';
import 'package:test/test.dart';

Future main() async {
  test('copyCategory', testCopyCategory);
  test('copyFileCheck', testCopyFileCheck);
  test('copyFileCheckSameName', testCopyFileCheckSameName);
  test('moveFileCheck', testMoveFileCheck);
}

Future testCopyCategory() async {
  if (new Directory('t1').existsSync())
    new Directory('t1').deleteSync(recursive: true);
  if (new Directory('t2').existsSync())
    new Directory('t2').deleteSync(recursive: true);

  new Directory('t1').createSync();
  new File('t1/ss.txt').createSync();
  new Directory('t2').createSync();
  await copyDirectory('t1', 't2/t1');
  expect(new File('t2/t1/ss.txt').existsSync(), true);

  if (new Directory('t1').existsSync())
    new Directory('t1').deleteSync(recursive: true);
  if (new Directory('t2').existsSync())
    new Directory('t2').deleteSync(recursive: true);
}

Future testCopyFileCheck() async {
  if (new Directory('t1').existsSync())
    new Directory('t1').deleteSync(recursive: true);

  new Directory('t1').createSync();
  new File('t1/file.txt').createSync();
  await copyFileCheck('t1', 't1/t2', 'file.txt');
  expect(new File('t1/t2/file.txt').existsSync(), true);

  if (new Directory('t1').existsSync())
    new Directory('t1').deleteSync(recursive: true);
}

Future testCopyFileCheckSameName() async {
  if (new Directory('t1').existsSync())
    new Directory('t1').deleteSync(recursive: true);

  new Directory('t1').createSync();
  new Directory('t1/t2').createSync();
  new File('t1/file.txt').createSync();
  new File('t1/t2/file.txt').createSync();
  await copyFileCheck('t1', 't1/t2', 'file.txt');
  expect(new File('t1/t2/file.txt').existsSync(), true);
  expect(new File('t1/t2/file_1.txt').existsSync(), true);

  if (new Directory('t1').existsSync())
    new Directory('t1').deleteSync(recursive: true);
}

Future testMoveFileCheck() async {
  if (new Directory('t1').existsSync())
    new Directory('t1').deleteSync(recursive: true);

  new Directory('t1').createSync();
  new File('t1/file.txt').createSync();
  await moveFileCheck('t1', 't1/t2', 'file.txt');
  expect(new File('t1/file.txt').existsSync(), false);
  expect(new File('t1/t2/file.txt').existsSync(), true);

  if (new Directory('t1').existsSync())
    new Directory('t1').deleteSync(recursive: true);
}
