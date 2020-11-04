part of ui;

typedef CheckF = bool Function();

class LockDecorations {
  String lockTip;
  String unlockTip;
  String lockIcon;
  String unlockIcon;
  String bClass;
  String title;

  LockDecorations(
      {this.lockTip,
      this.unlockTip,
      this.lockIcon,
      this.unlockIcon,
      this.bClass,
      this.title}) {
    lockTip ??= intl.Lock();
    unlockTip ??= intl.Unlock();
    lockIcon ??= cl.Icon.lock_outline;
    unlockIcon ??= cl.Icon.lock_open;
    bClass ??= 'warning';
    title ??= '';
  }
}

class Lock extends cl_action.Button {
  cl_app.Application ap;
  String permission;
  bool _locked = false;

  bool get locked => _locked;
  LockDecorations decorations;
  final List<Object> _components = [];
  final StreamController _contr = new StreamController<bool>.broadcast();
  final StreamController _contrLockTry = new StreamController<bool>.broadcast();
  CheckF checkF = () => false;

  Lock(this.ap, this.permission, {this.decorations, CheckF f}) : super() {
    ///Have we external function for lock checking
    if (f != null) checkF = f;

    decorations ??= new LockDecorations();
    addClass(decorations.bClass);
    setTip(decorations.lockTip, 'top');
    if (decorations.title.isNotEmpty) setTitle(decorations.title);
    addAction((e) => _lock());
    setIcon(decorations.unlockIcon);
  }

  Stream get onStateChange => _contr.stream;

  Stream get onLockTry => _contrLockTry.stream;

  void setLockState(bool state, {bool force = true}) {
    if (state)
      _lock(force: force);
    else
      _unlock(force: force);
  }

  void registerComponent(Object comp) {
    if (comp is Iterable)
      comp.forEach(_components.add);
    else
      _components.add(comp);
  }

  void removeComponent(Object comp) {
    if (comp is Iterable)
      comp.forEach(_components.remove);
    else
      _components.remove(comp);
  }

  void _lock({bool force = false}) {
    if (locked) return;
    _locked = true;
    if (!force &&
        permission != null &&
        !ap.client.checkPermission(permission) &&
        !checkF()) {
      _contrLockTry.add(true);
      return;
    }
    _operate(false);
    setIcon(decorations.lockIcon);
    setTip(decorations.unlockTip, 'top');
    removeAction('click.lock');
    addAction((e) => _unlock(), 'click.lock');
    _contr.add(true);
  }

  void _unlock({bool force = false}) {
    if (!locked) return;
    _locked = false;
    if (!force &&
        permission != null &&
        !ap.client.checkPermission(permission) &&
        !checkF()) {
      _contrLockTry.add(false);
      return;
    }
    _operate(true);
    setIcon(decorations.unlockIcon);
    setTip(decorations.lockTip, 'top');
    removeAction('click.lock');
    addAction((e) => _lock(), 'click.lock');
    _contr.add(false);
  }

  void _operate(bool state) {
    _components.forEach((comp) {
      if (comp is cl.CLElement)
        comp.setState(state);
      else if (comp is cl_form.Data) comp.setState(state);
    });
  }
}

class PButton extends cl_action.Button {
  cl_app.Application ap;
  String permission;
  final StreamController<bool> _contrTry =
      new StreamController<bool>.broadcast();
  final StreamController<bool> _contrDo =
      new StreamController<bool>.broadcast();

  Stream get onTry => _contrTry.stream;

  Stream get onDo => _contrDo.stream;
  CheckF checkF = () => false;

  PButton(this.ap, this.permission, {CheckF f}) : super() {
    if (f != null) checkF = f;
    addAction((e) => _click());
  }

  void _click() {
    if (permission != null &&
        !ap.client.checkPermission(permission) &&
        !checkF()) {
      _contrTry.add(true);
      return;
    } else
      _contrDo.add(true);
  }
}
