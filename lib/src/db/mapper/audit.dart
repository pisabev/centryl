part of cl_base.mapper;

class AuditMapper extends Mapper<Audit, AuditCollection> {
  String table = entity.Audit.$table;

  AuditMapper(m) : super(m);

}

class Audit extends entity.Audit with Entity {}

class AuditCollection extends entity.AuditCollection<Audit> {}
