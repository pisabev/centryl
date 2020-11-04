part of cl_base.svc.server;

class VCalendar {
  String PRODID;
  String CALSCALE;
  String VERSION;

  List<String> ics_content;

  List<VElement> elements = [];

  VCalendar();

  Future<void> readFile(File file) async {
    ics_content = await file.readAsLines();
  }

  void readUrl(String url) {
    ics_content = [];
  }

  void parse() {
    final lines_normalized = [];
    ics_content.forEach((line) {
      final pattern = new RegExp(r'\s');
      if (line.startsWith(pattern))
        lines_normalized[lines_normalized.length - 1] +=
            line.replaceFirst(pattern, '');
      else
        lines_normalized.add(line);
    });

    if (lines_normalized.removeAt(0) != 'BEGIN:VCALENDAR') return;
    if (lines_normalized.removeLast() != 'END:VCALENDAR') return;

    VElement element;
    lines_normalized.forEach((line) {
      if (line.startsWith('END:')) return;

      final types = ['BEGIN:VEVENT'];
      if (types.contains(line)) {
        element = new VElement();
        elements.add(element);
      }

      final pairs = _readPairs(line);

      if (element != null)
        element.decodePair(pairs[0], pairs[1]);
      else
        decodePair(pairs[0], pairs[1]);
    });
  }

  void decodePair(String key, String value) {
    switch (key) {
      case 'PRODID':
        PRODID = value;
        break;
      case 'CALSCALE':
        CALSCALE = value;
        break;
      case 'VERSION':
        VERSION = value;
        break;
    }
  }

  List<String> _readPairs(String line) {
    final pattern = new RegExp(r'([^:]+)[:]([\w\W]*)');
    final match = pattern.firstMatch(line);
    if (match != null) return [match[1], match[2]];
    return null;
  }
}

class VElement {
  String TYPE;

  DateTime DTSTART;
  DateTime DTEND;
  DateTime DTSTAMP;
  DateTime CREATED;
  String UID;
  String DESCRIPTION;
  String URL;
  String TRANSP;
  String SUMMARY;
  String LOCATION;
  Map RRULE;

  void decodePair(String key, String value) {
    switch (key) {
      case 'SUMMARY':
        SUMMARY = decode(value);
        break;
      case 'DESCRIPTION':
        DESCRIPTION = decode(value);
        break;
      case 'UID':
        UID = decode(value);
        break;
      case 'URL':
        URL = decode(value);
        break;
      case 'TRANSP':
        TRANSP = decode(value);
        break;
      case 'DTSTART':
        DTSTART = decodeDate(value);
        break;
      case 'DTSTART;VALUE=DATE':
        DTSTART = decodeDate(value);
        break;
      case 'DTEND':
        DTSTART = decodeDateTime(value);
        break;
      case 'DTEND;VALUE=DATE':
        DTSTART = decodeDate(value);
        break;
      case 'DTSTAMP':
        DTSTART = decodeDateTime(value);
        break;
      case 'DTSTAMP;VALUE=DATE':
        DTSTART = decodeDate(value);
        break;
      case 'CREATED':
        CREATED = decodeDateTime(value);
        break;
      case 'RRULE':
        RRULE = decodeRrule(value);
        break;
    }
  }

  DateTime decodeDate(String value) {
    DateTime date;
    final date_pattern = new RegExp(r'^(\d{4})(\d{2})(\d{2})$');
    final match = date_pattern.firstMatch(value);
    if (match != null) {
      date = new DateTime(
          int.parse(match[1]), int.parse(match[2]), int.parse(match[3]));
    }
    return date;
  }

  DateTime decodeDateTime(String value) {
    DateTime date;
    final date_pattern =
        new RegExp(r'^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})(Z)?$');
    final match = date_pattern.firstMatch(value);
    if (match != null) {
      if (match[7] == 'Z') {
        date = new DateTime.utc(
            int.parse(match[1]),
            int.parse(match[2]),
            int.parse(match[3]),
            int.parse(match[4]),
            int.parse(match[5]),
            int.parse(match[6]));
      } else {
        date = new DateTime(
            int.parse(match[1]),
            int.parse(match[2]),
            int.parse(match[3]),
            int.parse(match[4]),
            int.parse(match[5]),
            int.parse(match[6]));
      }
    }
    return date;
  }

  String DateTimeToString(DateTime date) {
    var date_string = date.toIso8601String().split('.').first;

    date_string = date_string.replaceAll('-', '').replaceAll(':', '');

    if (date.isUtc) date_string += 'Z';
    return date_string;
  }

  String DateToString(DateTime date) => '${date.year}${date.month}${date.day}';

  int decodeInt(String value) => int.parse(value);

  String decode(String value) => value;

  Map decodeRrule(String value) {
    String FREQ;
    int INTERVAL;
    int COUNT;
    DateTime UNTIL;

    value.split(';').forEach((declaration) {
      final parts = declaration.split('=');
      switch (parts[0]) {
        case 'FREQ':
          FREQ = parts[1];
          break;
        case 'INTERVAL':
          INTERVAL = decodeInt(parts[1]);
          break;
        case 'COUNT':
          COUNT = decodeInt(parts[1]);
          break;
        case 'UNTIL':
          UNTIL = decodeDateTime(parts[1]);
          break;
      }
    });

    return {'FREQ': FREQ, 'INTERVAL': INTERVAL, 'COUNT': COUNT, 'UNTIL': UNTIL};
  }

  String writeBuffer(String key, String value) {
    const max_chars = 75;
    final data = '$key:$value';
    if (data.length < (max_chars + 1)) return data;
    final sb = new StringBuffer();
    for (var i = 0; i < data.length; i++) {
      sb.write(data[i]);
      if (i > 0 && i % (max_chars - 1) == 0)
        sb
          ..writeln()
          ..write(' ');
    }
    return sb.toString();
  }

  String toString() {
    final sb = new StringBuffer()
      ..writeln('BEGIN:VEVENT')
      ..writeln('DTSTART:${DateTimeToString(DTSTART)}')
      ..writeln('DTEND:${DateTimeToString(DTEND)}')
      ..writeln('DTSTAMP:${DateTimeToString(DTSTAMP)}');
    if (CREATED != null) sb.writeln('CREATED:${DateTimeToString(CREATED)}');
    if (SUMMARY != null) sb.writeln('${writeBuffer('SUMMARY', SUMMARY)}');
    if (DESCRIPTION != null)
      sb.writeln('${writeBuffer('DESCRIPTION', DESCRIPTION)}');
    if (UID != null) sb.writeln('${writeBuffer('UID', UID)}');
    if (URL != null) sb.writeln('${writeBuffer('URL', URL)}');
    sb.writeln('BEGIN:END');
    return sb.toString();
  }
}
