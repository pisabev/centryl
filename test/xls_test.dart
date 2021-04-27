@TestOn('vm')
library test;

import 'dart:async';
import 'dart:io';

import 'package:centryl/server.dart';
import 'package:test/test.dart';

Future<void> main() async {
  test('XLS', () async {
    final dc =
        new XLS.fromXLSBytes(new File('test/output.xlsx').readAsBytesSync());
    expect(dc.toMap(), emits(const TypeMatcher<Map>()));
  });
  test('XLS ToMap', () async {
    final dc =
        new XLS.fromXLSBytes(new File('test/output.xlsx').readAsBytesSync());
    final Stream<Map> f = dc.toMap();
    await f.forEach(print);
  });
  test('XLS To .csv', () async {
    final dc = new XLS.fromMapData([
      {'test': 1, 'test2': 2},
      {'test': 2, 'test2': 3},
      {'test': 4, 'test2': 5}
    ]);
    final List<int> f = dc.toCsv()!;
    new File('test/output.csv').writeAsBytesSync(f);
  });
  test('XLS To .xlsx', () async {
    final dc = new XLS.fromMapData([
      {'test': 1, 'test2': 2},
      {'test': 2, 'test2': 3},
      {'test': 4, 'test2': 5},
      {'test': 1, 'test2': 2},
      {'test': 2, 'test2': 3},
      {'test': 4, 'test2': 5},
      {'test': 1, 'test2': 2},
      {'test': 2, 'test2': 3},
      {'test': 4, 'test2': 5},
      {'test': 1, 'test2': 2},
      {'test': 2, 'test2': 3},
      {'test': 4, 'test2': 5}
    ]);
    final List<int>? f = await dc.toXls();
    await new File('test/output.xlsx').writeAsBytes(f!);
  });
}
