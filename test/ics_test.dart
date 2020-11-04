library test;

@TestOn('vm')
import 'dart:async';
import 'dart:io';
import 'package:centryl/server.dart';
//import 'package:mapper/mapper.dart' show Manager, Connection, Application;
import 'package:test/test.dart';

Future main() async {
  test('Parse', parse);
  test('75StringRow', stringRow);
  test('VEventToString', VEventToString);
}

Future parse() async {
  final ic = new VCalendar();
  await ic.readFile(new File('test/ics.ics'));
  ic.parse();
  expect(ic.elements.length, greaterThan(0));
}

void stringRow() {
  final v = new VElement();
  final String d = v.writeBuffer('SOMETHING',
      'Very long long long long long long long long long long long '
          'long long long long long long long long long long text');
  expect(d.split('\n').first.length, 75);
}

void VEventToString() {
  final v = new VElement()
    ..DTSTART = new DateTime.utc(2016, 03, 22, 10, 10, 15)
    ..DTEND = new DateTime.utc(2016, 03, 23, 10, 10, 15)
    ..DTSTAMP = new DateTime.utc(2016, 03, 24, 10, 10, 15)
    ..SUMMARY = 'Test';
  expect(
      v.toString(),
      '''BEGIN:VEVENT
DTSTART:20160322T101015Z
DTEND:20160323T101015Z
DTSTAMP:20160324T101015Z
SUMMARY:Test
BEGIN:END
''');
}
