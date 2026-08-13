class MarketOpportunity {
  final int id;
  final String title;
  final String bannerImage;
  final String buttonText;
  final String destinationLink;
  final bool isPublished;
  final String displayOrder;
  final String createdAt;
  final String updatedAt;
  final String bannerUrl;

  MarketOpportunity({
    required this.id,
    required this.title,
    required this.bannerImage,
    required this.buttonText,
    required this.destinationLink,
    required this.isPublished,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
    required this.bannerUrl,
  });

  factory MarketOpportunity.fromJson(Map<String, dynamic> json) {
    return MarketOpportunity(
      id: json['id'],
      title: json['title'],
      bannerImage: json['banner_image'],
      buttonText: json['button_text'],
      destinationLink: json['destination_link'],
      isPublished: json['is_published'],
      displayOrder: json['display_order'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      bannerUrl: json['banner_url'],
    );
  }
}
