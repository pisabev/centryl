part of cl_base.ctrl;

class Index extends Base {
  Index(req) : super(req);

  Future<void> index() async {
    if (req.session[sessionKey] == null) return page404();
    final settings = req.session[sessionKey]['settings'] ?? {};
    final theme = settings['theme'] ?? 'main';

    String? css;
    if (new File('$path/web/css/$theme.css').existsSync() ||
        new File('$path/web/css/$theme.scss').existsSync())
      css = 'css/$theme.css';

    if (css == null) {
      try {
        await loadResource('centryl/css/$theme.css');
        css = 'packages/centryl/css/$theme.css';
      } catch (e) {
        css = 'packages/centryl/css/main.css';
      }
    }

    String image;
    if (new File('$path/web/images/manifest.json').existsSync()) {
      image = 'images';
    } else {
      image = 'packages/centryl/images';
    }

    final custom = new File('$path/web/app.html');
    final html = custom.existsSync()
        ? await custom.readAsString(encoding: utf8)
        : await loadResource('centryl/templates/app.html');

    responseHtml(
        await new Template(html, lenient: true, htmlEscapeValues: false)
            .renderString({
      'title': appTitle,
      'baseurl': baseURL,
      'css': css,
      'image': image
    }));
  }

  void page404() => responseHtml('Not Found', 404);

  Future init() async {
    final Map<String, dynamic> data = {};
    final params = await getData();
    if (params.isNotEmpty) data.addAll(params);
    data['devmode'] = devmode;
    final bPart = meta.build.split('.').map(int.parse).toList();
    data['build'] =
        new DateTime(bPart[0], bPart[1], bPart[2], bPart[3], bPart[4]);
    data[sessionKey] = req.session[sessionKey];
    for (final f in boot_call) await f(data);
    response(data);
  }
}
