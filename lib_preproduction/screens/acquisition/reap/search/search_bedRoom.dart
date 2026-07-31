import 'package:GapHub/provider/acquisiProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/acquisitionProvider.dart';

class SearchBedRooms extends StatefulWidget {
  const SearchBedRooms({super.key});

  @override
  State<SearchBedRooms> createState() => _SearchBedRoomsState();
}

class _SearchBedRoomsState extends State<SearchBedRooms> {
  @override
  Widget build(BuildContext context) {
    final acquisitionProvider = context.watch<AcquisiProvider>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(acquisitionProvider.bedRoom.length, (index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
            child: GestureDetector(
              onTap: () {
                acquisitionProvider.onBedroomsChanged(
                  acquisitionProvider.bedRoom[index],
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: acquisitionProvider.isSelectedBedRoom[index]
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
                      acquisitionProvider.bedRoom[index],
                      style: TextStyle(
                        color: acquisitionProvider.isSelectedBedRoom[index]
                            ? Colors.white
                            : Colors.black,
                        fontSize: 14,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 5),
                    if (acquisitionProvider.isSelectedBedRoom[index])
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
