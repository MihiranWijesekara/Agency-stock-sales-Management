class Shopmodel {
  final int? id;
  final String Shopname;
  final int? rootId;
  final String? rootName;

  Shopmodel({
    this.id,
    required this.Shopname,
    this.rootId,
    this.rootName,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shop_name': Shopname,
      'root_id': rootId,
    };
  }

  // Create from Map
  factory Shopmodel.fromMap(Map<String, dynamic> map) {
    return Shopmodel(
      id: map['id'],
      Shopname: map['shop_name'],
      rootId: map['root_id'],
      rootName: map['root_name'], // For joined queries
    );
  }
}