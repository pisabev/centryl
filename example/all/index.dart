library test.cl.layout;

import 'dart:async';
import 'dart:html';

import 'package:centryl/action.dart' as cl_action;
import 'package:centryl/app.dart' as cl_app;
import 'package:centryl/base.dart';
import 'package:centryl/calendar.dart' as calendar;
import 'package:centryl/forms.dart' as cl_form;
import 'package:centryl/gui.dart' as cl_gui;
import 'package:centryl/layout.dart' as layout;
import 'package:centryl/utils.dart' as util;

import 'lib/action.dart';
import 'lib/grid.dart';
import 'lib/input.dart';
import 'lib/win.dart';

part 'lib/form.dart';

part 'lib/layout.dart';

cl_app.Application ap;

class EventCalendar extends calendar.EventCalendar {
  EventCalendar(container) : super(container);

  void createEvent(DateTime start_date, DateTime end_date,
      [bool full_day = false]) =>
    events.add(new calendar.Event('Untitled', start_date, end_date, full_day));

  void editEvent(calendar.Event ev) {}

  Future loadEvents(DateTime start_date, DateTime end_date) async {}
  Future persistEvent(calendar.Event ev) async {}
}

void renderCalendar() {
  final win =
      ap.winmanager.loadWindow(title: 'Calendar');
  final cal = new EventCalendar(win.getContent())
    ..setViewMonth();
  win.observer.addHook('layout', (_) {
    cal.layout();
    return true;
  });

  win..render();
}

void main() {
  ap = new cl_app.Application(
      settings: new cl_app.AppSettings()..desktopIcons = true)
    ..setAbout('packages/centryl/images/icons-sprite.svg', null)
    ..setClient(new cl_app.Client({
    'client': {'name': 'test'}})
    ..addApp(new cl_app.ClientApp()
      ..init = (ap) => new cl_action.Button()
        ..setIcon(Icon.exit_to_app)
        ..addAction((e) => window.alert('logout'))
        ..setTitle('Logout'))
    ..addApp(new cl_app.ClientApp()
      ..init = (ap) => new cl_action.Button()
        ..setIcon(Icon.settings)
        ..addAction((e) => window.alert('settings'))
        ..setTitle('Settings')));

  final List<cl_app.MenuElement> l = [
    new cl_app.MenuElement()
      ..title = 'Layouts'
      ..icon = Icon.sync
      ..addChild(new cl_app.MenuElement()
        ..title = 'Layout 1'
        ..icon = 'apps'
        ..desktop = true
        ..action = (ap) => new Ap1(ap))
      ..addChild(new cl_app.MenuElement()
        ..title = 'Layout 2'
        ..icon = 'apps'
        ..action = (ap) => new Ap2(ap))
      ..addChild(new cl_app.MenuElement()
        ..title = 'Layout 3'
        ..icon = 'apps'
        ..action = (ap) => new Ap3(ap))
      ..addChild(new cl_app.MenuElement()
        ..title = 'Layout 4'
        ..icon = 'apps'
        ..action = (ap) => new Ap4(ap)),
    new cl_app.MenuElement()
      ..title = 'Inputs'
      ..icon = 'input'
      ..action = (ap) => new AppInputs(ap),
    new cl_app.MenuElement()
      ..title = 'Actions'
      ..icon = 'play_arrow'
      ..action = (ap) => new AppActions(ap),
    new cl_app.MenuElement()
      ..title = 'Grids'
      ..icon = 'play_arrow'
      ..action = (ap) => new AppGrid(ap),
    new cl_app.MenuElement()
      ..title = 'Dialogs'
      ..icon = 'comment'
      ..addChild(new cl_app.MenuElement()
        ..title = 'Dialog'
        ..icon = 'comment'
        ..action = runDialog)
      ..addChild(new cl_app.MenuElement()
        ..title = 'Confirmer'
        ..icon = 'comment'
        ..action = runConfirmer)
      ..addChild(new cl_app.MenuElement()
        ..title = 'Question'
        ..icon = 'comment'
        ..action = runQuestion)];

  ap..setMenu(l)..done();

  //ap.notify.add(new cl_app.NotificationMessage()
  //..date = new DateTime.now()
  //..text = 'Notification Test');
}
