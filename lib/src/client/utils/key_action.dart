part of utils;

class KeyAction {
  static const String ALT_S = 'ALT+S';
  static const String CTRL_S = 'CTRL+S';
  static const String CTRL_P = 'CTRL+P';
  static const String ALT_F4 = 'ALT+F4';
  static const String ESC = 'ESC';
  static const String F2 = 'F2';

  static final Map<String, bool Function(KeyboardEvent)> _combos = {
    CTRL_S: (e) => e.ctrlKey && e.keyCode == KeyCode.S,
    ALT_S: (e) => e.altKey && e.keyCode == KeyCode.S,
    CTRL_P: (e) => e.ctrlKey && e.keyCode == KeyCode.P,
    ALT_F4: (e) => e.altKey && e.keyCode == KeyCode.F4,
    ESC: (e) => e.keyCode == KeyCode.ESC,
    F2: (e) => e.keyCode == KeyCode.F2
  };

  String combo;
  Function action;

  KeyAction(this.combo, this.action);

  void run(Event e) {
    if (e is! KeyboardEvent) return;
    try {
      if (_combos[combo]!(e)) {
        e.preventDefault();
        action();
      }
    } catch (err) {}
  }
}
