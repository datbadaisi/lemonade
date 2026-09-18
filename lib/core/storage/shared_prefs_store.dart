import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_store.dart';

final class SharedPrefsStore implements KeyValueStore {
  const SharedPrefsStore(this._preferences);

  final SharedPreferences _preferences;

  static Future<SharedPrefsStore> create() async =>
      SharedPrefsStore(await SharedPreferences.getInstance());

  @override
  String? getString(String key) => _preferences.getString(key);

  @override
  Future<bool> remove(String key) => _preferences.remove(key);

  @override
  Future<bool> setString(String key, String value) =>
      _preferences.setString(key, value);
}
