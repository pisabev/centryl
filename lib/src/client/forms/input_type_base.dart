part of forms;

abstract class _InputTypeBase<T> {
  T? value;
  void set(dynamic v);
  String toString();
  FutureOr<bool> validateValue(T v);
  FutureOr<bool> validateInput(html.KeyboardEvent e);
}
