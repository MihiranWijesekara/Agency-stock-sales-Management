class Salesmodel {
  final int? id;
  final String billNo;
  final int? shopId;
  final int itemId;
  final int sellingPrice;
  final int? quantityKg;
  final double? amount;
  final String? vatNumber;
  final String? paymentMethod;
  final int? isChecked;
  final String? addedDate;
  final String? shopName;
  final int? qty;
  final int? sellPacket;

  Salesmodel({
    this.id,
    required this.billNo,
    this.shopId,
    required this.itemId,
    required this.sellingPrice,
    this.quantityKg,
    this.amount,
    this.vatNumber,
    this.paymentMethod,
    this.isChecked,
    this.addedDate,
    this.shopName,
    this.qty,
    this.sellPacket,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bill_no': billNo,
      'shop_id': shopId,
      'item_id': itemId,
      'selling_price': sellingPrice,
      'quantity_grams': quantityKg,
      'amount': amount,
      'Vat_Number': vatNumber,
      'PaymentMethod': paymentMethod,
      'is_checked': isChecked,
      'added_date': addedDate,
      'QTY': qty,
      'sellPacket': sellPacket,
    };
  }

  // Create from Map
  factory Salesmodel.fromMap(Map<String, dynamic> map) {
    return Salesmodel(
      id: map['id'],
      billNo: map['bill_no'],
      shopId: map['shop_id'],
      itemId: map['item_id'],
      sellingPrice: map['selling_price'],
      quantityKg: map['quantity_grams'],
      amount: map['amount'],
      vatNumber: map['Vat_Number'],
      paymentMethod: map['PaymentMethod'],
      isChecked: map['is_checked'],
      addedDate: map['added_date'],
      shopName: map['shop_name'],
      qty: map['QTY'],
      sellPacket: map['sellPacket'],
    );
  }
}
