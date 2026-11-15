import 'package:flutter/material.dart';

class NavTab {
  const NavTab(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;
}

const _dashboard = NavTab('/dashboard', 'Beranda', Icons.space_dashboard_outlined);
const _tables = NavTab('/tables', 'Meja', Icons.grid_view_rounded);
const _orders = NavTab('/orders', 'Pesanan', Icons.receipt_long_outlined);
const _shift = NavTab('/shift', 'Shift', Icons.schedule);
const _notifications = NavTab('/notifications', 'Notifikasi', Icons.notifications_none);
const _profile = NavTab('/profile', 'Akun', Icons.account_circle_outlined);
const _inventory = NavTab('/inventory', 'Stok', Icons.inventory_2_outlined);
const _purchaseOrders = NavTab('/purchase-orders', 'PO', Icons.assignment_outlined);
const _suppliers = NavTab('/suppliers', 'Supplier', Icons.local_shipping_outlined);
const _finance = NavTab('/finance', 'Keuangan', Icons.account_balance_wallet_outlined);
const _expenses = NavTab('/finance/expenses', 'Pengeluaran', Icons.receipt_outlined);
const _reports = NavTab('/reports', 'Laporan', Icons.bar_chart);
const _kitchen = NavTab('/kitchen', 'Dapur', Icons.soup_kitchen_outlined);
const _menuAvailability = NavTab('/kitchen/menu-availability', 'Menu', Icons.restaurant_menu);

List<NavTab> tabsForRole(String roleName) => switch (roleName) {
      'owner' => const [
          _dashboard,
          NavTab('/finance', 'Laporan', Icons.bar_chart),
          NavTab('/purchase-orders', 'Persetujuan', Icons.fact_check_outlined),
          _notifications,
          _profile,
        ],
      'manager' => const [_dashboard, _tables, NavTab('/inventory', 'Gudang', Icons.inventory_2_outlined), _notifications, _profile],
      'kasir' => const [_tables, _orders, _shift, _notifications, _profile],
      'pelayan' => const [_tables, _orders, _notifications, _profile],
      'dapur' => const [_kitchen, _menuAvailability, _profile],
      'gudang' => const [_inventory, _purchaseOrders, _suppliers, _notifications, _profile],
      'akuntan' => const [_finance, _expenses, _reports, _notifications, _profile],
      _ => const [_dashboard, _profile],
    };