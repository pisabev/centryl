part of cl_base.svc.server;

// Check for dependencies: ldd chrome | grep not

class PaperFormat {
  static const letter = PaperFormat.inches(width: 8.5, height: 11);
  static const legal = PaperFormat.inches(width: 8.5, height: 14);
  static const tabloid = PaperFormat.inches(width: 11, height: 17);
  static const ledger = PaperFormat.inches(width: 17, height: 11);
  static const a0 = PaperFormat.inches(width: 33.1, height: 46.8);
  static const a1 = PaperFormat.inches(width: 23.4, height: 33.1);
  static const a2 = PaperFormat.inches(width: 16.54, height: 23.4);
  static const a3 = PaperFormat.inches(width: 11.7, height: 16.54);
  static const a4 = PaperFormat.inches(width: 8.27, height: 11.7);
  static const a5 = PaperFormat.inches(width: 5.83, height: 8.27);
  static const a6 = PaperFormat.inches(width: 4.13, height: 5.83);

  final num width, height;

  const PaperFormat.inches({required this.width, required this.height});

  PaperFormat.px({required int width, required int height})
      : width = _pxToInches(width),
        height = _pxToInches(height);

  PaperFormat.cm({required num width, required num height})
      : width = _cmToInches(width),
        height = _cmToInches(height);

  PaperFormat.mm({required num width, required num height})
      : width = _mmToInches(width),
        height = _mmToInches(height);

  @override
  String toString() => 'PaperFormat.inches(width: $width, height: $height)';
}

num _pxToInches(num px) => px / 96;

num _cmToInches(num cm) => _pxToInches(cm * 37.8);

num _mmToInches(num mm) => _cmToInches(mm / 10);

class Pdf {
  String html;
  bool headerFooterShow;
  PaperFormat format;
  String? footerTemplate;
  String? headerTemplate;

  static const footerPaginationHtml =
      '<style>#header, #footer { padding: 0 !important; }</style>'
      '<div class="header" style="padding: 10px; width: 100%; '
      'text-align: center; font-size: 10px;"><span class="pageNumber">'
      '</span> / <span class="totalPages"></span>'
      '</div>';

  Pdf(this.html,
      {this.format = PaperFormat.a4,
      this.headerFooterShow = false,
      this.footerTemplate,
      this.headerTemplate});

  Future<File> toPdfFile([String? filename, String? basepath]) async {
    final data = await toPdfBytes();
    basepath ??= '$path/tmp';
    final k = new DateTime.now().microsecondsSinceEpoch;
    filename ??= '$basepath/___temp_$k.pdf';
    return new File('$basepath/$filename').writeAsBytes(data);
  }

  Future<List<int>> toPdfBytes() async {
    final browser = await puppeteer.puppeteer
        .launch(args: ['--no-sandbox', '--disable-setuid-sandbox']);
    final page = await browser.newPage();
    final k = new DateTime.now().microsecondsSinceEpoch;
    final file = await new File('./___temp_$k.html').writeAsString(html);
    await page.goto(file.absolute.uri.toString(),
        wait: puppeteer.Until.networkIdle);

    final fTemplate = footerTemplate ?? '<div></div>';
    final hTemplate = headerTemplate ?? '<div></div>';

    final res = await page.pdf(
        format: puppeteer.PaperFormat.inches(
            width: format.width, height: format.height),
        printBackground: true,
        displayHeaderFooter: headerFooterShow,
        headerTemplate: hTemplate,
        footerTemplate: fTemplate);
    await browser.close();
    await file.delete();

    return res?.toList() ?? <int>[];
  }
}
