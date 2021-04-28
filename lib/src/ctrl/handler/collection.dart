part of cl_base.ctrl;

abstract class Collection<E extends Entity, T> extends Base {
  String? group;

  String? scope;

  Collection(req, [this.group, this.scope]) : super(req);

  void get() => run(group, scope, $RunRights.read, () async {
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
        manager = await new Database().init();
        final cb = await doGet(filter, order, paginator);
        final r = <Map>[];
        for (final o in cb.collection) r.add(await lister(o as E));
        response({$BaseConsts.total: cb.total, $BaseConsts.result: r});
      });

  void delete() => run(group, scope, $RunRights.delete, () async {
        final params = await getData();
        manager = await new Database().init();
        response(await doDelete(params[$BaseConsts.ids].cast<T>()));
      });

  Future<Map> lister(E o) async => o.toJson();

  Future<CollectionBuilder> doGet(
      Map<String, dynamic> filter, Map order, Map paginator);

  Future<bool> doDelete(List<T> ids);
}
