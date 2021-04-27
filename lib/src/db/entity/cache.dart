part of cl_base.entity;

@MSerializable()
class Cache {
  static const String $cache = 'base_cache';

  static String get $table => $cache;

  late String key;
  Map? value;
  late DateTime expire;

  Cache();

  void init(Map data) => _$CacheFromMap(this, data);

  Map<String, dynamic> toMap() => _$CacheToMap(this);

  Map<String, dynamic> toJson() => _$CacheToMap(this, true);
}

class CacheCollection<E extends Cache> extends Collection<E> {}
