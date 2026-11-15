import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/restaurant_table.dart';

/// Satu sumber format nominal agar seluruh tampilan meja konsisten.
final NumberFormat _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

String formatRupiah(int amount) => _rupiah.format(amount);

/// Warna, ikon, dan latar untuk setiap status meja.
extension TableStatusVisuals on TableStatus {
  Color get color => switch (this) {
        TableStatus.tersedia => const Color(0xFF2E7D32),
        TableStatus.terisi => const Color(0xFFEF6C00),
        TableStatus.perluDibersihkan => const Color(0xFF546E7A),
      };

  IconData get icon => switch (this) {
        TableStatus.tersedia => Icons.check_circle_outline,
        TableStatus.terisi => Icons.groups_outlined,
        TableStatus.perluDibersihkan => Icons.cleaning_services_outlined,
      };

  Color get tint => color.withValues(alpha: 0.10);
}

/// Label status meja dengan warna yang sama di kartu maupun dialog.
class TableStatusBadge extends StatelessWidget {
  const TableStatusBadge({
    super.key,
    required this.status,
    this.wide = false,
  });

  final TableStatus status;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final color = status.color;

    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: status.tint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: wide ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              status.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
