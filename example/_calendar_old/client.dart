library application;

import 'dart:async';
import 'dart:html';
import 'package:centryl/app.dart' as cl_app;
import 'package:centryl/base.dart' as cl;
import 'package:centryl/action.dart' as action;
import 'package:centryl/calendar.dart' as calendar;

class EventCalendar extends calendar.EventCalendar {
  EventCalendar(container) : super(container);

  void createEvent(DateTime start_date, DateTime end_date,
      [bool full_day = false]) {
    events.add(new calendar.Event('Untitled', start_date, end_date, full_day));
  }

  void editEvent(calendar.Event ev) {}

  Future loadEvents(DateTime start_date, DateTime end_date) async {}

  Future persistEvent(calendar.Event ev) async {}
}

cl_app.Application ap = new cl_app.Application();

void main() {
  final cl_app.Client client = new cl_app.Client({'client': {'name': 'test'}})
    ..addApp(new cl_app.ClientApp()..init = (ap) => new action.Button()
      ..setIcon(cl.Icon.exit_to_app)
      ..addAction((e) => window.alert('logout'))
      ..setTitle('Logout'))
    ..addApp(new cl_app.ClientApp()..init = (ap) => new action.Button()
      ..setIcon(cl.Icon.settings)
      ..addAction((e) => window.alert('settings'))
      ..setTitle('Settings'));

  ap..setClient(client)
    ..menu.setMenu([])
    ..done();

  testCalendar();
}

void test() {
  testFormat();
  //testDates();
  //testDuration();
  //testDateSame();
}

void testFormat() {
  final d = DateTime.parse('2016-02-21 08:46:14.427288Z');
  print(d.toLocal());
}

void testDates() {
  final d = new DateTime(2016, 3, 27);
  print(d.add(new Duration(hours: 3)));

  final dutc = new DateTime.utc(2016, 3, 27);
  print(dutc.add(new Duration(hours: 3)));

  final d1 = new DateTime.utc(2016, 3, 1);
  //var d1 = new DateTime(2016, 3, 27).toUtc();
  print(new DateTime.utc(
          d1.year, d1.month, new DateTime.utc(d1.year, d1.month + 1, 0).day)
      .difference(new DateTime.utc(d1.year, d1.month, 1))
      .inHours);
  return print([
    new DateTime.utc(d1.year, d1.month, 1),
    new DateTime.utc(
        d1.year, d1.month, new DateTime.utc(d1.year, d1.month + 1, 0).day)
  ]);
}

void testDuration() {
  final d1 = new DateTime(2016, 3, 27);
  final d2 = new DateTime(2016, 3, 28);
  print(d2.difference(d1));
}

void testDateSame() {
  final d1 = new DateTime(2016, 3, 27, 2);
  final d2 = new DateTime(2016, 3, 27, 3);
  print(d1);
  print(d2);
  print(d2.isAtSameMomentAs(d1));
}

void testCalendar() {
  final cl_app.Win win = new cl_app.Win(ap.desktop)
    ..setTitle('Event calendar')
    ..render(1000, 600);

  final cal = new EventCalendar(win.getContent());
  win.observer.addHook('layout', (_) {
    cal.layout();
    return true;
  });

  /*cal.events.add(new calendar.Event(
        'test',
        (new DateTime.now()).add(new Duration(minutes:0)),
        (new DateTime.now()).add(new Duration(hours:23))
    ));
    cal.events.add(new calendar.Event(
        'test2',
        (new DateTime.now()).add(new Duration(minutes:0)),
        (new DateTime.now()).add(new Duration(days:3)),
        true
    ));*/
  cal.events
    ..add(new calendar.Event(
      'test2',
      (new DateTime.now()).add(new Duration(minutes: 0)),
      (new DateTime.now()).add(new Duration(days: 1)), true))
    ..add(new calendar.Event(
      'test3',
      (new DateTime.now()).add(new Duration(minutes: 0)),
      (new DateTime.now()).add(new Duration(days: 1)), true))
    ..add(new calendar.Event(
      'test4',
      (new DateTime.now()).add(new Duration(minutes: 0)),
      (new DateTime.now()).add(new Duration(days: 1)), true))
    ..add(new calendar.Event(
      'test5',
      (new DateTime.now()).add(new Duration(minutes: 0)),
      (new DateTime.now()).add(new Duration(days: 1)),true));

  final d1 = new DateTime.now().add(new Duration(minutes: 0));
  cal.events.add(new calendar.Event('test6', d1, d1, false));
  //new Timer(new Duration(seconds: 1), () {
  //    cal.refresh();
  //});
}
