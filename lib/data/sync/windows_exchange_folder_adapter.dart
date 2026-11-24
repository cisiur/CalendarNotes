import 'dart:io';
import 'dart:typed_data';

import 'package:calendar_notes/core/ids/stable_id.dart';
import 'package:calendar_notes/data/sync/exchange_folder_adapter.dart';
import 'package:calendar_notes/data/sync/file_system_exchange_folder_adapter.dart';
import 'package:file_selector/file_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Windows directory chooser and persisted selection. It is intentionally
/// unavailable on Android: Android must use [AndroidSafExchangeFolderAdapter].
class WindowsExchangeFolderAdapter implements ExchangeFolderAdapter {
  static const String _pathKey = 'exchange_folder.windows_path';
  static const String _deviceIdKey = 'exchange_folder.diagnostic_device_id';

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  FileSystemExchangeFolderAdapter? _delegate;

  @override
  Future<ExchangeFolderStatus> checkAccess() async {
    final FileSystemExchangeFolderAdapter? delegate = await _restoreDelegate();
    if (delegate == null) {
      return const ExchangeFolderStatus(
        kind: ExchangeFolderKind.windowsDirectory,
        isSelected: false,
        canRead: false,
        canWrite: false,
        canList: false,
        supportsStagedRename: false,
        atomicRenameVerified: false,
        error: 'Nie wybrano folderu wymiany.',
      );
    }
    return delegate.checkAccess();
  }

  @override
  Future<ExchangeFolderStatus> selectFolder() async {
    final String? path = await getDirectoryPath(
      confirmButtonText: 'Użyj folderu wymiany',
    );
    if (path == null) {
      return checkAccess();
    }
    final String deviceId = await _deviceId();
    _delegate = FileSystemExchangeFolderAdapter(
      directory: Directory(path),
      deviceDiagnosticId: deviceId,
    );
    await _preferences.setString(_pathKey, path);
    return _delegate!.checkAccess();
  }

  @override
  Future<List<ExchangeFileInfo>> listOwnTestFiles() => _required().then(
        (FileSystemExchangeFolderAdapter adapter) => adapter.listOwnTestFiles(),
      );

  @override
  Future<ExchangeWriteResult> writeOnce({
    required String name,
    required Uint8List contents,
    required String expectedSha256,
  }) => _required().then(
        (FileSystemExchangeFolderAdapter adapter) => adapter.writeOnce(
          name: name,
          contents: contents,
          expectedSha256: expectedSha256,
        ),
      );

  @override
  Future<ExchangeReadVerification> readAndVerify({
    required String name,
    required String expectedSha256,
  }) => _required().then(
        (FileSystemExchangeFolderAdapter adapter) => adapter.readAndVerify(
          name: name,
          expectedSha256: expectedSha256,
        ),
      );

  @override
  Future<ExchangeDeleteResult> deleteOwnTestFile(String name) => _required().then(
        (FileSystemExchangeFolderAdapter adapter) => adapter.deleteOwnTestFile(name),
      );

  Future<FileSystemExchangeFolderAdapter> _required() async {
    final FileSystemExchangeFolderAdapter? delegate = await _restoreDelegate();
    if (delegate == null) {
      throw const ExchangeFolderException('Najpierw wybierz folder wymiany.');
    }
    return delegate;
  }

  Future<FileSystemExchangeFolderAdapter?> _restoreDelegate() async {
    if (_delegate != null) {
      return _delegate;
    }
    final String? path = await _preferences.getString(_pathKey);
    if (path == null) {
      return null;
    }
    _delegate = FileSystemExchangeFolderAdapter(
      directory: Directory(path),
      deviceDiagnosticId: await _deviceId(),
    );
    return _delegate;
  }

  Future<String> _deviceId() async {
    final String? existing = await _preferences.getString(_deviceIdKey);
    if (existing != null && StableId.isValid(existing)) {
      return existing;
    }
    final String created = StableId.newId();
    await _preferences.setString(_deviceIdKey, created);
    return created;
  }
}
