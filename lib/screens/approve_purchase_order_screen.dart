import 'package:flutter/material.dart';
import 'package:inventory_frontendtwo/res/api_client.dart';

class ApprovePurchaseOrderScreen extends StatefulWidget {
  const ApprovePurchaseOrderScreen({super.key});

  @override
  State<ApprovePurchaseOrderScreen> createState() =>
      _ApprovePurchaseOrderScreenState();
}

class _ApprovePurchaseOrderScreenState
    extends State<ApprovePurchaseOrderScreen> {

  List orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await ApiClient.dio.get("/purchase-orders");
      setState(() {
        // show only CREATED orders
        orders = response.data
            .where((o) => o["status"] == "CREATED")
            .toList();
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load purchase orders")),
      );
    }
  }

  Future<void> approveOrder(int orderId) async {
    try {
      await ApiClient.dio.put("/purchase-orders/$orderId/approve");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Purchase Order Approved")),
      );
      fetchOrders(); // refresh list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Approval failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.isEmpty) {
      return const Center(child: Text("No pending purchase orders"));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Approve Purchase Orders",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final po = orders[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      "${po["product"]["name"]}  (Qty: ${po["quantity"]})",
                    ),
                    subtitle: Text(
                      "Vendor: ${po["vendor"]["name"]}",
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => approveOrder(po["id"]),
                      child: const Text("Approve"),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
