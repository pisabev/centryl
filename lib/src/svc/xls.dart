part of cl_base.svc.server;

class XLS {
  static const String _execute = 'ssconvert';
  final List<int> _bytes_csv;
  final List<int> _bytes_xls;
  final Iterable<Map> _data;

  factory XLS.fromCSVBytes(List<int> data) => new XLS._int(data, null, null);

  factory XLS.fromXLSBytes(List<int> data) => new XLS._int(null, data, null);

  factory XLS.fromMapData(Iterable<Map> data) => new XLS._int(null, null, data);

  XLS._int(this._bytes_csv, this._bytes_xls, this._data);

  Future<File> _createTempFile(String ext) async {
    final p = await new Directory('$path/tmp').exists() ? '$path/tmp' : '.';
    final fn = '$p/___temp${new DateTime.now().microsecondsSinceEpoch}.$ext';
    return new File(fn);
  }

  Future<File> _xlsToCsv() async {
    if (_bytes_xls == null) return null;
    final fileFrom = await _createTempFile('xls');
    await fileFrom.writeAsBytes(_bytes_xls);
    final fileTo = await _createTempFile('csv');

    final res = await Process.run(_execute, [fileFrom.path, fileTo.path]);
    if (res.exitCode > 1 && !fileTo.existsSync())
      throw new Exception(res.stderr);

    await fileFrom.delete();
    return fileTo;
  }

  List<int> toCsv() {
    if (_data != null) {
      const encoder = const csv.ListToCsvConverter();
      final sb = new StringBuffer();

      encoder.convertSingleRow(sb, _data.first.keys.toList());
      for (final r in _data) {
        sb.write(encoder.eol);
        encoder.convertSingleRow(sb, r.values.toList());
      }
      return utf8.encode(sb.toString());
    }
    return null;
  }

  Stream<List<int>> toXls([String ext = 'xls']) async* {
    final fileFrom = await _createTempFile('csv');
    final fileTo = await _createTempFile(ext);
    await fileFrom.writeAsBytes(toCsv());

    final res = await Process.run(_execute, [fileFrom.path, fileTo.path]);
    if (res.exitCode > 1 && !fileTo.existsSync())
      throw new Exception(res.stderr);

    final input = fileTo.openRead();
    await for (final r in input) yield r;

    await fileFrom.delete();
    await fileTo.delete();
  }

  Stream<Map> toMap() async* {
    final title = [];
    var i = 0;
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
      final csvf = await _xlsToCsv();
      final input = csvf.openRead();
      await for (final r
          in utf8.decoder.bind(input).transform(csvCodec.decoder)) {
        if (i == 0) {
          title.addAll(r);
        } else {
          final m = {};
          for (var j = 0; j < r.length; j++) m[title[j]] = r[j];
          yield m;
        }
        i++;
      }
      await csvf.delete();
    }
  }
}
