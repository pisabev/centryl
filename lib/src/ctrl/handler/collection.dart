part of cl_base.ctrl;

abstract class Collection<E extends Entity, T> extends Base {
  String? group;

  String? scope;

  Collection(req, [this.group, this.scope]) : super(req);

  void get() => runDb(group, scope, $RunRights.read, (manager) async {
        final params = await getData();
        final paginator = (params[$BaseConsts.paginator] != null)
            ? params[$BaseConsts.paginator]
            : {$BaseConsts.page: 0, $BaseConsts.limit: 0};
        final filter = (params[$BaseConsts.filter] != null)
            ? params[$BaseConsts.filter]
            : <String, dynamic>{};
        final order = (params[$BaseConsts.order] != null)
            ? params[$BaseConsts.order]
            : <String, String>{};
        paginator[$BaseConsts.page] = (paginator[$BaseConsts.page] != 0)
            ? paginator[$BaseConsts.page]
            : 1;
        final cb = await doGet(manager, filter, order, paginator);
        final r = <Map>[];
        for (final o in cb.collection) r.add(await lister(manager, o as E));
        return response({$BaseConsts.total: cb.total, $BaseConsts.result: r});
      });

  void delete() => runDb(group, scope, $RunRights.delete, (manager) async {
        final params = await getData();
        response(await doDelete(manager, params[$BaseConsts.ids].cast<T>()));
      });

  Future<Map> lister(Manager manager, E o) async => o.toJson();

  Future<CollectionBuilder> doGet(
      Manager manager, Map<String, dynamic> filter, Map order, Map paginator);

  Future<bool> doDelete(Manager manager, List<T> ids);
}
