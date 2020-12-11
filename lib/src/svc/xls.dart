part of cl_base.svc.server;

class XLS {
  final List<int> _bytes_csv;
  final List<int> _bytes_xls;
  final Iterable<Map> _data;

  factory XLS.fromCSVBytes(List<int> data) => new XLS._int(data, null, null);

  factory XLS.fromXLSBytes(List<int> data) => new XLS._int(null, data, null);

  factory XLS.fromMapData(Iterable<Map> data) => new XLS._int(null, null, data);

  XLS._int(this._bytes_csv, this._bytes_xls, this._data);

  List<int> toCsv() {
    if (_data == null) return null;
    const encoder = const csv.ListToCsvConverter();
    final sb = new StringBuffer();

    encoder.convertSingleRow(sb, _data.first.keys.toList());
    for (final r in _data) {
      sb.write(encoder.eol);
      encoder.convertSingleRow(sb, r.values.toList());
    }
    return utf8.encode(sb.toString());
  }

  Future<List<int>> toXls([String ext = 'xlsx']) async {
    if (_data == null) return null;
    final excel = xls.Excel.createExcel();
    final sheet = excel[await excel.getDefaultSheet()]
      ..appendRow(_data.first.keys.toList());
    sheet.row(0).forEach((cell) {
      cell.cellStyle = xls.CellStyle(
          backgroundColorHex: '#666666',
          fontColorHex: '#FFFFFF',
          bold: true,
          fontFamily: 'arial');
    });
    _data.forEach((row) => sheet.appendRow(row.values.toList()));

    return excel.encode();
  }

  Stream<Map> toMap() async* {
    final title = [];
    int i = 0;
    final csvCodec = new csv.CsvCodec(eol: '\n');
    if (_bytes_csv != null) {
      final l = csvCodec.decoder.convert(utf8.decode(_bytes_csv));
      for (final r in l) {
        if (i == 0) {
          title.addAll(r);
        } else {
          final m = {};
          for (var j = 0; j < r.length; j++) m[title[j]] = r[j];
          yield m;
        }
        i++;
      }
    } else {
      final excel = xls.Excel.decodeBytes(_bytes_xls);
      int i = 0;
      for (final r in excel.tables.values.first.rows) {
        if (i == 0) {
          title.addAll(r);
        } else {
          final m = {};
          for (var j = 0; j < r.length; j++) m[title[j]] = r[j];
          yield m;
        }
        i++;
      }
    }
  }
}
