part of cl_base.mapper;

class APILocalMapper extends Mapper<APILocal, APILocalCollection> {
  String table = entity.APILocal.$table;
  dynamic pkey = entity.$APILocal.api_local_id;

  APILocalMapper(m) : super(m);

  Future<APILocal?> findByKey(String key) => loadE(selectBuilder()
    ..where('${entity.$APILocal.key} = @key')
    ..setParameter('key', key));

  Future<APILocalCollection> findBySuggestion(String sug, [int limit = 10]) =>
      loadC(selectBuilder()
        ..where('${entity.$APILocal.name} ILIKE @s')
        ..setParameter('s', '$sug%')
        ..limit(limit));
}

class APILocal extends entity.APILocal with Entity {}

class APILocalCollection extends entity.APILocalCollection<APILocal> {}
