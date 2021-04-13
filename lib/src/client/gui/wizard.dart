part of gui;

class WizardElement extends CLElement {
  late CLElement titleDom;
  late CLElement contentDom;
  late Wizard _parent;

  FutureOr<bool> Function()? validate;

  WizardElement() : super(new LIElement()) {
    createDom();
  }

  void createDom() {
    addClass('step');
    titleDom = new CLElement(new DivElement())
      ..addClass('step-title')
      ..appendTo(this);
    contentDom = new CLElement(new DivElement())
      ..addClass('step-content')
      ..appendTo(this);
  }

  void setTitle(dynamic title) {
    titleDom.dom.innerHtml = '';
    titleDom.append((title is String) ? new Text(title) : title);
  }

  void current() {
    _parent.views.forEach((t) {
      t.removeClass('current');
    });
    addClass('current');
    _parent._contr.add(this);
  }

  void enable() {
    addAction((e) {
      final curStep = _parent.getCurrentStep();
      final curIndex = curStep._parent.views.indexOf(curStep);
      final nextIndex = _parent.views.indexOf(this);
      if (curIndex > nextIndex) current();
    });
    removeClass('disabled');
  }

  void disable() {
    removeActionsAll();
    addClass('disabled');
  }

  bool isLast() => _parent.views.last == this;

  bool isFirst() => _parent.views.first == this;
}

class Wizard extends Container {
  final StreamController<WizardElement> _contr =
      new StreamController.broadcast();
  List<WizardElement> views = [];

  Wizard() : super(new UListElement()) {
    createDom();
  }

  Stream<WizardElement> get onChangeStep => _contr.stream;

  void createDom() {
    addClass('ui-wizard horizontal');
  }

  WizardElement createStep(dynamic title) {
    final view = new WizardElement()..setTitle(title);
    append(view);
    views.add(view);
    view
      .._parent = this
      ..enable();
    return view;
  }

  bool isCurrentStep(WizardElement tab) => tab.existClass('current');

  void currentStep(WizardElement tab) => tab.current();

  void enableStep(WizardElement tab) => tab.enable();

  void disableStep(WizardElement tab) => tab.disable();

  void hideStep(WizardElement tab) => tab.hide();

  void showStep(WizardElement tab) => tab.show();

  WizardElement? getCurrentStep() =>
      views.firstWhereOrNull((e) => e.existClass('current'));

  WizardElement? prev() {
    final current = getCurrentStep();
    if (current != null) {
      final curIndex = views.indexOf(current);
      final prevIndex = math.max(0, curIndex - 1);
      return views[prevIndex]
        ..current()
        ..enable();
    }
    return null;
  }

  Future<WizardElement> next({bool validate = true}) async {
    final current = getCurrentStep();
    if (current != null &&
        (!validate || current.validate == null || await current.validate())) {
      final curIndex = views.indexOf(current);
      final nextIndex = math.min(views.length - 1, curIndex + 1);
      return views[nextIndex]
        ..current()
        ..enable();
    }
    return null;
  }
}
