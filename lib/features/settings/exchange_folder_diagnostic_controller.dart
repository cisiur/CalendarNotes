import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:calendar_notes/core/ids/stable_id.dart';
import 'package:calendar_notes/data/sync/android_saf_exchange_folder_adapter.dart';
import 'package:calendar_notes/data/sync/exchange_folder_adapter.dart';
import 'package:calendar_notes/data/sync/windows_exchange_folder_adapter.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeFolderDiagnosticController extends ChangeNotifier {
  ExchangeFolderDiagnosticController({ExchangeFolderAdapter? adapter})
      : _adapter = adapter ?? _createAdapter();

  static const String _deviceIdKey = 'exchange_folder.diagnostic_device_id';
  final ExchangeFolderAdapter _adapter;
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  ExchangeFolderStatus? status;
  List<ExchangeFileInfo> files = <ExchangeFileInfo>[];
  String message = 'Diagnostyka nie została jeszcze uruchomiona.';
  bool isBusy = false;

  Future<void> refresh() => _run(() async {
        status = await _adapter.checkAccess();
        files = status!.isUsable
            ? await _adapter.listOwnTestFiles()
            : <ExchangeFileInfo>[];
        message = status!.isUsable
            ? 'Dostęp do folderu został sprawdzony.'
            : (status!.error ?? 'Folder wymiany jest niedostępny.');
      });

  Future<void> selectFolder() => _run(() async {
        status = await _adapter.selectFolder();
        files = status!.isUsable
            ? await _adapter.listOwnTestFiles()
            : <ExchangeFileInfo>[];
        message = status!.isUsable
            ? 'Folder wymiany wybrany i sprawdzony.'
            : (status!.error ?? 'Nie wybrano folderu wymiany.');
      });

  Future<void> createAndVerify() => _run(() async {
        final String deviceId = await _deviceId();
        final String nonce = StableId.newId();
        final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonEncode(<String, String>{
          'kind': 'calendar_notes_exchange_diagnostic',
          'nonce': nonce,
          'createdAtUtc': DateTime.now().toUtc().toIso8601String(),
        })));
        final String hash = sha256.convert(bytes).toString();
        final String name = 'calendarnotes-diagnostic-$deviceId-$nonce.json';
        await _adapter.writeOnce(name: name, contents: bytes, expectedSha256: hash);
        final ExchangeReadVerification verification = await _adapter.readAndVerify(
          name: name,
          expectedSha256: hash,
        );
        if (!verification.hashMatches) {
          throw const ExchangeFolderException('Odczytana suma SHA-256 nie jest zgodna.');
        }
        files = await _adapter.listOwnTestFiles();
        message = 'Utworzono i zweryfikowano $name (${verification.sizeBytes} B).';
      });

  Future<void> deleteFile(String name) => _run(() async {
        final ExchangeDeleteResult result = await _adapter.deleteOwnTestFile(name);
        files = await _adapter.listOwnTestFiles();
        message = result.deleted ? 'Usunięto własny plik testowy: $name' : 'Plik już nie istnieje.';
      });

  Future<void> _run(Future<void> Function() action) async {
    isBusy = true;
    notifyListeners();
    try {
      await action();
    } on ExchangeFolderException catch (error) {
      message = error.message;
    } on FileSystemException catch (error) {
      message = 'Błąd systemu plików: ${error.message}';
    } catch (error) {
      message = 'Błąd diagnostyki: $error';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<String> _deviceId() async {
    final String? stored = await _preferences.getString(_deviceIdKey);
    if (stored != null && StableId.isValid(stored)) return stored;
    final String created = StableId.newId();
    await _preferences.setString(_deviceIdKey, created);
    return created;
  }

  static ExchangeFolderAdapter _createAdapter() {
    if (Platform.isWindows) return WindowsExchangeFolderAdapter();
    if (Platform.isAndroid) return AndroidSafExchangeFolderAdapter();
    return _UnsupportedExchangeFolderAdapter();
  }
}

class _UnsupportedExchangeFolderAdapter implements ExchangeFolderAdapter {
  ExchangeFolderStatus get _status => const ExchangeFolderStatus(
        kind: ExchangeFolderKind.unsupported,
        isSelected: false,
        canRead: false,
        canWrite: false,
        canList: false,
        supportsStagedRename: false,
        atomicRenameVerified: false,
        error: 'Diagnostyka folderu działa wyłącznie na Windows i Androidzie.',
      );
  @override
  Future<ExchangeFolderStatus> checkAccess() async => _status;
  @override
  Future<ExchangeFolderStatus> selectFolder() async => _status;
  @override
  Future<ExchangeDeleteResult> deleteOwnTestFile(String name) =>
      throw const ExchangeFolderException('Platforma nie jest obsługiwana.');
  @override
  Future<List<ExchangeFileInfo>> listOwnTestFiles() =>
      throw const ExchangeFolderException('Platforma nie jest obsługiwana.');
  @override
  Future<ExchangeReadVerification> readAndVerify({
    required String name,
    required String expectedSha256,
  }) => throw const ExchangeFolderException('Platforma nie jest obsługiwana.');
  @override
  Future<ExchangeWriteResult> writeOnce({
    required String name,
    required Uint8List contents,
    required String expectedSha256,
  }) => throw const ExchangeFolderException('Platforma nie jest obsługiwana.');
}
