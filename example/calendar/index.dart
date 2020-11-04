library test.cl.calendar;

import 'dart:async';
//import 'dart:html';
//import 'package:centryl/base.dart' as cl;
import 'package:centryl/app.dart' as app;
import 'package:centryl/calendar.dart' as ec;

import '../common/base.dart';

Future main() async {
  init();
  final w = new app.Win(ap.desktop)
    ..setTitle('Charts')
    ..render(1000, 750);

  final calendar = new EventCalendar(w.getContent());
  test1(calendar);
  //await new Future.delayed(new Duration(seconds:4));
  //calendar.scale(1.2);
  await calendar.setViewWeek();
  //var calendar1 = new EventCalendar.weekly(w.getContent());
  //test1(calendar1);
  //calendar1.renderEvents();
}

class EventCalendar extends ec.EventCalendar {

  EventCalendar(container) : super(container);

  EventCalendar.weekly(container) : super.weekly(container);

  void createEvent(DateTime start_date, DateTime end_date,
      [bool full_day = false]) {
    events.add(new ec.Event('Untitled', start_date, end_date, full_day));
  }

  void editEvent(ec.Event ev) {
    print('Edit $ev');
  }

  Future loadEvents(DateTime start_date, DateTime end_date) async { }

  Future persistEvent(ec.Event ev) async {
    print('Persist $ev');
  }

}

void test1(EventCalendar calendar) {
  final start = new DateTime.now().subtract(new Duration(hours: 2));
  final end = new DateTime.now().add(new Duration(hours: 2));
  final filterstart = start.subtract(new Duration(hours:2));
  final filterend = end.add(new Duration(hours:2));
  final filterstart2 = start.add(new Duration(days:1));
  final filterend2 = end.add(new Duration(days:2));

  final ec.Filter filter = new ec.Filter('test', filterstart, filterend);
  final ec.Filter filter2 = new ec.Filter('test', filterstart2, filterend2);
  calendar.filters.add(filter);
  calendar.filters.add(filter2);

  calendar.events.add(new ec.Event(
      'test1',
      start,
      end,
      false));
  calendar.events.add(new ec.Event('test2', new DateTime.now(),
      new DateTime.now().add(new Duration(days: 2)), true));
}