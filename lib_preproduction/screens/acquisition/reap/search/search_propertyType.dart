import 'package:GapHub/provider/acquisiProvider.dart';
import 'package:GapHub/provider/acquisitionProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPropertyType extends StatefulWidget {
  const SearchPropertyType({super.key}); // Pass key to super

  @override
  State<SearchPropertyType> createState() => _SearchPropertyTypeState();
}

class _SearchPropertyTypeState extends State<SearchPropertyType> {
  @override
  Widget build(BuildContext context) {
    final acquisitionProvider = context.watch<AcquisiProvider>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(acquisitionProvider.propertyType.length, (
          index,
        ) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
            child: GestureDetector(
              onTap: () {
                acquisitionProvider.onPropertyType(
                  acquisitionProvider.propertyType[index],
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: acquisitionProvider.isSelectedPropertyType[index]
                      ? Colors.black
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xffe5e5e5),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      acquisitionProvider.propertyType[index],
                      style: TextStyle(
                        color: acquisitionProvider.isSelectedPropertyType[index]
                            ? Colors.white
                            : Colors.black,
                        fontSize: 14,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 5),
                    if (acquisitionProvider.isSelectedPropertyType[index])
                      const Icon(Icons.check, color: Colors.white, size: 15),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
