import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/restaurant_table.dart';

class TableCard extends StatelessWidget {
  const TableCard({
    super.key,
    required this.table,
    this.onTap,
  });

  final RestaurantTable table;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (table.status) {
      TableStatus.tersedia => Colors.green,
      TableStatus.terisi => Colors.orange,
      TableStatus.perluDibersihkan => Colors.grey,
    };

    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                table.number,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text('${table.capacity} kursi'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.circle, size: 10, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      table.status.label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              if (table.status == TableStatus.terisi) ...[
                const SizedBox(height: 8),
                Text('${table.guests ?? 0} tamu'),
                Text(rupiah.format(table.runningTotal)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}