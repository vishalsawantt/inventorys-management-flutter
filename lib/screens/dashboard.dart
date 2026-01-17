import 'package:flutter/material.dart';
import 'inventory_screen.dart';
import 'vendor_screen.dart';
import 'product_screen.dart';
import 'approve_purchase_order_screen.dart';
import 'goods_receipt_screen.dart';
import 'payment_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  Widget currentScreen = const InventoryScreen();

  void changeScreen(Widget screen) {
    setState(() {
      currentScreen = screen;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      drawer: Drawer(
        child: ListView(
          children: [

            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Center(
                child: Text(
                  "ADMIN PANEL",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),

            ListTile(
              title: const Text("Inventory"),
              onTap: () => changeScreen(const InventoryScreen()),
            ),
            ListTile(
              title: const Text("Add Vendor"),
              onTap: () => changeScreen(const VendorScreen()),
            ),
            ListTile(
              title: const Text("Add Product"),
              onTap: () => changeScreen(const ProductScreen()),
            ),
            ListTile(
              title: const Text("Approve Purchase Orders"),
              onTap: () => changeScreen(const ApprovePurchaseOrderScreen()),
            ),
            ListTile(
              title: const Text("Goods Receipt"),
              onTap: () => changeScreen(const GoodsReceiptScreen()),
            ),
            ListTile(
              title: const Text("Vendor Payments"),
              onTap: () => changeScreen(const PaymentScreen()),
            ),
          ],
        ),
      ),
      body: currentScreen,
    );
  }
}
