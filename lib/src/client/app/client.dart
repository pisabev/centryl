part of app;

class ClientApp {
  late FutureOr<void> Function(Application ap) init;
}

class Client {
  Map<String, dynamic> data;
  List<ClientApp> apps = [];

  Client(this.data);

  bool get devmode => data['devmode'] ?? true;

  int get userId => data['client']['user_id'];

  int get userGroupId => data['client']['user_group_id'];

  String? get name => data['client']['name'];

  String? get username => data['client']['username'];

  Map? get settings => data['client']['settings'];

  String? get locale => data['client']['settings']['language'];

  String? get session => data['client']['session'];

  String? get picture => data['client']['picture'];

  Map? get permissions => data['client']['permissions'];

  bool checkPermission(String? groupScopeAccess) {
    if (permissions == null || permissions!.isEmpty || groupScopeAccess == null)
      return true;
    final parts = groupScopeAccess.split(':');
    if (parts.length > 2 &&
        permissions!.containsKey(parts[0]) &&
        permissions![parts[0]].containsKey(parts[1]))
      return permissions![parts[0]][parts[1]][parts[2]] ?? false;
    return false;
  }

  void addApp(ClientApp app) => apps.add(app);
}
