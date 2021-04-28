part of ui;

typedef CheckF = bool Function();

class LockDecorations {
  late String lockTip;
  late String unlockTip;
  late String lockIcon;
  late String unlockIcon;
  late String bClass;
  late String title;

  LockDecorations(
      {String? lockTip,
      String? unlockTip,
      String? lockIcon,
      String? unlockIcon,
      String? bClass,
      String? title}) {
    lockTip = lockTip ?? intl.Lock();
    unlockTip = unlockTip ?? intl.Unlock();
    lockIcon = lockIcon ?? cl.Icon.lock_outline;
    unlockIcon = unlockIcon ?? cl.Icon.lock_open;
    bClass = bClass ?? 'warning';
    title = title ?? '';
  }
}

class Lock extends cl_action.Button {
  cl_app.Application ap;
  String? permission;
  bool _locked = false;

  bool get locked => _locked;
  late LockDecorations decorations;
  late final List<dynamic> _components = [];
  final StreamController _contr = new StreamController<bool>.broadcast();
  final StreamController _contrLockTry = new StreamController<bool>.broadcast();
  CheckF checkF = () => false;

  Lock(this.ap, this.permission, {LockDecorations? dec, CheckF? f}) : super() {
    ///Have we external function for lock checking
    if (f != null) checkF = f;

    decorations = dec ?? new LockDecorations();
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
