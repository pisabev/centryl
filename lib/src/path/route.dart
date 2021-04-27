part of path;

class Routes {
  static UrlPattern get ws => new UrlPattern(r'/ws');

  static UrlPattern get init => new UrlPattern(r'/init');

  static UrlPattern get sync => new UrlPattern(r'/sync');

  static UrlPattern get upload => new UrlPattern(r'/upload');

  static UrlPattern get dirList => new UrlPattern(r'/folder/list');

  static UrlPattern get dirListAll => new UrlPattern(r'/folder/listAll');

  static UrlPattern get dirAdd => new UrlPattern(r'/folder/add');

  static UrlPattern get dirMove => new UrlPattern(r'/folder/move');

  static UrlPattern get dirRename => new UrlPattern(r'/folder/rename');

  static UrlPattern get dirDelete => new UrlPattern(r'/folder/delete');

  static UrlPattern get fileList => new UrlPattern(r'/file/list');

  static UrlPattern get fileMove => new UrlPattern(r'/file/move');

  static UrlPattern get fileRename => new UrlPattern(r'/file/rename');

  static UrlPattern get fileDelete => new UrlPattern(r'/file/delete');

  static UrlPattern get fileRead => new UrlPattern(r'/file/content');

  static UrlPattern get fileCreate => new UrlPattern(r'/file/create');

  static UrlPattern get fileWrite => new UrlPattern(r'/file/write');

  static UrlPattern get fileUpload => new UrlPattern(r'/file/upload');

  static const String eventServerStop = 'system:platform:stop';
  static const String eventServerStart = 'system:platform:start';
  static const String eventServerUpdate = 'system:platform:update';
  static const String eventServerUpdater = 'system:platform:updater';
}

abstract class $RunRights {
  static const String read = 'read';
  static const String create = 'create';
  static const String update = 'update';
  static const String delete = 'delete';
  static const String export = 'export';
  static const String lock = 'lock';
}

abstract class $BaseConsts {
  static const String get_before = 'get_before';
  static const String get_after = 'get_after';
  static const String del_before = 'del_before';
  static const String del_after = 'del_after';
  static const String print_before = 'print_before';

  static const String ids = 'ids';
  static const String id = 'id';
  static const String filter = 'filter';
  static const String order = 'order';
  static const String paginator = 'paginator';
  static const String language_id = 'language_id';
  static const String print = 'print';
  static const String export = 'export';
  static const String result = 'result';
  static const String check = 'check';
  static const String clear = 'clear';
  static const String cache = 'cache';
  static const String keyup = 'keyup';
  static const String total = 'total';
  static const String field = 'field';
  static const String way = 'way';
  static const String page = 'page';
  static const String limit = 'limit';
  static const String suggestion = 'suggestion';

  static const String insert = 'insert';
  static const String update = 'update';
  static const String delete = 'delete';
  static const String source = 'source';
}

class DocumentBase {
  late String prefix = '';
  late int padchars = 10;

  String encode(dynamic number) =>
      (number is num) ? prefix + pad(number) : prefix + number.toString();

  String get padZeros {
    final s = new StringBuffer();
    for (int i = 0; i < padchars; i++) s.write('0');
    return s.toString();
  }

  String pad(num number) => new NumberFormat(padZeros).format(number);

  int? decode(String string) {
    if (string.startsWith(prefix))
      return int.tryParse(string.replaceFirst(new RegExp(prefix), ''));
    return int.tryParse(string);
  }
}
