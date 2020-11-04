part of utils;

class KeyValidator {
  static bool isNum(KeyboardEvent event) {
    final code = event.which;
    return new RegExp(r'\d').hasMatch(String.fromCharCode(code));
  }

  static bool isPoint(KeyboardEvent event) {
    final code = event.which;
    return new RegExp(r'\.').hasMatch(String.fromCharCode(code));
  }

  static bool isComma(KeyboardEvent event) {
    final code = event.which;
    return new RegExp(r',').hasMatch(String.fromCharCode(code));
  }

  static bool isMinus(KeyboardEvent event) {
    final code = event.which;
    return new RegExp(r'-').hasMatch(String.fromCharCode(code));
  }

  static bool isPlus(KeyboardEvent event) {
    final code = event.which;
    return new RegExp(r'\+').hasMatch(String.fromCharCode(code));
  }

  static bool isSlash(KeyboardEvent event) {
    final code = event.which;
    return new RegExp(r'/').hasMatch(String.fromCharCode(code));
  }

  static bool isColon(KeyboardEvent event) {
    final code = event.which;
    return new RegExp(r':').hasMatch(String.fromCharCode(code));
  }

  static bool isKeyDown(KeyboardEvent event) {
    final code = event.which;
    return code == 40;
  }

  static bool isKeyUp(KeyboardEvent event) {
    final code = event.which;
    return code == 38;
  }

  static bool isKeyLeft(KeyboardEvent event) {
    final code = event.which;
    return code == 37;
  }

  static bool isKeyRight(KeyboardEvent event) {
    final code = event.which;
    return code == 39;
  }

  static bool isKeyEnter(KeyboardEvent event) {
    final code = event.which;
    return code == 13;
  }

  static bool isKeyEnterCtrl(KeyboardEvent event) {
    final code = event.which;
    return code == 10;
  }

  static bool isKeySpace(KeyboardEvent event) {
    final code = event.which;
    return code == 32;
  }

  static bool isBackSpace(KeyboardEvent event) {
    final code = event.which;
    return code == 8;
  }

  static bool isESC(KeyboardEvent event) {
    final code = event.which;
    return code == 27;
  }
}
