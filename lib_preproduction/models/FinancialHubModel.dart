class FinancialHubModel {
  final int id;
  final String title;
  final String category;
  final String bannerUrl;
  final String videoLink;

  FinancialHubModel({
    required this.id,
    required this.title,
    required this.category,
    required this.bannerUrl,
    required this.videoLink,
  });

  factory FinancialHubModel.fromJson(Map<String, dynamic> json) {
    return FinancialHubModel(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      bannerUrl: json['banner_url'],
      videoLink: json['video_link'],
    );
  }
}
