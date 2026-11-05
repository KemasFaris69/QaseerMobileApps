import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../domain/restaurant_table.dart';
import '../domain/table_repository.dart';
import 'table_card.dart';
import 'table_cubit.dart';

class TablesDart extends StatelessWidget {
  const TablesDart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TableCubit(context.read<TableRepository>())..load(),
      child: const _TablesView(),
    );
  }
}

class _TablesView extends StatelessWidget {
  const _TablesView();

  Future<void> _onTap(
    BuildContext context,
    RestaurantTable table,
  ) async {
    final cubit = context.read<TableCubit>();

    switch (table.status) {
      case TableStatus.tersedia:
        final guests = await showDialog<int>(
          context: context,
          builder: (_) => _OpenTableDialog(table: table),
        );

        if (guests == null || !context.mounted) return;

        final error = await cubit.openTable(table.id, guests);

        if (!context.mounted) return;
        _message(context, error ?? 'Meja ${table.number} berhasil dibuka.');
        return;

      case TableStatus.terisi:
        final rupiah = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('Meja ${table.number}'),
            content: Text(
              'Area: ${table.area}\n'
              'Jumlah tamu: ${table.guests ?? 0}\n'
              'Tagihan dummy: ${rupiah.format(table.runningTotal)}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
        return;

      case TableStatus.perluDibersihkan:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Tandai meja bersih?'),
            content: Text(
              'Pastikan meja ${table.number} sudah siap digunakan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Sudah Bersih'),
              ),
            ],
          ),
        );

        if (confirmed != true || !context.mounted) return;

        final error = await cubit.markClean(table.id);

        if (!context.mounted) return;
        _message(context, error ?? 'Meja ${table.number} tersedia kembali.');
        return;
    }
  }

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Denah Meja')),
      body: BlocBuilder<TableCubit, TableState>(
        builder: (context, state) {
          final cubit = context.read<TableCubit>();
          final busy = state.loading || state.processing;

          return Column(
            children: [
              if (busy) const LinearProgressIndicator(),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('Semua Area'),
                        selected: state.area == null,
                        onSelected: (_) => cubit.selectArea(null),
                      ),
                    ),
                    for (final area in state.areas)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(area),
                          selected: state.area == area,
                          onSelected: (_) => cubit.selectArea(area),
                        ),
                      ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('Semua Status'),
                        selected: state.filter == null,
                        onSelected: (_) => cubit.setFilter(null),
                      ),
                    ),
                    for (final status in TableStatus.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status.label),
                          selected: state.filter == status,
                          onSelected: (_) => cubit.setFilter(status),
                        ),
                      ),
                  ],
                ),
              ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(state.error!),
                      TextButton(
                        onPressed: busy ? null : () => cubit.load(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: cubit.load,
                  child: state.visible.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                state.loading
                                    ? 'Memuat meja...'
                                    : 'Tidak ada meja untuk filter ini.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
                      : GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 240,
                            mainAxisExtent: 220,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: state.visible.length,
                          itemBuilder: (context, index) {
                            final table = state.visible[index];

                            return TableCard(
                              table: table,
                              onTap: busy ? null : () => _onTap(context, table),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OpenTableDialog extends StatefulWidget {
  const _OpenTableDialog({required this.table});

  final RestaurantTable table;

  @override
  State<_OpenTableDialog> createState() => _OpenTableDialogState();
}

class _OpenTableDialogState extends State<_OpenTableDialog> {
  final _formKey = GlobalKey<FormState>();
  final _guestsController = TextEditingController(text: '1');

  @override
  void dispose() {
    _guestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Buka Meja ${widget.table.number}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kapasitas: ${widget.table.capacity} kursi'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _guestsController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah tamu',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final guests = int.tryParse(value?.trim() ?? '');

                if (guests == null || guests < 1) {
                  return 'Masukkan jumlah tamu minimal satu.';
                }

                return null;
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Jika melebihi kapasitas, pastikan tempat duduk tambahan tersedia.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            Navigator.pop(
              context,
              int.parse(_guestsController.text.trim()),
            );
          },
          child: const Text('Buka Meja'),
        ),
      ],
    );
  }
}