part of chart;

class BarSmall extends CLElement {
  late DivElement bar;
  late SpanElement text;
  num width;

  BarSmall(this.width) : super(new DivElement()) {
    createDom();
  }

  void createDom() {
    addClass('ui-chart-bar-small');
    text = new SpanElement();
    append(text);
    bar = new DivElement();
    setStyle({'width': '${width}px'});
    append(bar);
  }

  void setPercents(int p) {
    text.text = '$p%';
    if (p == 0) {
      bar.style
        ..display = 'none'
        ..width = '0px';
      return;
    }
    bar.style.display = '';
    final widthInner = width * p / 100;
    new Timer(const Duration(milliseconds: 0), () {
      bar.style.width = '${widthInner}px';
    });
  }
}
