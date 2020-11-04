part of cl_base.ctrl;

class Hint extends Base {
  UrlPattern path;

  Hint(req, this.path) : super(req);

  Map data;

  Future getFrom(Map data) async {
    final params = await getData();
    final key = path.parse(req.uri.path)[0];
    if (data.containsKey(key))
      return response(Intl.withLocale(params['locale'], data[key]));
    else
      return response(key);
  }
}
