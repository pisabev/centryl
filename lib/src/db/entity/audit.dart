part of cl_base.entity;

@MSerializable()
class Audit {
  static const String $audit = 'base_audit';

  static String get $table => $audit;

  DateTime? audit_ts;
  String? table_name;
  String? operation;
  Map? before;
  Map? after;

  Audit();

  void init(Map data) => _$AuditFromMap(this, data);

  Map<String, dynamic> toMap() => _$AuditToMap(this);

  Map<String, dynamic> toJson() => _$AuditToMap(this, true);
}

class AuditCollection<E extends Audit> extends Collection<E> {}
