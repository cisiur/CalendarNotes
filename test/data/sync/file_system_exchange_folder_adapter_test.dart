import 'dart:io';
import 'dart:typed_data';

import 'package:calendar_notes/data/sync/exchange_folder_adapter.dart';
import 'package:calendar_notes/data/sync/file_system_exchange_folder_adapter.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late FileSystemExchangeFolderAdapter adapter;
  const String deviceId = '66666666-6666-4666-8666-666666666666';

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('calendar_notes_exchange_test_');
    adapter = FileSystemExchangeFolderAdapter(
      directory: directory,
      deviceDiagnosticId: deviceId,
    );
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test('writes once, lists, verifies SHA-256 and deletes only own artifact', () async {
    final Uint8List contents = Uint8List.fromList(<int>[1, 2, 3, 4]);
    final String hash = sha256.convert(contents).toString();
    final String name = '${adapter.ownTestPrefix}roundtrip.json';

    final ExchangeWriteResult write = await adapter.writeOnce(
      name: name,
      contents: contents,
      expectedSha256: hash,
    );
    final List<ExchangeFileInfo> files = await adapter.listOwnTestFiles();
    final ExchangeReadVerification read = await adapter.readAndVerify(
      name: name,
      expectedSha256: hash,
    );

    expect(write.usedStagedRename, isFalse);
    expect(files.single.name, name);
    expect(read.hashMatches, isTrue);
    expect((await adapter.deleteOwnTestFile(name)).deleted, isTrue);
    expect(await adapter.listOwnTestFiles(), isEmpty);
  });

  test('rejects duplicate and non-owned names without overwriting a file', () async {
    final Uint8List contents = Uint8List.fromList(<int>[9]);
    final String hash = sha256.convert(contents).toString();
    final String name = '${adapter.ownTestPrefix}unique.json';
    await adapter.writeOnce(name: name, contents: contents, expectedSha256: hash);

    await expectLater(
      adapter.writeOnce(name: name, contents: contents, expectedSha256: hash),
      throwsA(isA<ExchangeFolderException>()),
    );
    await expectLater(
      adapter.deleteOwnTestFile('unrelated-user-file.json'),
      throwsA(isA<ExchangeFolderException>()),
    );
    expect(await File('${directory.path}${Platform.pathSeparator}$name').readAsBytes(), contents);
  });

  test('exclusive create keeps the first writer bytes during a write race', () async {
    final Uint8List first = Uint8List.fromList(<int>[1, 1, 1]);
    final Uint8List second = Uint8List.fromList(<int>[2, 2, 2]);
    final String name = '${adapter.ownTestPrefix}race.json';

    final List<Object> results = await Future.wait<Object>(<Future<Object>>[
      adapter.writeOnce(
        name: name,
        contents: first,
        expectedSha256: sha256.convert(first).toString(),
      ).then<Object>((ExchangeWriteResult value) => value).catchError((Object error) => error),
      adapter.writeOnce(
        name: name,
        contents: second,
        expectedSha256: sha256.convert(second).toString(),
      ).then<Object>((ExchangeWriteResult value) => value).catchError((Object error) => error),
    ]);

    expect(results.whereType<ExchangeWriteResult>(), hasLength(1));
    expect(results.whereType<ExchangeFolderException>(), hasLength(1));
    final List<int> stored = await File('${directory.path}${Platform.pathSeparator}$name').readAsBytes();
    expect(stored, anyOf(first, second));
  });

  test('reports malformed input and a truncated artifact', () async {
    final Uint8List contents = Uint8List.fromList(<int>[8, 7, 6, 5]);
    final String hash = sha256.convert(contents).toString();
    final String name = '${adapter.ownTestPrefix}truncated.json';

    await expectLater(
      adapter.writeOnce(name: name, contents: contents, expectedSha256: 'not-a-hash'),
      throwsA(isA<ExchangeFolderException>()),
    );
    await adapter.writeOnce(name: name, contents: contents, expectedSha256: hash);
    await File('${directory.path}${Platform.pathSeparator}$name').writeAsBytes(<int>[8]);

    final ExchangeReadVerification verification = await adapter.readAndVerify(
      name: name,
      expectedSha256: hash,
    );
    expect(verification.hashMatches, isFalse);
  });

  test('reports missing folders and deterministic permission errors', () async {
    final FileSystemExchangeFolderAdapter missing = FileSystemExchangeFolderAdapter(
      directory: Directory('${directory.path}${Platform.pathSeparator}missing'),
      deviceDiagnosticId: deviceId,
    );

    expect((await missing.checkAccess()).isUsable, isFalse);
    expect((await missing.checkAccess()).isUsable, isFalse);

    final FileSystemExchangeFolderAdapter denied = FileSystemExchangeFolderAdapter(
      directory: directory,
      deviceDiagnosticId: deviceId,
      accessProbeForTesting: () async {
        throw FileSystemException('Permission denied');
      },
    );
    final ExchangeFolderStatus deniedStatus = await denied.checkAccess();
    expect(deniedStatus.isUsable, isFalse);
    expect(deniedStatus.error, contains('Permission denied'));
  });
}
