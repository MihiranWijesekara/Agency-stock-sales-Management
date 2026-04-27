// Cart Item Model
class CartItem {
  final int itemId;
  final String itemName;
  final double originalPrice; // Add this
  double sellingPrice;
  double weight;
  double amount;
  double discount; // Add this

  CartItem({
    required this.itemId,
    required this.itemName,
    required this.originalPrice,
    required this.sellingPrice,
    required this.weight,
    required this.amount,
    required this.discount,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'originalPrice': originalPrice,
      'sellingPrice': sellingPrice,
      'weight': weight,
      'amount': amount,
      'discount': discount,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      itemId: map['itemId'],
      itemName: map['itemName'],
      originalPrice: map['originalPrice'],
      sellingPrice: map['sellingPrice'],
      weight: map['weight'],
      amount: map['amount'],
      discount: map['discount'],
    );
  }
}