part of dto;

@DTOSerializable()
class AuditDTO {
  String table;
  String pkey;
  dynamic pkeyValue;

  AuditDTO(this.table, this.pkey, this.pkeyValue);

  factory AuditDTO.fromMap(Map data) => _$AuditDTOFromMap(data);

  Map toMap() => _$AuditDTOToMap(this);

  Map toJson() => toMap();
}
