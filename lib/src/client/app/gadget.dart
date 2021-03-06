part of app;

class GadgetController<T> {
  late T result;

  late FutureOr<T> Function(CLElement) init;
  MessageBusSub? feed;
  FutureOr<void> Function<E>(E v)? loadFeed;
  late void Function() update;

  GadgetController({required this.init, this.feed, this.loadFeed}) {
    if (feed != null)
      feed!.listen((v) {
        if (loadFeed != null)
          loadFeed!(v);
        else {
          result = v;
          update();
        }
      });
  }

  Future<void> load(CLElement el) async {
    result = await init(el);
    update();
  }
}

abstract class GadgetBase<T> extends CLElement<DivElement> {
  late GadgetController<T> contr;
  String? scope;

  GadgetBase([GadgetController<T>? contr]) : super(new DivElement()) {
    createDom();
    if (contr != null) setController(contr);
  }

  void setController(GadgetController<T> controller) =>
      contr = controller..update = update;

  void createDom();

  void update();

  Future? load() => contr.load(this);
}

class CardGadget extends GadgetBase<String> {
  String title;
  String icon;

  late CLElement titleDom, contentDom;
  late Element domIcon;

  CardGadget(this.title, this.icon, GadgetController<String> contr)
      : super(contr);

  @override
  void createDom() {
    final cont = new CLElement(new SpanElement())
      ..addClass('left')
      ..append(contentDom = new CLElement(new SpanElement())..addClass('value'))
      ..append(titleDom = new CLElement(new SpanElement())
        ..addClass('title')
        ..setText(title));
    append(cont);
    append(domIcon = new Icon(icon).dom);
  }

  @override
  void update() => contentDom.setText('${contr.result}');
}

class ChartGadget extends GadgetBase<List<dto.DataContainer>> {
  String? title;
  late chart.Chart ch;
  late CLElement titleDom, contentDom;

  ChartGadget(this.title, GadgetController<List<dto.DataContainer>> contr)
      : super(contr);

  @override
  void createDom() {
    if (title != null) {
      titleDom = new CLElement(new HeadingElement.h2())
        ..appendTo(this)
        ..dom.text = title;
    }
    contentDom = new CLElement(new DivElement())..appendTo(this);
    ch = new chart.Chart(contentDom);
  }

  @override
  void update() {
    ch.reset();
    contr.result.forEach(ch.addData);
    ch.redraw();
  }
}

class PieGadget extends GadgetBase<List<dto.DataSet>> {
  String? title;
  late chart.Pie ch;
  late CLElement titleDom, contentDom;

  PieGadget(this.title, GadgetController<List<dto.DataSet>> contr)
      : super(contr);

  @override
  void createDom() {
    if (title != null) {
      titleDom = new CLElement(new HeadingElement.h2())
        ..appendTo(this)
        ..dom.text = title;
    }
    contentDom = new CLElement(new DivElement())..appendTo(this);
    ch = new chart.Pie(contentDom);
  }

  @override
  void update() {
    ch
      ..setData(contr.result)
      ..redraw();
  }
}

class BarGadget extends GadgetBase<List<dto.DataSet>> {
  String? title;
  late chart.Bar bar;
  late CLElement titleDom, contentDom;

  BarGadget(this.title, GadgetController<List<dto.DataSet>> contr)
      : super(contr);

  @override
  void createDom() {
    if (title != null) {
      titleDom = new CLElement(new HeadingElement.h2())
        ..appendTo(this)
        ..dom.text = title;
    }
    contentDom = new CLElement(new DivElement())..appendTo(this);
    bar = new chart.Bar(contentDom);
  }

  @override
  void update() {
    bar
      ..setData(contr.result)
      ..redraw();
  }
}

class IconContainer extends Container {
  List<DeskIcon> icons = [];

  IconContainer() : super() {
    addClass('deskicon');
  }

  void addIcon(DeskIcon el) {
    icons.add(el);
    addCol(el);
  }
}

class GadgetContainer extends Container {
  late Application ap;
  List<GadgetBase> gadgets = [];

  GadgetContainer() : super();

  void addGadget(GadgetBase gadget, int size, [String? clas]) {
    gadgets.add(gadget);
    final cont = new Container()
      ..addClass('size$size')
      ..append(gadget)
      ..auto = true;
    addCol(cont);
    if (clas != null) cont.addClass(clas);
  }

  void load() => gadgets.forEach((g) {
        if (g.scope == null || ap.client.checkPermission(g.scope))
          g.load();
        else
          g.remove();
      });
}
