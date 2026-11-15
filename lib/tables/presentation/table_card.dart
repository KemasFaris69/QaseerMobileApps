import 'package:flutter/material.dart';

import '../domain/restaurant_table.dart';
import 'table_visuals.dart';

class TableCard extends StatelessWidget {
  const TableCard({
    super.key,
    required this.table,
    this.onTap,
  });

  final RestaurantTable table;
  final VoidCallback? onTap;

  String get _hint => switch (table.status) {
        TableStatus.tersedia => 'Ketuk untuk membuka meja',
        TableStatus.terisi => '',
        TableStatus.perluDibersihkan => 'Ketuk setelah meja dibersihkan',
      };

  @override
  Widget build(BuildContext context) {
    final color = table.status.color;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                table.number,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${table.area} · ${table.capacity} kursi',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const Spacer(),
              if (table.status == TableStatus.terisi) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 14,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${table.guests ?? 0} tamu',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      'Tagihan',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        formatRupiah(table.runningTotal),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else
                Text(
                  _hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              const SizedBox(height: 10),
              TableStatusBadge(status: table.status, wide: true),
            ],
          ),
        ),
      ),
    );
  }
}
