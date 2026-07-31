
class PropertyModel {
  final int propertyId;
  final String propertyName;
  final String propertyFeaturedImage;
  final List<String> propertyGalleryImages;
  final String propertyContent;
  final String propertyAddress;
  final String propertyCountrie;
  final String noOfBedroom;
  final String noOfBathroom;
  final String propertyArea;
  final String propertySaleOptions;
  final String propertyPrice;
  final PropertyType propertyType;
  final String propertyTotalPrice;
  final String pricePerMonth;

  PropertyModel({
    required this.propertyId,
    required this.propertyName,
    required this.propertyFeaturedImage,
    required this.propertyGalleryImages,
    required this.propertyContent,
    required this.propertyAddress,
    required this.propertyCountrie,
    required this.noOfBedroom,
    required this.noOfBathroom,
    required this.propertyArea,
    required this.propertySaleOptions,
    required this.propertyPrice,
    required this.propertyType,
    required this.propertyTotalPrice,
    required this.pricePerMonth,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      propertyId: json['property_id'],
      propertyName: json['property_name'],
      propertyFeaturedImage: json['property_featured_image'],
      propertyGalleryImages: json['property_gallery_images'] == false
          ? []
          : List<String>.from(json['property_gallery_images']),
      propertyContent: json['property_content'],
      propertyAddress: json['property_address'],
      propertyCountrie: json['property_countrie'],
      noOfBedroom: json['no_of_bedroom'],
      noOfBathroom: json['no_of_bathroom'],
      propertyArea: json['property_area'],
      propertySaleOptions: json['property_sale_options'],
      propertyPrice: json['property_price'],
      propertyType: PropertyType.fromJson(json['property_type']),
      propertyTotalPrice: json['property_total_price'],
      pricePerMonth: json['price_per_month'],
    );
  }
}

class PropertyType {
  final int termId;
  final String name;
  final String slug;

  PropertyType({
    required this.termId,
    required this.name,
    required this.slug,
  });

  factory PropertyType.fromJson(Map<String, dynamic> json) {
    return PropertyType(
      termId: json['term_id'],
      name: json['name'],
      slug: json['slug'],
    );
  }
}
