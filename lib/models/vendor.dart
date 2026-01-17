class Vendor {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String address;

  Vendor({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "email": email,
        "address": address,
      };
}
