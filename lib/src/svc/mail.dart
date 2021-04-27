part of cl_base.svc.server;

class Mail {
  late SmtpServer _transport;
  late mailer.Message _message;

  Mail([SmtpServer? transport]) {
    _transport = transport ?? new SmtpServer('localhost', port: 25);
    _message = new mailer.Message();
  }

  void from(String from, [String? name]) {
    _message.from = new mailer.Address(from, name);
  }

  void to(dynamic recipient) {
    if (recipient is List)
      _message.recipients = recipient;
    else
      _message.recipients.add(recipient);
  }

  static bool validate(dynamic mail) => new RegExp(
          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}"
          r'[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$')
      .hasMatch(mail);

  void setSubject(String subject) => _message.subject = subject;

  void setHtml(String html) => _message.html = html;

  void setText(String text) => _message.text = text;

  void addFile(dynamic source, String fileName) {
    if (source is String)
      _message.attachments
          .add(new mailer.FileAttachment(new File(source), fileName: fileName));
    else if (source is List)
      _message.attachments.add(new mailer.StreamAttachment(
          new Stream.fromIterable([source as List<int>]), 'application/octet-stream',
          fileName: fileName));
  }

  Future<bool> send({bool devmodeBased = true}) async {
    final checked = _message.recipients.where(validate).toList();
    if (checked.isEmpty) return false;
    _message.recipients = checked;
    if (devmodeBased && devmode) {
      log.info('Mail Sent'
          '\nSubject: ${_message.subject}'
          '\nFrom: ${_message.from.mailAddress}'
          '\nTo: ${_message.recipients.join(', ')}'
          '\nMessage (text): ${_message.text}'
          '\nMessage (html): ${_message.html}'
          '\nAttachments: '
          '${_message.attachments.map((a) => a.fileName).join(',')}');
      return true;
    }
    return mailer.send(_message, _transport).then((_) => true);
  }
}
