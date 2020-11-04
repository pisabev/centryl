part of base;

class DataWarning {
  String key;
  String message;
  int level;

  DataWarning(this.key, this.message, {this.level = 0});
}