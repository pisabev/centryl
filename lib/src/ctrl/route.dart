part of cl_base.ctrl;

final Map map = {};

const String AUTHCOOKIENAME = 'CENTRYLSESSID';
const String SESSIONKEY = 'client';

void routesInit(Router router) => router
    .serve(Routes.init, method: 'POST')
    .listen((req) => new Index(req).init());

void routesAnonymous(Router router) {
  router.filter(new UrlPattern(r'(.*)'), (req) async {
    final cookie = req.cookies
        .firstWhere((cookie) => cookie.name == AUTHCOOKIENAME, orElse: () {
      final cookie = new Cookie(AUTHCOOKIENAME, req.session.id);
      req.response.cookies.add(cookie);
      req.cookies.add(cookie);
      req.session[SESSIONKEY] = null;
      return cookie;
    });
    if (map[cookie.value] == null) map[cookie.value] = {'name': 'Anonymous'};
    req.session[SESSIONKEY] = map[cookie.value];
    return new Future.value(true);
  });
}

void routesSync(Router router) {
  router
      .serve(Routes.sync, method: 'POST')
      .listen((req) => new CSync(req).index());
}

void routesFile(Router router) => router
  ..serve(Routes.dirList, method: 'POST')
      .listen((req) => new FileManager(req).getDirs())
  ..serve(Routes.dirListAll, method: 'POST')
      .listen((req) => new FileManager(req).getDirsAll())
  ..serve(Routes.dirAdd, method: 'POST')
      .listen((req) => new FileManager(req).dirAdd())
  ..serve(Routes.dirMove, method: 'POST')
      .listen((req) => new FileManager(req).dirMove())
  ..serve(Routes.dirRename, method: 'POST')
      .listen((req) => new FileManager(req).dirRen())
  ..serve(Routes.dirDelete, method: 'POST')
      .listen((req) => new FileManager(req).dirDel())
  ..serve(Routes.fileList, method: 'POST')
      .listen((req) => new FileManager(req).getFiles())
  ..serve(Routes.fileMove, method: 'POST')
      .listen((req) => new FileManager(req).fileMove())
  ..serve(Routes.fileRename, method: 'POST')
      .listen((req) => new FileManager(req).fileRen())
  ..serve(Routes.fileDelete, method: 'POST')
      .listen((req) => new FileManager(req).fileDel())
  ..serve(Routes.fileRead, method: 'POST')
      .listen((req) => new FileManager(req).fileRead())
  ..serve(Routes.fileCreate, method: 'POST')
      .listen((req) => new FileManager(req).fileCreate())
  ..serve(Routes.fileWrite, method: 'POST')
      .listen((req) => new FileManager(req).fileWrite())
  ..serve(Routes.fileUpload, method: 'POST')
      .listen((req) => new FileManager(req).fileUpload());
