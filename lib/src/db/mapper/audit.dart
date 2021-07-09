part of cl_base.mapper;

class AuditMapper extends Mapper<Audit, AuditCollection> {
  String table = entity.Audit.$table;

  AuditMapper(m) : super(m);

  Future<AuditCollection> findByScope(AuditDTO dto) async =>
      loadC(selectBuilder()
        ..where('${entity.$Audit.table_name} = @table')
        ..andWhere('${entity.$Audit.before}->\'${dto.pkey}\' = @pkey '
            'OR ${entity.$Audit.after}->\'${dto.pkey}\' = @pkey')
        ..setParameter('table', dto.table)
        ..setParameter('pkey', dto.pkeyValue)
        ..orderBy(entity.$Audit.audit_ts, 'DESC'));
}

class Audit extends entity.Audit with Entity {}

class AuditCollection extends entity.AuditCollection<Audit> {}
