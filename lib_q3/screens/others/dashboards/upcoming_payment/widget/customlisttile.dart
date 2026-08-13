import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String currency;
  final double width;
  final double amount;

  const CustomListTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.currency,
    required this.width,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xffD8D8D8), // Border color
            width: 0.5, // Border width
          ),
          color: const Color(0xffFDFDFD),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(imagePath),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
          fontSize: width * 0.040,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w300,
          fontSize: width * 0.040,
        ),
      ),
      trailing: Row(
        mainAxisSize:
            MainAxisSize.min, // Ensures the row takes minimum space necessary
        children: [
          Text(
            '$currency$amount',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: width * 0.050,
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Color(0xffCCCCCC)),
        ],
      ),
    );
  }
}
