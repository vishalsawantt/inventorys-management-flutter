import 'package:flutter/material.dart';
import 'purchase_order_screen.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Dashboard")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: PurchaseOrderScreen(),
      ),
    );
  }
}
