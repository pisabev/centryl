part of cl_base.svc.server;

class Pdf {
  String html;
  bool headerFooterShow;
  String? footerTemplate;
  String? headerTemplate;

  static const footerPaginationHtml =
      '<style>#header, #footer { padding: 0 !important; }</style>'
      '<div class="header" style="padding: 10px; width: 100%; '
      'text-align: center; font-size: 10px;"><span class="pageNumber">'
      '</span> / <span class="totalPages"></span>'
      '</div>';

  Pdf(this.html,
      {this.headerFooterShow = false,
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
    final browser = await puppeteer.launch(args: ['--no-sandbox']);
    final page = await browser.newPage();
    await page.setContent(html, wait: Until.networkIdle);

    final fTemplate = footerTemplate ?? '<div></div>';
    final hTemplate = headerTemplate ?? '<div></div>';

    final res = await page.pdf(
        format: PaperFormat.a4,
        printBackground: true,
        displayHeaderFooter: headerFooterShow,
        headerTemplate: hTemplate,
        footerTemplate: fTemplate);
    await browser.close();

    return res?.toList() ?? <int>[];
  }
}
