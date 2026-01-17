import 'package:flutter/material.dart';
import 'package:inventory_frontendtwo/res/api_client.dart';

class PurchaseOrderScreen extends StatefulWidget {
  const PurchaseOrderScreen({super.key});

  @override
  State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends State<PurchaseOrderScreen> {
  List vendors = [];
  List products = [];

  int? selectedVendorId;
  int? selectedProductId;
  final qtyCtrl = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMasterData();
  }

  Future<void> loadMasterData() async {
    try {
      final vendorRes = await ApiClient.dio.get("/vendors");
      final productRes = await ApiClient.dio.get("/products");

      setState(() {
        vendors = vendorRes.data;
        products = productRes.data;
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load vendors/products")),
      );
    }
  }

  void createPO() async {
    if (selectedVendorId == null ||
        selectedProductId == null ||
        qtyCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      await ApiClient.dio.post(
        "/purchase-orders",
        data: {
          "vendor": {"id": selectedVendorId},
          "product": {"id": selectedProductId},
          "quantity": int.parse(qtyCtrl.text),
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Purchase Order Created")),
      );

      setState(() {
        selectedVendorId = null;
        selectedProductId = null;
      });
      qtyCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create Purchase Order")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Create Purchase Order",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Select vendor, product, and quantity",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const Divider(height: 32),

                      DropdownButtonFormField<int>(
                        value: selectedVendorId,
                        decoration: const InputDecoration(
                          labelText: "Vendor",
                          border: OutlineInputBorder(),
                        ),
                        items: vendors.map<DropdownMenuItem<int>>((v) {
                          return DropdownMenuItem(
                            value: v["id"],
                            child: Text(v["name"]),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedVendorId = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<int>(
                        value: selectedProductId,
                        decoration: const InputDecoration(
                          labelText: "Product",
                          border: OutlineInputBorder(),
                        ),
                        items: products.map<DropdownMenuItem<int>>((p) {
                          return DropdownMenuItem(
                            value: p["id"],
                            child: Text(p["name"]),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProductId = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Quantity",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: createPO,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Create Purchase Order",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
