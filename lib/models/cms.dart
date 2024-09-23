

class Album {
  final String? href;
  final String? id;
  final String? title;
  final String? imgUrl;

  Album({this.href, this.id, this.title, this.imgUrl});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      href: json['href'],
      id: json['id'],
      title: json['title'],
      imgUrl: json['imgUrl'],
    );
  }
}