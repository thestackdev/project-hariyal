class ProductModel {
  dynamic id;
  String category, description, title;
  List<dynamic> images;
  Map<String, dynamic> location;
  bool isSold;

  ProductModel(
      {this.id,
      this.category,
      this.description,
      this.title,
      this.images,
      this.location,
      this.isSold});

  factory ProductModel.fromMap(Map<String, dynamic> map, dynamic id) {
    return ProductModel(
        id: id,
        category: map['category'],
        description: map['description'],
        images: map['images'],
        isSold: map['isSold'],
        location: map['location'],
        title: map['title']);
  }
}
