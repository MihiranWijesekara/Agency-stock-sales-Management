class RootModel{
  final int? id;
  final String name;

RootModel({
  this.id,
  required this.name,
});

Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
  };
}
factory RootModel.fromMap(Map<String, dynamic> map) {
  return RootModel(
    id: map['id'],
    name: map['name'],
  );
}

}