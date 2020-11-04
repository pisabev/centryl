part of calendar;

class HourRow extends CLElement {
  int hour;

  int minutes;

  HourRow(this.hour, this.minutes) : super(new DivElement()) {
    addClass('hour-grid');
    if(minutes != 0)
      addClass('inner');
  }
}
