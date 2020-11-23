part of dto;

@DTOSerializable()
class DataContainer {
  String label;
  String clas;
  List<DataSet> set = [];

  DataContainer();

  factory DataContainer.fromMap(Map data) => _$DataContainerFromMap(data);

  Map toMap() => _$DataContainerToMap(this);

  Map toJson() => toMap();
}

@DTOSerializable()
class DataSet {
  String key;
  num value;

  DataSet(this.key, this.value);

  factory DataSet.fromMap(Map data) => _$DataSetFromMap(data);

  Map toMap() => _$DataSetToMap(this);

  Map toJson() => toMap();
}
