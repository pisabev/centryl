part of cl_base.svc.server;

class Csv {
  List<List> data;

  Csv(this.data);

  String toCsvString({String? fieldDelimiter}) {
    const encoder = const csv.ListToCsvConverter();
    return encoder.convert(data, fieldDelimiter: fieldDelimiter);
  }
}
