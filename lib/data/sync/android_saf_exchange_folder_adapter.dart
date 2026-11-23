import 'dart:convert';
import 'dart:typed_data';

import 'package:calendar_notes/core/ids/stable_id.dart';
import 'package:calendar_notes/data/sync/exchange_folder_adapter.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Android-only adapter backed by ACTION_OPEN_DOCUMENT_TREE. The native side
/// stores the persisted content URI; this class never treats it as a file path.
class AndroidSafExchangeFolderAdapter implements ExchangeFolderAdapter {
  AndroidSafExchangeFolderAdapter({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(_channelName);

  static const String _channelName = 'dev.cisiur.calendarnotes/exchange_folder';
  static const String _deviceIdKey = 'exchange_folder.diagnostic_device_id';

  final MethodChannel _channel;
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  @override
  Future<ExchangeFolderStatus> checkAccess() async {
    try {
      final Map<Object?, Object?>? result =
          await _channel.invokeMapMethod<Object?, Object?>('checkAccess');
      return result == null
          ? _unavailable('Brak odpowiedzi z adaptera SAF.')
          : _statusFromMap(result);
    } on PlatformException catch (error) {
      return _unavailable(error.message ?? error.code);
    } on MissingPluginException {
      return _unavailable('Kanał SAF nie jest dostępny na tej platformie.');
    }
  }

  @override
  Future<ExchangeFolderStatus> selectFolder() async {
    try {
      final Map<Object?, Object?>? result =
          await _channel.invokeMapMethod<Object?, Object?>('selectFolder');
      return result == null
          ? _unavailable('Brak odpowiedzi z adaptera SAF.')
          : _statusFromMap(result);
    } on PlatformException catch (error) {
      return _unavailable(error.message ?? error.code);
    } on MissingPluginException {
      return _unavailable('Kanał SAF nie jest dostępny na tej platformie.');
    }
  }

  @override
  Future<List<ExchangeFileInfo>> listOwnTestFiles() async {
    final List<Object?> result = await _channel.invokeListMethod<Object?>(
      'listOwnTestFiles',
      <String, Object?>{'prefix': await _ownPrefix()},
    ) ?? <Object?>[];
    return result
        .cast<Map<Object?, Object?>>()
        .map(
          (Map<Object?, Object?> item) => ExchangeFileInfo(
            name: item['name']! as String,
            sizeBytes: item['sizeBytes']! as int,
          ),
        )
        .toList();
  }

  @override
  Future<ExchangeWriteResult> writeOnce({
    required String name,
    required Uint8List contents,
    required String expectedSha256,
  }) async {
    _requireOwnName(name, await _ownPrefix());
    final Map<Object?, Object?>? result = await _channel.invokeMapMethod<Object?, Object?>(
      'writeOnce',
      <String, Object?>{
        'name': name,
        'contents': base64Encode(contents),
        'expectedSha256': expectedSha256,
        'prefix': await _ownPrefix(),
      },
    );
    if (result == null) {
      throw const ExchangeFolderException('Brak odpowiedzi po zapisie SAF.');
    }
    return ExchangeWriteResult(
      name: result['name']! as String,
      sizeBytes: result['sizeBytes']! as int,
      sha256: result['sha256']! as String,
      usedStagedRename: false,
    );
  }

  @override
  Future<ExchangeReadVerification> readAndVerify({
    required String name,
    required String expectedSha256,
  }) async {
    _requireOwnName(name, await _ownPrefix());
    final Map<Object?, Object?>? result = await _channel.invokeMapMethod<Object?, Object?>(
      'readAndVerify',
      <String, Object?>{
        'name': name,
        'expectedSha256': expectedSha256,
        'prefix': await _ownPrefix(),
      },
    );
    if (result == null) {
      throw const ExchangeFolderException('Brak odpowiedzi po odczycie SAF.');
    }
    return ExchangeReadVerification(
      name: result['name']! as String,
      sizeBytes: result['sizeBytes']! as int,
      actualSha256: result['actualSha256']! as String,
      hashMatches: result['hashMatches']! as bool,
    );
  }

  @override
  Future<ExchangeDeleteResult> deleteOwnTestFile(String name) async {
    _requireOwnName(name, await _ownPrefix());
    final Map<Object?, Object?>? result = await _channel.invokeMapMethod<Object?, Object?>(
      'deleteOwnTestFile',
      <String, Object?>{'name': name, 'prefix': await _ownPrefix()},
    );
    if (result == null) {
      throw const ExchangeFolderException('Brak odpowiedzi po usunięciu SAF.');
    }
    return ExchangeDeleteResult(
      name: result['name']! as String,
      deleted: result['deleted']! as bool,
    );
  }

  ExchangeFolderStatus _statusFromMap(Map<Object?, Object?> value) {
    return ExchangeFolderStatus(
      kind: ExchangeFolderKind.androidSafTree,
      isSelected: value['isSelected']! as bool,
      canRead: value['canRead']! as bool,
      canWrite: value['canWrite']! as bool,
      canList: value['canList']! as bool,
      supportsStagedRename: false,
      atomicRenameVerified: false,
      location: value['uri'] as String?,
      provider: value['provider'] as String?,
      error: value['error'] as String?,
    );
  }

  ExchangeFolderStatus _unavailable(String error) => ExchangeFolderStatus(
        kind: ExchangeFolderKind.androidSafTree,
        isSelected: false,
        canRead: false,
        canWrite: false,
        canList: false,
        supportsStagedRename: false,
        atomicRenameVerified: false,
        error: error,
      );

  Future<String> _ownPrefix() async {
    final String? existing = await _preferences.getString(_deviceIdKey);
    final String id;
    if (existing != null && StableId.isValid(existing)) {
      id = existing;
    } else {
      id = StableId.newId();
      await _preferences.setString(_deviceIdKey, id);
    }
    return 'calendarnotes-diagnostic-$id-';
  }

  void _requireOwnName(String name, String prefix) {
    if (!name.startsWith(prefix) ||
        name.contains('/') ||
        name.contains('\\') ||
        name.contains('..')) {
      throw const ExchangeFolderException('Niedozwolona nazwa pliku testowego.');
    }
  }
}
