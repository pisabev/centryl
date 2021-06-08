part of cl_base.ctrl;

class ResourceNotFoundException implements Exception {
  ResourceNotFoundException() : super();
}

class WorkflowException implements Exception {
  final String Function()? _message;

  String get message => _message != null ? _message!() : '';

  WorkflowException([this._message]) : super();

  String toString() {
    if (_message == null) return 'WorkflowException';
    return 'WorkflowException: $message';
  }
}
