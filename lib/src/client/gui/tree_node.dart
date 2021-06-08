part of gui;

class TreeNode {
  String? id;
  String? parentId;
  dynamic value;
  dynamic data;
  String? type;
  String? clas;
  late bool hasChilds;

  TreeNode(
      {this.id,
      this.value,
      this.type,
      this.hasChilds = false,
      this.clas,
      this.data});

  TreeNode.fromMap(Map d)
      : id = d['id'],
        parentId = d['parentId'],
        value = d['value'],
        type = d['type'],
        hasChilds = d['hasChilds'],
        clas = d['clas'],
        data = d['data'];
}
