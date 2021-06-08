part of app;

class Route {
  String templ;
  final RegExp pat = new RegExp(r'(:int)|(:string)');
  Function func;

  Route(this.templ, this.func);

  String getRoute() =>
      templ.replaceAll(':int', '(\\d+)').replaceAll(':string', '([^/]+)');

  static bool match(Pattern p, String str) {
    final iter = p.allMatches(str).iterator;
    if (iter.moveNext()) {
      final match = iter.current;
      return (match.start == 0) &&
          (match.end == str.length) &&
          (!iter.moveNext());
    }
    return false;
  }

  List parse(String test) {
    final tmplString = getRoute();
    final pattern = new RegExp(tmplString);
    final typeList = pat.allMatches(templ).map((m) => m[0]).toList();
    final params = [];

    pattern.allMatches(test).forEach((m) {
      for (var i = 0; i < m.groupCount; i++) {
        final v = m.group(i + 1);
        params.add((typeList[i] == ':int') ? int.parse(v!) : v);
      }
    });
    return params;
  }

  String reverse([List? params]) {
    var k = 0;
    if (params == null) return templ;
    return templ.replaceAllMapped(pat, (m) => params[k++].toString());
  }
}
