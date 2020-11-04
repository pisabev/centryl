part of cl_base.mapper;

class CacheMapper extends Mapper<Cache, CacheCollection> {
  String table = entity.Cache.$table;
  dynamic pkey = entity.$Cache.key;

  CacheMapper(m) : super(m);

  Future<CacheCollection> findAllWithExpire() =>
      loadC(selectBuilder()..where('${entity.$Cache.expire} IS NOT NULL'));
}

class Cache extends entity.Cache with Entity {}

class CacheCollection extends entity.CacheCollection<Cache> {}
