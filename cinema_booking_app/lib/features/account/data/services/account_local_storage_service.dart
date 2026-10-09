import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../domain/entities/customer_profile.dart';

class AccountLocalStorageService {
  AccountLocalStorageService._();
  AccountLocalStorageService.testing() : this._();

  static final AccountLocalStorageService instance =
      AccountLocalStorageService._();

  static const _fileName = 'profiles_cache.json';

  Future<File> _cacheFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}${Platform.pathSeparator}$_fileName');
  }

  Future<Map<String, dynamic>> _readProfiles() async {
    final file = await _cacheFile();
    if (!await file.exists()) return {};
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return {};
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    } on FormatException {
      return {};
    }
  }

  Future<void> _writeProfiles(Map<String, dynamic> profiles) async {
    final file = await _cacheFile();
    await file.writeAsString(jsonEncode(profiles), flush: true);
  }

  Future<void> saveProfile(CustomerProfile profile) async {
    final profiles = await _readProfiles();
    profiles[profile.username] = profile.toJson();
    await _writeProfiles(profiles);
  }

  Future<CustomerProfile?> getProfile(String username) async {
    final data = (await _readProfiles())[username];
    return data is Map
        ? CustomerProfile.fromJson(Map<String, dynamic>.from(data))
        : null;
  }

  Future<void> updateProfile(CustomerProfile profile) => saveProfile(profile);
}
