part of app;

class IconManager {
  CLElement container;
  List icons = [];

  IconManager(this.container);

  void add(Map o) {
    final cont = new CLElement(new AnchorElement())
      ..addAction((e) => o['action']());
    new CLElement(new DivElement())
      ..setClass('${o['icon']} icon-big')
      ..appendTo(cont);
    final h3 = new CLElement(new HeadingElement.h3())..appendTo(cont);
    cont.addClass('desktop-icon');
    h3.dom.text = o['title'];
    icons.add(cont);
  }

  void set(List arr) => arr.forEach(add);

  void render() {
    icons.forEach((icon) {
      container.append(icon);
    });
  }
}
