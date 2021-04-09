part of action;

class Menu {
  CLElement container;
  List<dynamic> indexOfElements = [];

  Menu(this.container) {
    container.addClass('ui-menu');
  }

  void add(dynamic el) {
    indexOfElements.add(el);
    container.append(el);
  }

  Button remove(String name) {
    dynamic el;
    indexOfElements.removeWhere((e) {
      if (e.getName() == name) {
        el = e;
        return true;
      }
      return false;
    });
    if (el != null) container.removeChild(el);
    return el;
  }

  void disable() => indexOfElements.forEach((e) => e.setState(false));

  void enable() => indexOfElements.forEach((e) => e.setState(true));

  Button getElement(String name) => indexOfElements
      .firstWhere((el) => el.getName() == name, orElse: () => null);

  void setState(String name, bool state) {
    for (var i = 0; i < indexOfElements.length; i++)
      if (name.isNotEmpty) {
        if (indexOfElements[i].getName() == name)
          indexOfElements[i].setState(state);
      } else
        indexOfElements[i].setState(state);
  }

  Button operator [](String key) => getElement(key);

  void initButtons([List? arr]) {
    indexOfElements.forEach((el) => el.setState(false));
    if (arr is List) arr.forEach((name) => this[name].setState(true));
  }

  void hide() => container.hide();

  void show() => container.show();
}
