abstract interface class KeyValueStore {
  String? getString(String key);
  Future<bool> setString(String key, String value);
  Future<bool> remove(String key);
}
