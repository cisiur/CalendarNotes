import 'dart:io';
import 'dart:typed_data';

import 'package:calendar_notes/data/sync/exchange_folder_adapter.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

/// Filesystem implementation used by Windows after the user selects a folder.
/// It is also the deterministic temporary-directory fake used in unit tests.
class FileSystemExchangeFolderAdapter implements ExchangeFolderAdapter {
  FileSystemExchangeFolderAdapter({
    required Directory directory,
    required String deviceDiagnosticId,
    Future<void> Function()? accessProbeForTesting,
  })  : _directory = directory,
        _deviceDiagnosticId = deviceDiagnosticId,
        _accessProbeForTesting = accessProbeForTesting;

  final Directory _directory;
  final String _deviceDiagnosticId;
  final Future<void> Function()? _accessProbeForTesting;

  String get ownTestPrefix => 'calendarnotes-diagnostic-$_deviceDiagnosticId-';

  @override
  Future<ExchangeFolderStatus> checkAccess() async {
    try {
      if (!await _directory.exists()) {
        return _status(error: 'Wybrany folder nie istnieje.');
      }
      await _accessProbeForTesting?.call();
      await _directory.list(recursive: false).toList();
      final File probe = File(
        '${_directory.path}${Platform.pathSeparator}$ownTestPrefix.access-${const Uuid().v4()}',
      );
      await probe.create(exclusive: true);
      await probe.delete();
      return _status();
    } on FileSystemException catch (error) {
      return _status(error: 'Brak dostępu do folderu: ${error.message}');
    }
  }

  @override
  Future<ExchangeFolderStatus> selectFolder() async => checkAccess();

  @override
  Future<List<ExchangeFileInfo>> listOwnTestFiles() async {
    await _requireAccess();
    final List<ExchangeFileInfo> files = <ExchangeFileInfo>[];
    await for (final FileSystemEntity entity in _directory.list()) {
      if (entity is File && _fileName(entity.path).startsWith(ownTestPrefix)) {
        files.add(
          ExchangeFileInfo(
            name: _fileName(entity.path),
            sizeBytes: await entity.length(),
          ),
        );
      }
    }
    files.sort((ExchangeFileInfo a, ExchangeFileInfo b) => a.name.compareTo(b.name));
    return files;
  }

  @override
  Future<ExchangeWriteResult> writeOnce({
    required String name,
    required Uint8List contents,
    required String expectedSha256,
  }) async {
    _requireOwnName(name);
    _verifyHash(contents, expectedSha256);
    await _requireAccess();
    final File destination = _fileFor(name);
    try {
      // `create(exclusive: true)` is the actual write-once gate. It combines
      // the existence check and creation, so a concurrent writer cannot win
      // between separate exists/create calls. The diagnostic may leave a
      // truncated own artifact after a crash; hash verification rejects it.
      await destination.create(exclusive: true);
      final RandomAccessFile output = await destination.open(mode: FileMode.write);
      await output.writeFrom(contents);
      await output.flush();
      await output.close();
    } on FileSystemException catch (error) {
      throw ExchangeFolderException('Nie można zapisać pliku testowego: ${error.message}');
    }
    return ExchangeWriteResult(
      name: name,
      sizeBytes: contents.length,
      sha256: expectedSha256,
      usedStagedRename: false,
    );
  }

  @override
  Future<ExchangeReadVerification> readAndVerify({
    required String name,
    required String expectedSha256,
  }) async {
    _requireOwnName(name);
    await _requireAccess();
    final File file = _fileFor(name);
    if (!await file.exists()) {
      throw ExchangeFolderException('Nie znaleziono pliku testowego: $name');
    }
    final Uint8List contents = await file.readAsBytes();
    final String actualSha256 = sha256.convert(contents).toString();
    return ExchangeReadVerification(
      name: name,
      sizeBytes: contents.length,
      actualSha256: actualSha256,
      hashMatches: actualSha256 == expectedSha256,
    );
  }

  @override
  Future<ExchangeDeleteResult> deleteOwnTestFile(String name) async {
    _requireOwnName(name);
    await _requireAccess();
    final File file = _fileFor(name);
    if (!await file.exists()) {
      return ExchangeDeleteResult(name: name, deleted: false);
    }
    await file.delete();
    return ExchangeDeleteResult(name: name, deleted: true);
  }

  ExchangeFolderStatus _status({String? error}) => ExchangeFolderStatus(
        kind: ExchangeFolderKind.windowsDirectory,
        isSelected: true,
        canRead: error == null,
        canWrite: error == null,
        canList: error == null,
        supportsStagedRename: false,
        atomicRenameVerified: false,
        location: _directory.path,
        provider: 'Windows filesystem',
        error: error,
      );

  Future<void> _requireAccess() async {
    final ExchangeFolderStatus status = await checkAccess();
    if (!status.isUsable) {
      throw ExchangeFolderException(status.error ?? 'Folder wymiany jest niedostępny.');
    }
  }

  File _fileFor(String name) =>
      File('${_directory.path}${Platform.pathSeparator}$name');

  void _requireOwnName(String name) {
    if (!name.startsWith(ownTestPrefix) ||
        name.contains('/') ||
        name.contains('\\') ||
        name.contains('..')) {
      throw ExchangeFolderException('Niedozwolona nazwa pliku testowego.');
    }
  }

  void _verifyHash(Uint8List contents, String expectedSha256) {
    if (sha256.convert(contents).toString() != expectedSha256) {
      throw const ExchangeFolderException('Suma SHA-256 danych wejściowych jest nieprawidłowa.');
    }
  }

  String _fileName(String path) => path.split(Platform.pathSeparator).last;
}
