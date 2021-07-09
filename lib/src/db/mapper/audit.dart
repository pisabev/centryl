part of cl_base.mapper;

class AuditMapper extends Mapper<Audit, AuditCollection> {
  String table = entity.Audit.$table;

  AuditMapper(m) : super(m);

  Future<AuditCollection> findByScope(AuditDTO dto) => loadC(selectBuilder()
    ..where('${entity.$Audit.table_name} = @table',
        '${entity.$Audit.before}->${dto.pkeyValue} = @pkey')
    ..setParameter('table', dto.table)
    ..setParameter('pkey', dto.pkeyValue));
}

class Audit extends entity.Audit with Entity {}

class AuditCollection extends entity.AuditCollection<Audit> {}
