class ItemModel {
  final int? id;
  final String unit;
  final String name;

  ItemModel({this.id, required this.unit, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'unit': unit, 'name': name};
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(id: map['id'], unit: map['unit'] ?? '', name: map['name']);
  }
}
