library test;

@TestOn('vm')
import 'dart:async';

import 'package:centryl/server.dart';
import 'package:mapper/mapper_test.dart';
import 'package:test/test.dart';

Future main() async {
  //test('', set);
  setUp(() async => testManager(new DatabaseConfig()));
  test('Cache', add);
  test('Cache expire', expire);
}

Future add() async {
  final cs = new CacheService();
  await cs.set('test', {'value': 1});
  expect((await cs.get('test'))['value'], 1);
  await cs.remove('test');
  expect(await cs.get('test'), null);
}

Future expire() async {
  final cs = new CacheService();
  await cs.set('test1', {'value': 1},
      expire: new DateTime.now().add(const Duration(seconds: 1)));
  expect((await cs.get('test1'))['value'], 1);
  await new Future.delayed(const Duration(seconds: 2));
  expect(await cs.get('test1'), null);
}
