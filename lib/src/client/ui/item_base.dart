part of ui;

abstract class ItemBase<C extends cl_app.Client> {
  cl_app.Application<C> ap;

  static const String save_before = 'save_before';
  static const String save_after = 'save_after';
  static const String get_before = 'get_before';
  static const String get_after = 'get_after';
  static const String del_before = 'del_before';
  static const String del_after = 'del_after';
  static const String change_after = 'change_after';

  dynamic _id;

  UrlPattern contr_get, contr_save, contr_del;

  Map data_send = {};
  dynamic data_response;
  cl_util.Observer observer;

  ItemBase(this.ap, [dynamic id]) {
    setId(id);
    observer = new cl_util.Observer();
  }

  void setId(dynamic id) => _id = id == 0 ? null : id;

  dynamic getId() => _id;

  Future get([cl.CLElementBase loading]) async {
    if (_id != null) {
      await ap.loadExecute(loading, () async {
        if (await observer.execHooksAsync(get_before)) {
          data_response =
              await ap.serverCall(contr_get.reverse([]), {'id': _id});
          await observer.execHooksAsync(get_after);
        }
      });
    }
  }

  Future del([cl.CLElementBase loading]) async {
    if (_id != null) {
      await ap.loadExecute(loading, () async {
        if (await observer.execHooksAsync(del_before)) {
          data_response =
              await ap.serverCall(contr_del.reverse([]), {'id': _id});
          await observer.execHooksAsync(change_after);
          await observer.execHooksAsync(del_after);
        }
      });
    }
  }

  Future save([cl.CLElementBase loading]) async {
    await ap.loadExecute(loading, () async {
      if (await observer.execHooksAsync(save_before)) {
        data_response = await ap.serverCall(contr_save.reverse([]), data_send);
        await observer.execHooksAsync(change_after);
        await observer.execHooksAsync(save_after);
      }
    });
  }

  void addHook(String scope, cl_util.ObserverFunction func,
          [bool first = false]) =>
      observer.addHook(scope, func, first);

  void removeHook(String scope, cl_util.ObserverFunction func) =>
      observer.removeHook(scope, func);
}
