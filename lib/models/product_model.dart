// Data models 
class Product {
  int id;
  String title;
  num price;
  String description;
  String category;
  String image;
  Rating? rating;
 
  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    this.rating
  });
 
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      description: json['description'],
      category: json['category'],
      image: json['image'],
      rating: json['rating'] != null ? Rating.fromJson(json['rating']) : null
    );
  }
 
}
 
class Rating {
  num? rate;
  int? count;
 
  Rating({
    this.rate, 
    this.count});
 
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rate: json['rate'],
      count: json['count']
    );
  }
 
}