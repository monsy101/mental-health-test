class ProductModel {
  int? id;
  String? title;
  dynamic? price;
  String? image;
  String? description;
  String? category;
  String? brand;

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    price = json['price'];
    image = json['image'];
    description = json['description'];
    category = json['category'];
    brand = json['brand'];
  }
}
