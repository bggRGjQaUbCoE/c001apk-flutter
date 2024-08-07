class FeedArticle {
  String? type;
  String? message;
  String? url;
  String? description;
  String? title;
  String? subTitle;
  String? logo;

  FeedArticle({
    this.type,
    this.message,
    this.url,
    this.description,
    this.title,
    this.subTitle,
    this.logo,
  });

  factory FeedArticle.fromJson(Map<String, dynamic> json) {
    return FeedArticle(
      type: json['type'] as String?,
      message: json['message'] as String?,
      url: json['url'] as String?,
      description: json['description'] as String?,
      title: json['title'] as String?,
      subTitle: json['subTitle'] as String?,
      logo: json['logo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'url': url,
      'description': description,
      'title': title,
      'subTitle': subTitle,
      'logo': logo,
    };
  }
}
