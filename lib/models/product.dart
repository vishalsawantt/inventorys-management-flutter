class Product {
  final int? id;
  final String name;
  final double price;

  Product({this.id, required this.name, required this.price});

  Map<String, dynamic> toJson() => {
        "name": name,
        "price": price,
      };
}
