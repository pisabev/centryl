part of utils;

class ClientPath {
  final String _path;
  List<String> _parts;
  List<String> _varTypes;
  String _list;

  ClientPath(this._path) {
    _varTypes = getVars;
  }

  String get path => _path;

  List<String> get getVars {
    _parts = path.trim().split('/');
    final vars = <String>[];

    _parts.forEach((el) {
      if (el[0] == ':') vars.add(el.substring(1));
    });

    return vars;
  }

  String get list {
    if (_list != null) return _list;

    final retParts = <String>[];
    for (var i = 0; i < _parts.length; i++)
      if (_parts[i][0] == ':')
        retParts.add('list');
      else
        retParts.add(_parts[i]);

    return _list = retParts.join('/');
  }

  String renderPath(List vars) {
    if (vars.length != _varTypes.length)
      throw new Exception('Invalid parameter length!');

    final retParts = <String>[];
    var j = 0;
    for (var i = 0; i < _parts.length; i++) {
      if (_parts[i][0] == ':') {
        //Render null => list
        //Add null var for consistency if parameter is not added
        if (vars.length == j) vars.add(null);
        if (vars[j] == null)
          retParts.add('list');
        else {
          //Render -1 => :int // :num or whatever it is in source
          if (vars[j] == -1)
            retParts.add(':${_varTypes[j]}');
          else
            retParts.add(vars[j].toString());
        }
        j++;
      } else
        retParts.add(_parts[i]);
    }

    return retParts.join('/');
  }
}
