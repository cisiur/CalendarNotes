import 'dart:typed_data';

/// A narrow, diagnostic-only contract for the separately selected exchange
/// directory. It does not know about SQLite, journal records, or sync events.
abstract interface class ExchangeFolderAdapter {
  Future<ExchangeFolderStatus> checkAccess();

  Future<ExchangeFolderStatus> selectFolder();

  Future<List<ExchangeFileInfo>> listOwnTestFiles();

  /// Creates an immutable diagnostic file. Implementations must reject an
  /// existing name and must never replace it.
  Future<ExchangeWriteResult> writeOnce({
    required String name,
    required Uint8List contents,
    required String expectedSha256,
  });

  Future<ExchangeReadVerification> readAndVerify({
    required String name,
    required String expectedSha256,
  });

  /// Deletes only a file whose name carries this installation's test prefix.
  Future<ExchangeDeleteResult> deleteOwnTestFile(String name);
}

enum ExchangeFolderKind { windowsDirectory, androidSafTree, unsupported }

class ExchangeFolderStatus {
  const ExchangeFolderStatus({
    required this.kind,
    required this.isSelected,
    required this.canRead,
    required this.canWrite,
    required this.canList,
    required this.supportsStagedRename,
    required this.atomicRenameVerified,
    this.location,
    this.provider,
    this.error,
  });

  final ExchangeFolderKind kind;
  final bool isSelected;
  final bool canRead;
  final bool canWrite;
  final bool canList;
  final bool supportsStagedRename;
  final bool atomicRenameVerified;
  final String? location;
  final String? provider;
  final String? error;

  bool get isUsable => isSelected && canRead && canWrite && canList;
}

class ExchangeFileInfo {
  const ExchangeFileInfo({required this.name, required this.sizeBytes});

  final String name;
  final int sizeBytes;
}

class ExchangeWriteResult {
  const ExchangeWriteResult({
    required this.name,
    required this.sizeBytes,
    required this.sha256,
    required this.usedStagedRename,
  });

  final String name;
  final int sizeBytes;
  final String sha256;
  final bool usedStagedRename;
}

class ExchangeReadVerification {
  const ExchangeReadVerification({
    required this.name,
    required this.sizeBytes,
    required this.actualSha256,
    required this.hashMatches,
  });

  final String name;
  final int sizeBytes;
  final String actualSha256;
  final bool hashMatches;
}

class ExchangeDeleteResult {
  const ExchangeDeleteResult({required this.name, required this.deleted});

  final String name;
  final bool deleted;
}

class ExchangeFolderException implements Exception {
  const ExchangeFolderException(this.message);

  final String message;

  @override
  String toString() => 'ExchangeFolderException: $message';
}
