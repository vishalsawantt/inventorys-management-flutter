import 'package:flutter/material.dart';
import 'package:inventory_frontendtwo/res/api_client.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  List vendors = [];
  int? selectedVendorId;
  final amountCtrl = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadVendors();
  }

  Future<void> loadVendors() async {
    try {
      final response = await ApiClient.dio.get("/vendors");
      setState(() {
        vendors = response.data;
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load vendors")),
      );
    }
  }

  void payVendor() async {
    if (selectedVendorId == null || amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select vendor and amount")),
      );
      return;
    }

    try {
      await ApiClient.dio.post(
        "/payments",
        data: {
          "vendor": { "id": selectedVendorId },
          "amount": double.parse(amountCtrl.text)
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Successful")),
      );

      setState(() {
        selectedVendorId = null;
      });
      amountCtrl.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Vendor Payment",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<int>(
            value: selectedVendorId,
            decoration: const InputDecoration(
              labelText: "Select Vendor",
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

          const SizedBox(height: 12),

          TextField(
            controller: amountCtrl,
            decoration: const InputDecoration(
              labelText: "Payment Amount",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: payVendor,
              child: const Text("Pay Vendor"),
            ),
          ),
        ],
      ),
    );
  }
}
