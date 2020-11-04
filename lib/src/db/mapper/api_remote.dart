part of cl_base.mapper;

class APIRemoteMapper extends Mapper<APIRemote, APIRemoteCollection> {
  String table = entity.APIRemote.$table;
  dynamic pkey = entity.$APIRemote.api_remote_id;

  APIRemoteMapper(m) : super(m);

  Future<APIRemote> findByKey(String key) => loadE(selectBuilder()
    ..where('${entity.$APIRemote.key} = @key')
    ..setParameter('key', key));

  Future<APIRemote> findByHost(String host) => loadE(selectBuilder()
    ..where('${entity.$APIRemote.host} = @host')
    ..setParameter('host', host));

  Future<APIRemoteCollection> findBySuggestion(String sug, [int limit = 10]) =>
      loadC(selectBuilder()
        ..where('${entity.$APIRemote.name} ILIKE @s')
        ..setParameter('s', '$sug%')
        ..limit(limit));
}

class APIRemote extends entity.APIRemote with Entity {}

class APIRemoteCollection extends entity.APIRemoteCollection<APIRemote> {}
