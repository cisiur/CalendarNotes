import 'package:calendar_notes/data/sync/exchange_folder_adapter.dart';
import 'package:flutter/material.dart';

import 'exchange_folder_diagnostic_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final ExchangeFolderDiagnosticController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExchangeFolderDiagnosticController()..addListener(_onChanged);
    _controller.refresh();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ExchangeFolderStatus? status = _controller.status;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Text('Ustawienia', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Diagnostyka folderu wymiany (tylko dla programistów)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nie uruchamia synchronizacji ani nie wybiera bazy danych. '
                  'Tworzy wyłącznie nieosobowe pliki testowe tego urządzenia.',
                ),
                const SizedBox(height: 16),
                _StatusDetails(status: status),
                const SizedBox(height: 12),
                Text(_controller.message),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    FilledButton(
                      onPressed: _controller.isBusy ? null : _controller.selectFolder,
                      child: const Text('Wybierz folder'),
                    ),
                    OutlinedButton(
                      onPressed: _controller.isBusy ? null : _controller.refresh,
                      child: const Text('Sprawdź dostęp po restarcie'),
                    ),
                    OutlinedButton(
                      onPressed: _controller.isBusy || status?.isUsable != true
                          ? null
                          : _controller.createAndVerify,
                      child: const Text('Utwórz i zweryfikuj plik testowy'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Własne pliki diagnostyczne', style: Theme.of(context).textTheme.titleMedium),
        if (_controller.files.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Brak plików testowych tego urządzenia.'),
          )
        else
          ..._controller.files.map(
            (ExchangeFileInfo file) => ListTile(
              title: Text(file.name),
              subtitle: Text('${file.sizeBytes} B'),
              trailing: TextButton(
                onPressed: _controller.isBusy ? null : () => _confirmDelete(context, file.name),
                child: const Text('Usuń'),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, String name) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Usunąć plik testowy?'),
        content: Text('Zostanie usunięty wyłącznie plik diagnostyczny tego urządzenia:\n$name'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Anuluj')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Usuń')),
        ],
      ),
    );
    if (shouldDelete == true) await _controller.deleteFile(name);
  }
}

class _StatusDetails extends StatelessWidget {
  const _StatusDetails({required this.status});
  final ExchangeFolderStatus? status;

  @override
  Widget build(BuildContext context) {
    if (status == null) return const LinearProgressIndicator();
    return Text(
      'Provider: ${status!.provider ?? 'brak'}\n'
      'Lokalizacja/URI: ${status!.location ?? 'brak'}\n'
      'Odczyt: ${status!.canRead ? 'tak' : 'nie'}; zapis: ${status!.canWrite ? 'tak' : 'nie'}; '
      'lista: ${status!.canList ? 'tak' : 'nie'}\n'
      'Staging + rename: ${status!.supportsStagedRename ? 'dostępne do testu' : 'niedostępne'}; '
      'atomowość: ${status!.atomicRenameVerified ? 'zweryfikowana' : 'niezweryfikowana'}',
    );
  }
}
