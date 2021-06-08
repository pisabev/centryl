part of cl_base.ctrl;

abstract class Item<E extends Entity, T> extends Base {
  String? group;

  String? scope;

  Item(req, [this.group, this.scope]) : super(req);

  void get() => runDb(group, scope, $RunRights.read, (manager) async {
        final params = await getData();
        return response(await doGet(manager, params['id']));
      });

  Future<void> save() async {
    final body = await getData();
    final id = body['id'];
    final operation = (id != null) ? $RunRights.update : $RunRights.create;
    return runDb(group, scope, operation, (manager) async {
      final data = body['data'];
      return response({'id': await doSave(manager, id, data)});
    });
  }

  void delete() => runDb(group, scope, $RunRights.delete, (manager) async {
        final params = await getData();
        return response(await doDelete(manager, params['id']));
      });

  Future<Map> doGet(Manager manager, T id);

  Future<T> doSave(Manager manager, T id, Map<String, dynamic> data);

  Future<bool> doDelete(Manager manager, T id);
}
