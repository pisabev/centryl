part of cl_base.entity;

@MSerializable()
class APILocal {
  static const String $api_local = 'base_api_local';

  static String get $table => $api_local;

  int? api_local_id;
  String? name;
  String? key;
  int? limit;
  bool? active;

  APILocal();

  void init(Map data) => _$APILocalFromMap(this, data);

  Map<String, dynamic> toMap() => _$APILocalToMap(this);

  Map<String, dynamic> toJson() => _$APILocalToMap(this, true);
}

class APILocalCollection<E extends APILocal> extends Collection<E> {
  List pair() => map((api) => {'k': api.api_local_id, 'v': api.name}).toList();
}
