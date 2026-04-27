class ItemModel {
  final int? id;
  final String name;

  ItemModel({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(id: map['id'], name: map['name']);
  }

}
