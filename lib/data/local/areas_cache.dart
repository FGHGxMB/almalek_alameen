// lib/data/local/areas_cache.dart

import 'local_storage.dart';

class AreasCache {
  final LocalStorage _localStorage;

  AreasCache(this._localStorage);

  int get localVersion => _localStorage.prefs.getInt('areas_version') ?? 0;

  Future<void> setLocalVersion(int version) async {
    await _localStorage.prefs.setInt('areas_version', version);
  }

  List<String> getAreas() {
    return _localStorage.prefs.getStringList('areas_list') ??[];
  }

  Future<void> saveAreas(List<String> areas) async {
    await _localStorage.prefs.setStringList('areas_list', areas);
  }
}