part of cl_base.svc.server;

class Pdf {
  static String _executable;
  String html;

  Pdf(this.html);

  Future<File> toPdfFile([String filename, String basepath]) async {
    basepath ??= '$path/tmp';
    final k = new DateTime.now().microsecondsSinceEpoch;
    filename ??= '$basepath/___temp_$k.pdf';
    final fileHtml = '$basepath/___temp_$k.html';
    final file = await new File(fileHtml).writeAsString(html);
    final args = <String>[
      '--no-sandbox',
      '--headless',
      '--disable-gpu',
      '--print-to-pdf=$basepath/$filename',
      fileHtml
    ];
    if (_executable == null) {
      final v =
          await Process.run('command', ['-v', 'chromium'], runInShell: true);
      _executable =
          v.stdout.toString().trim().isNotEmpty ? 'chromium' : 'google-chrome';
    }
    final res = await Process.run(_executable, args);
    await file.delete();
    if (res.stderr.toString().trim().isNotEmpty && res.exitCode != 0)
      throw new Exception(res.stderr);
    if (res.stdout.toString().trim().isNotEmpty)
      throw new Exception(res.stdout);
    return new File('$basepath/$filename');
  }

  Future<List<int>> toPdfBytes() async {
    final f = await toPdfFile(null, '.');
    final data = await f.readAsBytes();
    await f.delete();
    return data;
  }
}
