part of action;

class Warning {
  Element warningIcon;
  app.Bubble _bubble;
  Timer _timerWrn;

  CLElementBase iconCont;

  Warning(this.iconCont);

  void init(List<DataWarning> warnings, {bool showAuto = true}) {
    final warningsHtml = warnings.map((w) => w.message).join('</br>');

    if (iconCont != null) {
      warningIcon?.remove();
      warningIcon = new Icon(Icon.warning).dom..classes.add('warning');
      iconCont.append(warningIcon);
    }
    _bubble = new app.Bubble(new CLElement(warningIcon))..setHtml(warningsHtml);
    _bubble.cont
      ..addAction((e) => _bubble.showBubble(), 'mouseover')
      ..addAction((e) => _bubble.hideBubble(), 'mouseout');

    iconCont.addClass('warning');

    if (showAuto && warnings.isNotEmpty) {
      _timerWrn?.cancel();
      _timerWrn = new Timer(const Duration(seconds: 1), () {
        show(const Duration(seconds: 5));
        _timerWrn = null;
      });
    }
  }

  void show([Duration duration]) {
    if (duration != null) new Timer(duration, _bubble.hideBubble);
    _bubble.showBubble();
  }

  void remove() {
    warningIcon?.remove();
    iconCont.removeClass('warning');
  }
}
