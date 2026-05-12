import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:castpa/application/providers/database_provider.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

final _dbTablesProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final db = ref.read(databaseProvider);
  final result = await db
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
      )
      .get();
  return result.map((r) => r.read<String>('name')).toList();
});

final _tableRowsProvider = FutureProvider.autoDispose
    .family<_TableData, String>((ref, tableName) async {
      final db = ref.read(databaseProvider);
      final rows = await db
          .customSelect('SELECT * FROM "$tableName" LIMIT 200')
          .get();
      if (rows.isEmpty) return _TableData(columns: [], rows: []);
      final columns = rows.first.data.keys.toList();
      final data = rows
          .map((r) => columns.map((c) => r.data[c]?.toString() ?? '').toList())
          .toList();
      return _TableData(columns: columns, rows: data);
    });

final _localDeviceRowsProvider = FutureProvider.autoDispose<_TableData>((
  ref,
) async {
  final db = ref.read(localDatabaseProvider);
  final rows = await db.customSelect('SELECT * FROM "local_device_info"').get();
  if (rows.isEmpty) return _TableData(columns: [], rows: []);
  final columns = rows.first.data.keys.toList();
  final data = rows
      .map((r) => columns.map((c) => r.data[c]?.toString() ?? '').toList())
      .toList();
  return _TableData(columns: columns, rows: data);
});

class _TableData {
  final List<String> columns;
  final List<List<String>> rows;
  const _TableData({required this.columns, required this.rows});
}

// ─── Tables list screen ───────────────────────────────────────────────────────

class DbTablesScreen extends ConsumerWidget {
  const DbTablesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(_dbTablesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('CastPA.DB')),
      body: tablesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tables) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tables.length + 2, // +1 divider header, +1 local device
            separatorBuilder: (ctx, i) => const Divider(height: 1),
            itemBuilder: (_, i) {
              if (i < tables.length) {
                final table = tables[i];
                return ListTile(
                  leading: const Icon(Icons.table_chart_outlined),
                  title: Text(
                    table,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/db-inspector/$table'),
                );
              }
              if (i == tables.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'LOCAL DEVICE  (not synced)',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                );
              }
              return ListTile(
                leading: const Icon(Icons.phone_android_outlined),
                title: const Text(
                  'local_device_info',
                  style: TextStyle(fontFamily: 'monospace'),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/db-inspector-local'),
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Single table screen ──────────────────────────────────────────────────────

class DbTableScreen extends ConsumerStatefulWidget {
  final String tableName;
  const DbTableScreen({super.key, required this.tableName});

  @override
  ConsumerState<DbTableScreen> createState() => _DbTableScreenState();
}

class _DbTableScreenState extends ConsumerState<DbTableScreen> {
  int _editTapCount = 0;
  bool _editEnabled = false;

  void _onEditTap() {
    if (_editEnabled) return;
    setState(() {
      _editTapCount++;
      if (_editTapCount >= 5) _editEnabled = true;
    });
  }

  Future<void> _deleteRow(List<String> columns, List<String> row) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete row?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final pkCol = columns.first;
    final pkVal = row.first;
    final db = ref.read(databaseProvider);
    await db.customStatement(
      'DELETE FROM "${widget.tableName}" WHERE "$pkCol" = ?',
      [pkVal],
    );
    ref.invalidate(_tableRowsProvider(widget.tableName));
  }

  Future<void> _editCell(List<String> columns, List<String> row, int colIndex) async {
    final col = columns[colIndex];
    final currentVal = row[colIndex];
    final ctrl = TextEditingController(text: currentVal);

    final newVal = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit "$col"', style: const TextStyle(fontFamily: 'monospace')),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 4,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: InputDecoration(labelText: col),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('Save')),
        ],
      ),
    );
    if (newVal == null || newVal == currentVal || !mounted) return;

    final pkCol = columns.first;
    final pkVal = row.first;
    final db = ref.read(databaseProvider);
    await db.customStatement(
      'UPDATE "${widget.tableName}" SET "$col" = ? WHERE "$pkCol" = ?',
      [newVal, pkVal],
    );
    ref.invalidate(_tableRowsProvider(widget.tableName));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataAsync = ref.watch(_tableRowsProvider(widget.tableName));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tableName, style: const TextStyle(fontFamily: 'monospace')),
        actions: [
          if (_editEnabled)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: const Text('EDIT ON', style: TextStyle(fontSize: 11, color: Colors.white)),
                backgroundColor: Colors.red,
                padding: EdgeInsets.zero,
              ),
            ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: _editEnabled ? Colors.red : (_editTapCount > 0 ? Colors.orange : null),
            ),
            tooltip: _editEnabled ? 'Edit enabled' : 'Tap ${5 - _editTapCount}x to unlock edit',
            onPressed: _onEditTap,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(_tableRowsProvider(widget.tableName)),
          ),
        ],
      ),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          if (data.columns.isEmpty) {
            return const Center(child: Text('Table is empty'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  theme.colorScheme.surfaceContainerHighest,
                ),
                columnSpacing: 20,
                dataRowMinHeight: 36,
                dataRowMaxHeight: 56,
                columns: [
                  ...data.columns.asMap().entries.map(
                    (e) => DataColumn(
                      label: Text(
                        e.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                  if (_editEnabled)
                    const DataColumn(label: SizedBox.shrink()),
                ],
                rows: data.rows.map((row) {
                  return DataRow(
                    cells: [
                      ...row.asMap().entries.map((e) => DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            e.value,
                            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        onTap: _editEnabled
                            ? () => _editCell(data.columns, row, e.key)
                            : null,
                      )),
                      if (_editEnabled)
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                            onPressed: () => _deleteRow(data.columns, row),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Local device screen ──────────────────────────────────────────────────────

class LocalDeviceScreen extends ConsumerWidget {
  const LocalDeviceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(_localDeviceRowsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'local_device_info',
          style: TextStyle(fontFamily: 'monospace'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(_localDeviceRowsProvider),
          ),
        ],
      ),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          print('Error loading local_device_info: $e');
          return Center(child: Text('Error: $e'));
        },
        data: (data) {
          print(
            'Loaded local_device_info: ${data.columns} with ${data.rows.length} rows',
          );
          if (data.columns.isEmpty) {
            return const Center(child: Text('No local device data yet'));
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                columnSpacing: 20,
                dataRowMinHeight: 36,
                dataRowMaxHeight: 56,
                columns: data.columns
                    .map(
                      (c) => DataColumn(
                        label: Text(
                          c,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    )
                    .toList(),
                rows: data.rows
                    .map(
                      (row) => DataRow(
                        cells: row
                            .map(
                              (cell) => DataCell(
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 200,
                                  ),
                                  child: Text(
                                    cell,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    )
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
