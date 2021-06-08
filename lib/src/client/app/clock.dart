part of app;

class Clock extends CLElement {
  Clock() : super(new DivElement()) {
    setClass('ui-addon ui-timer');
    final timer_func = ([_]) => dom.innerHtml =
        new DateFormat('Hm', 'en_US').format(new DateTime.now());
    new Timer.periodic(const Duration(seconds: 1), timer_func);
    timer_func();
  }
}
