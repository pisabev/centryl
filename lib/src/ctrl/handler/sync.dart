part of cl_base.ctrl;

class CSync extends Base {
  CSync(req) : super(req);

  Future index() => runDb(null, null, null, (manager) async {
        final c = await manager.app.api_remote.findAll();
        return response(c.pair());
      });
}
