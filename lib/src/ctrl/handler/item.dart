part of cl_base.ctrl;

abstract class Item<E extends Entity, T> extends Base {
  String group;

  String scope;

  Item(req, [this.group, this.scope]) : super(req);

  void get() => run(group, scope, $RunRights.read, () async {
        final params = await getData();
        manager = await new Database().init();
        response(await doGet(params['id']));
      });

  Future<void> save() async {
    final body = await getData();
    final id = body['id'];
    final operation = (id != null) ? $RunRights.update : $RunRights.create;
    await run(group, scope, operation, () async {
      final data = body['data'];
      manager = await new Database().init();
      response({'id': await doSave(id, data)});
    });
  }

  void delete() => run(group, scope, $RunRights.delete, () async {
        final params = await getData();
        manager = await new Database().init();
        response(await doDelete(params['id']));
      });

  Future<Map> doGet(T id);

  Future<T> doSave(T id, Map data);

  Future<bool> doDelete(T id);
}
