class StockModel {
  final int? id;
  final int item_id;
  final int stock_price;
  final int selling_price;
  final int? numberofpacks;
  final int? quantity_grams;
  final double? remain_quantity;
  final double? amount;
  final String? added_date;
  final String? item_name; // NEW
  final int? remainingNumberOfPack; // NEW

  StockModel({
    this.id,
    required this.item_id,
    required this.stock_price,
    required this.selling_price,
    this.numberofpacks,
    this.quantity_grams,
    this.remain_quantity,
    this.amount,
    this.added_date,
    this.item_name,
    this.remainingNumberOfPack,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_id': item_id,
      'stock_price': stock_price,
      'selling_price': selling_price,
      'numberofpacks': numberofpacks,
      'quantity_grams': quantity_grams,
      'remain_quantity': remain_quantity,
      'amount': amount,
      'added_date': added_date,
      'remainingNumberOfPack': remainingNumberOfPack,
    };
  }

  factory StockModel.fromMap(Map<String, dynamic> map) {
    return StockModel(
      id: map['id'],
      item_id: map['item_id'],
      stock_price: map['stock_price'],
      selling_price: map['selling_price'],
      numberofpacks: map['numberofpacks'],
      quantity_grams: map['quantity_grams'],
      remain_quantity: (map['remain_quantity'] as num?)?.toDouble(),
      amount: (map['amount'] as num?)?.toDouble(),
      added_date: map['added_date'],
      item_name: map['item_name'],
      remainingNumberOfPack: map['remainingNumberOfPack'],
    );
  }
}
