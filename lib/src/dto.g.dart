// GENERATED CODE - DO NOT MODIFY BY HAND

part of dto;

// **************************************************************************
// DTOSerializableGenerator
// **************************************************************************

abstract class $DataContainer {
  static const String label = 'label';
  static const String clas = 'clas';
  static const String set = 'set';
}

DataContainer _$DataContainerFromMap(Map data) => new DataContainer()
  ..label = data[$DataContainer.label]
  ..clas = data[$DataContainer.clas]
  ..set = (data[$DataContainer.set] as List)
      ?.map((v0) => v0 == null ? null : new DataSet.fromMap(v0))
      ?.toList();

Map<String, dynamic> _$DataContainerToMap(DataContainer obj) =>
    <String, dynamic>{
      $DataContainer.label: obj.label,
      $DataContainer.clas: obj.clas,
      $DataContainer.set: obj.set == null
          ? null
          : new List.generate(obj.set.length, (i0) => obj.set[i0]?.toMap())
    };

abstract class $DataSet {
  static const String key = 'key';
  static const String value = 'value';
}

DataSet _$DataSetFromMap(Map data) =>
    new DataSet(data[$DataSet.key], data[$DataSet.value]);

Map<String, dynamic> _$DataSetToMap(DataSet obj) =>
    <String, dynamic>{$DataSet.key: obj.key, $DataSet.value: obj.value};
