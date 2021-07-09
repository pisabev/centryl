part of cl_base.ctrl;

class CAudit extends Base {
  CAudit(req) : super(req);

  Future getByScope() => runDb(null, null, null, (manager) async {
        final params = await getData();
        final dto = new AuditDTO.fromMap(params);
        final c = await manager.app.audit.findByScope(dto);
        return response(c);
      });
}
