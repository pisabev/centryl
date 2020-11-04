part of cl_base.entity;

@MSerializable()
class APIRemote {
  static const String $api_remote = 'base_api_remote';
  static String get $table => $api_remote;

  int api_remote_id;
  String name;
  String key;
  String host;

  APIRemote();

  void init(Map data) => _$APIRemoteFromMap(this, data);

  Map<String, dynamic> toMap() => _$APIRemoteToMap(this);
  Map<String, dynamic> toJson() => _$APIRemoteToMap(this, true);
}

class APIRemoteCollection<E extends APIRemote> extends Collection<E> {
  List pair() => map((api) => {'k': api.api_remote_id, 'v': api.host}).toList();
}
