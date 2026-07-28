class PropertyDetailModel {
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
  final String propertyTotalPrice;
  final String pricePerMonth;
  final String grossRoi;
  final String managementFee;
  final String propertyCouncilTax;
  final String miscAndOtherFees;
  final String totalDeductions;
  final String netRentalIncome;
  final String monthlyIncome;
  final String netRoi;
  final List<Map<String, dynamic>> factAndFeatures;
  final List<dynamic> propertyVideoList;
  final String brochure;
  final String neighbourhoodHighlights;
  final String propertyVirtualTourLink;
  final List<FloorPlanImage> floorPlanImages;
  final String sharePricePerUnit;
  final String virtualTourVideo;
  final int totalShareUnit;
  final int remainingShareUnit;
  // final String persentageRantalIncome;

  PropertyDetailModel({
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
    required this.propertyTotalPrice,
    required this.pricePerMonth,
    required this.grossRoi,
    required this.managementFee,
    required this.propertyCouncilTax,
    required this.miscAndOtherFees,
    required this.totalDeductions,
    required this.netRentalIncome,
    required this.monthlyIncome,
    required this.netRoi,
    required this.factAndFeatures,
    required this.propertyVideoList,
    required this.brochure,
    required this.neighbourhoodHighlights,
    required this.floorPlanImages,
    required this.propertyVirtualTourLink,
    required this.sharePricePerUnit,
    required this.virtualTourVideo,
    required this.totalShareUnit,
    required this.remainingShareUnit,
    // @required this.persentageRantalIncome,
  });

  factory PropertyDetailModel.fromJson(Map<String, dynamic> json) {
    return PropertyDetailModel(
      propertyId: json['property_id'] ?? 0,
      propertyName: json['property_name'] ?? '',
      propertyFeaturedImage: json['property_featured_image'] ?? '',
      propertyGalleryImages: _parseGalleryImages(
        json['property_gallery_images'],
      ),
      propertyContent: json['property_content'] ?? '',
      propertyAddress: json['property_address'] ?? '',
      propertyCountrie: json['property_countrie'] ?? '',
      noOfBedroom: json['no_of_bedroom'] ?? '',
      noOfBathroom: json['no_of_bathroom'] ?? '',
      propertyArea: json['property_area'] ?? '',
      propertySaleOptions: json['property_sale_options'] ?? '',
      propertyTotalPrice: json['property_total_price'] ?? '',
      pricePerMonth: json['price_per_month'] ?? '',
      grossRoi: json['gross_roi'] ?? '',
      managementFee: json['management_fee'] ?? '',
      propertyCouncilTax: json['propertycouncil_tax'] ?? '',
      miscAndOtherFees: json['misc_&_other_fees'] ?? '',
      totalDeductions: json['total_deductions'] ?? '',
      netRentalIncome: json['net_rental_income'] ?? '',
      monthlyIncome: json['monthly_income'] ?? '',
      netRoi: json['net_roi'] ?? '',
      factAndFeatures: _parseFactAndFeatures(json['fact_and_features']),
      propertyVideoList: _parsePropertyVideoList(json['property_video_list']),
      brochure: _parseBrochure(json['brochure']),
      neighbourhoodHighlights: json['neighbourhood_highlights'] ?? '',
      floorPlanImages: json['floor_plan_images'] is List
          ? (json['floor_plan_images'] as List)
                .map((item) => FloorPlanImage.fromJson(item))
                .toList()
          : [],
      propertyVirtualTourLink: json['property_virtual_tour_link'] ?? '',
      sharePricePerUnit: json['share_price_per_unit'] ?? '',
      virtualTourVideo: _parseVirtualTourVideo(json['virtual_tour_video']),

      // totalShareUnit: json['total_share_unit'] ?? '0',
      // remainingShareUnit: json['remaining_share_unit'] ?? '0',
      // persentageRantalIncome: json['persentage_rantal_income'] ?? '0',
      totalShareUnit: _parseStringToInt(json['total_share_unit']),
      remainingShareUnit: _parseStringToInt(json['remaining_share_unit']),
      // persentageRantalIncome: json['persentage_rantal_income'] ?? '0',
    );
  }

  static List<String> _parseGalleryImages(dynamic galleryImages) {
    if (galleryImages is List) {
      return List<String>.from(galleryImages.whereType<String>());
    }
    return [];
  }

  static List<Map<String, dynamic>> _parsePropertyVideoList(
    dynamic propertyVideoList,
  ) {
    if (propertyVideoList is List) {
      return List<Map<String, dynamic>>.from(
        propertyVideoList.whereType<Map<String, dynamic>>(),
      );
    }
    return [];
  }

  static List<Map<String, dynamic>> _parseFactAndFeatures(
    dynamic factAndFeatures,
  ) {
    if (factAndFeatures is List) {
      return List<Map<String, dynamic>>.from(
        factAndFeatures.whereType<Map<String, dynamic>>(),
      );
    }
    return [];
  }

  static String _parseBrochure(dynamic brochure) {
    if (brochure is String) {
      return brochure;
    }
    return '';
  }

  static String _parseVirtualTourVideo(dynamic virtualTourVideo) {
    if (virtualTourVideo is String) {
      return virtualTourVideo;
    }
    return '';
  }
}

int _parseStringToInt(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) {
    print('Parsing value: $value');
    return 0; // Default value for blank or null
  }
  return int.tryParse(value.toString()) ?? 0; // Safely parse the value to int
}

class FloorPlanImage {
  final int id;
  final String title;
  final String filename;
  final int filesize;
  final String url;
  final String link;
  final String alt;
  final String author;
  final String description;
  final String caption;
  final String name;
  final String status;
  final int uploadedTo;
  final String date;
  final String modified;
  final int menuOrder;
  final String mimeType;
  final String type;
  final String subtype;
  final String icon;
  final int width;
  final int height;
  final Map<String, dynamic> sizes;

  FloorPlanImage({
    required this.id,
    required this.title,
    required this.filename,
    required this.filesize,
    required this.url,
    required this.link,
    required this.alt,
    required this.author,
    required this.description,
    required this.caption,
    required this.name,
    required this.status,
    required this.uploadedTo,
    required this.date,
    required this.modified,
    required this.menuOrder,
    required this.mimeType,
    required this.type,
    required this.subtype,
    required this.icon,
    required this.width,
    required this.height,
    required this.sizes,
  });

  factory FloorPlanImage.fromJson(Map<String, dynamic> json) {
    return FloorPlanImage(
      id: json['id'],
      title: json['title'],
      filename: json['filename'],
      filesize: json['filesize'],
      url: json['url'],
      link: json['link'],
      alt: json['alt'],
      author: json['author'],
      description: json['description'],
      caption: json['caption'],
      name: json['name'],
      status: json['status'],
      uploadedTo: json['uploaded_to'],
      date: json['date'],
      modified: json['modified'],
      menuOrder: json['menu_order'],
      mimeType: json['mime_type'],
      type: json['type'],
      subtype: json['subtype'],
      icon: json['icon'],
      width: json['width'],
      height: json['height'],
      sizes: json['sizes'],
    );
  }
}
