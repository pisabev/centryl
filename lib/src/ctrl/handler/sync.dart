part of cl_base.ctrl;

class CSync extends Base {
  CSync(req) : super(req);

  Future index() => run(null, null, null, () async {
        manager = await new Database().init();
        final c = await manager!.app.api_remote.findAll();
        return response(c.pair());
      });
}
