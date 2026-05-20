import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArchivedAssetCard extends StatelessWidget {
  final String name;
  final String createdAt;
  final String assetValue;
  final String monthlyROI;
  final String photo;

  const ArchivedAssetCard({
    required this.photo,
    required this.name,
    required this.createdAt,
    required this.assetValue,
    required this.monthlyROI,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * .02,
              vertical: MediaQuery.of(context).size.height * .015,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                photo == imgPrefixAssets
                    ? CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xffE84141), Color(0xffFA7070)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            name[0], // First letter of the name
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors
                                  .white, // Text color must be white for the gradient to show
                            ),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            Colors.grey[200], // Placeholder background color
                        child: ClipOval(
                          child: photo.isNotEmpty
                              ? Image.network(
                                  photo,
                                  fit: BoxFit.cover,
                                  width: 48, // Same as diameter (2 * radius)
                                  height: 48,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                            : null,
                                        strokeWidth: 2.0,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 24,
                                    ); // Fallback icon
                                  },
                                )
                              : const Icon(
                                  Icons.person, // Default icon for empty photo
                                  size: 24,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _capitalizeFirstLetter(name),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/timer_icon.png',
                            width: MediaQuery.of(context).size.width * .04,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formatDate(createdAt),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.grayColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _indicatorText(
                      context: context,
                      amount: assetValue,
                      color: Colors.green.shade200,
                      image: 'assets/images/green_arrow.png',
                    ),
                    // SizedBox(height: 8),
                    _indicatorText(
                      context: context,
                      amount: monthlyROI,
                      color: Colors.blue.shade200,
                      image: 'assets/images/blue_arrow.png',
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
          const Divider(color: AppColors.grayColor, height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/value_icon.png',
                      width: width * .04,
                    ),
                    SizedBox(width: width * .02),
                    const Text(
                      'Value',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grayColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/income_icon.png',
                      width: width * .04,
                    ),
                    SizedBox(width: width * .02),
                    const Text(
                      'Income',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grayColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text; // Return as is if empty
    return text[0].toUpperCase() + text.substring(1);
  }

  String formatDate(String createdAt) {
    DateTime date = DateTime.parse(createdAt);
    DateTime now = DateTime.now();

    // Check if the date is today
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Today";
    }

    // Format as "07 Jul" if not today
    return DateFormat("dd MMM").format(date);
  }

  Widget _indicatorText({
    BuildContext? context,
    String? amount,
    Color? color,
    String? image,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 4),
            Text(
              formatAmount(amount!),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        Image.asset(image!, width: MediaQuery.of(context!).size.width * .12),
      ],
    );
  }

  String formatAmount(String amount) {
    double? parsedAmount = double.tryParse(
      amount.replaceAll(RegExp(r'[^\d.]'), '').trim(),
    );

    if (parsedAmount == null) return 'Invalid amount';

    // Round to two decimal places
    String roundedAmount = parsedAmount.toStringAsFixed(2);

    // Apply comma formatting
    return roundedAmount.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
