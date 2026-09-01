class HiveManager {
  static final HiveManager _instance = HiveManager._internal();

  factory HiveManager() {
    return _instance;
  }
  HiveManager._internal();
  late final HiveManager _hive;
}
