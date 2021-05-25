part of cl_base.svc.server;

class TreeItem {
  String? type;
  String? value;
  dynamic id;
  dynamic parentId;
  String? clas;
  bool? hasChilds;
  dynamic data;

  Map toMap() => {
        'type': type,
        'value': value,
        'id': id,
        'parentId': parentId,
        'clas': clas,
        'hasChilds': hasChilds,
        'data': data
      };

  Map toJson() => toMap();
}

abstract class TreeType {
  mapper.Manager manager;

  List<TreeItem> rows = [];

  mapper.Builder query;

  TreeType(this.manager, this.query);

  Stream<TreeItem> execute() async* {
    final r = await manager.execute(query);
    for (final row in r) yield await setRow(row);
  }

  Future<TreeItem> setRow(Map r);
}

class TreeBuilder {
  List<TreeType> types;

  TreeBuilder(this.types);

  Stream<TreeItem> getResult() async* {
    for (final treeType in types) {
      await for (final tree in treeType.execute()) yield tree;
    }
  }
}
