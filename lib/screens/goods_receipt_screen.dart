import 'package:flutter/material.dart';
import 'package:inventory_frontendtwo/res/api_client.dart';

class GoodsReceiptScreen extends StatefulWidget {
  const GoodsReceiptScreen({super.key});

  @override
  State<GoodsReceiptScreen> createState() => _GoodsReceiptScreenState();
}

class _GoodsReceiptScreenState extends State<GoodsReceiptScreen> {

  List approvedOrders = [];
  bool isLoading = true;

  // PO_ID -> total received quantity (UI-level tracking)
  final Map<int, int> receivedQtyMap = {};

  @override
  void initState() {
    super.initState();
    loadApprovedOrders();
  }

  Future<void> loadApprovedOrders() async {
    try {
      final response = await ApiClient.dio.get("/purchase-orders");
      setState(() {
        approvedOrders = response.data
            .where((o) => o["status"] == "APPROVED")
            .toList();
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load approved orders")),
      );
    }
  }

  void showReceiveDialog(Map order) {
    final qtyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Receive Goods"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Product: ${order["product"]["name"]}"),
              Text("Ordered Qty: ${order["quantity"]}"),
              const SizedBox(height: 12),
              TextField(
                controller: qtyCtrl,
                decoration: const InputDecoration(
                  labelText: "Received Quantity",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (qtyCtrl.text.isEmpty) return;
                final qty = int.parse(qtyCtrl.text);
                await receiveGoods(order, qty);
                Navigator.pop(context);
              },
              child: const Text("Receive"),
            ),
          ],
        );
      },
    );
  }

  Future<void> receiveGoods(Map order, int qty) async {
    try {
      await ApiClient.dio.post(
        "/goods-receipts",
        data: {
          "purchaseOrder": {"id": order["id"]},
          "product": {"id": order["product"]["id"]},
          "receivedQty": qty,
        },
      );

      // Update UI received quantity
      setState(() {
        final poId = order["id"] as int;
        receivedQtyMap[poId] = (receivedQtyMap[poId] ?? 0) + qty;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Goods Received Successfully")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to receive goods")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (approvedOrders.isEmpty) {
      return const Center(child: Text("No approved purchase orders"));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Goods Receipt",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: approvedOrders.length,
              itemBuilder: (context, index) {
                final po = approvedOrders[index];

                final int orderedQty = po["quantity"];
                final int receivedQty =
                    receivedQtyMap[po["id"]] ?? 0;
                final int remainingQty =
                    orderedQty - receivedQty;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      po["product"]["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Vendor: ${po["vendor"]["name"]}"),
                        Text("Ordered: $orderedQty"),
                        Text("Received: $receivedQty"),
                        Text(
                          "Remaining: $remainingQty",
                          style: TextStyle(
                            color: remainingQty == 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: remainingQty == 0
                          ? null
                          : () => showReceiveDialog(po),
                      child: const Text("Receive"),
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
