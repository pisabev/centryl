part of forms;

abstract class DataElement<T, E extends html.Element> extends CLElementBase<E>
    with Data<T> {
  void setState(bool state) {
    this.state = state;
    super.setState(state);
  }
}
