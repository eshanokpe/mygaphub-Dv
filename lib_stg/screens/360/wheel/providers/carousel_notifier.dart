// providers/carousel_notifier.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wheel_item.dart';
import '../models/wheel_side_card.dart';

class CarouselState {
  final int selectedIndex;
  final double wheelRotation;
  final bool isDragging;           // ← NEW
  final List<WheelItem> wheelItems;
  final List<WheelItemSideCard> sideCardItems;

  const CarouselState({
    required this.selectedIndex,
    required this.wheelRotation,
    required this.isDragging,      // ← NEW
    required this.wheelItems,
    required this.sideCardItems,
  });

  CarouselState copyWith({
    int? selectedIndex,
    double? wheelRotation,
    bool? isDragging,              // ← NEW
  }) =>
      CarouselState(
        selectedIndex: selectedIndex ?? this.selectedIndex,
        wheelRotation: wheelRotation ?? this.wheelRotation,
        isDragging: isDragging ?? this.isDragging,   // ← NEW
        wheelItems: wheelItems,
        sideCardItems: sideCardItems,
      );
}

class CarouselNotifier extends Notifier<CarouselState> {
 
 double _rotationForIndex(int index, int total) {
  if (total == 0) return 0.0; // ← guard
  final sectionAngle = (2 * pi) / total;
  const double pointerAngle = -pi / 2;
  double r =
      (pointerAngle - (index * sectionAngle + sectionAngle / 2)) % (2 * pi);
  if (r > pi) r -= 2 * pi;
  return r;
}

  @override
  CarouselState build() {
    final items = <WheelItem>[
      WheelItem(
        title: "Net \n   Worth",
        iconRotation: 90 * pi / 2.0, 
        activeCardPath: 'assets/wheel_segments/networth_icon.png',
        segmentPath: 'assets/wheel_segments/segment_networth.png',
        centerIconPath: 'assets/wheel_segments/networth_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/networth_icon.png',
        gradienColor: [const Color(0xFF134EB2), const Color(0xFF0D2D60)],
      ),
      WheelItem(
        title: "Assets",
        iconRotation: 90 * pi / 5.1, 
        activeCardPath: 'assets/wheel_segments/Assets.png',
        segmentPath: 'assets/wheel_segments/segment_assets.png',
        centerIconPath: 'assets/wheel_segments/assets_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/assets_wheelIcon.png',
        gradienColor: [const Color(0xFF266C26), const Color(0xFF173C17)],
      ),
      WheelItem(
        title: "Income",
        iconRotation: 90 * pi / 5.1, 
        activeCardPath: 'assets/wheel_segments/Income.png',
        segmentPath: 'assets/wheel_segments/segment_income.png',
        centerIconPath: 'assets/wheel_segments/income_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/income_wheelIcon.png',
        gradienColor: [const Color(0xFFF6981E), const Color(0xFF825212)],
      ),
      WheelItem(
        title: "Strategy",
        iconRotation: 90 * pi / 5.1, 
        activeCardPath: 'assets/wheel_segments/Strategy.png',
        segmentPath: 'assets/wheel_segments/segment_strategy.png',
        centerIconPath: 'assets/wheel_segments/strategy_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/strategy_wheelIcon.png',
        gradienColor: [const Color(0xFFE85607), const Color(0xFF7B3002)],
      ), 
      WheelItem(
        title: "Philanthropy",
        iconRotation: 90 * pi / 4.1, 
        activeCardPath: 'assets/wheel_segments/Philanthropy.png',
        segmentPath: 'assets/wheel_segments/segment_philanthropy.png',
        centerIconPath: 'assets/wheel_segments/philanthropy_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/philanthropy_wheelIcon.png',
        gradienColor: [const Color(0xFFB20049), const Color(0xFF5F002A)],
      ),
      WheelItem(
        title: "Mortgage",
        iconRotation: 90 * pi / 3.2, 
        activeCardPath: 'assets/wheel_segments/Mortgage.png',
        segmentPath: 'assets/wheel_segments/segment_mortgage.png',
        centerIconPath: 'assets/wheel_segments/mortgage_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/networth_wheelIcon.png',
        gradienColor: [const Color(0xFF7A009A), const Color(0xFF420953)],
      ),
      WheelItem(
        title: "Cash",
        iconRotation: 90 * pi / 4.9,
        activeCardPath: 'assets/wheel_segments/Cash.png',
        segmentPath: 'assets/wheel_segments/segment_cash.png',
        centerIconPath: 'assets/wheel_segments/cash_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/networth_wheelIcon.png',
        gradienColor: [const Color(0xFF0F73C6), const Color(0xFF09406A)],
      ),
      WheelItem(
        title: "Investment",
        iconRotation: 90 * pi / 4.0,
        activeCardPath: 'assets/wheel_segments/Investment.png',
        segmentPath: 'assets/wheel_segments/segment_investment.png',
        centerIconPath: 'assets/wheel_segments/investment_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/networth_wheelIcon.png',
        gradienColor: [const Color(0xFF174E18), const Color(0xFF0F2B10)],
      ),
      WheelItem(
        title: "Retirement",
        iconRotation: 90 * pi / 5.0,
        activeCardPath: 'assets/wheel_segments/Retirement.png',
        segmentPath: 'assets/wheel_segments/segment_retirement.png',
        centerIconPath: 'assets/wheel_segments/retirement_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/networth_wheelIcon.png',
        gradienColor: [const Color(0xFFF9B423), const Color(0xFF846116)],
      ),
      WheelItem(
        title: "Protection",
        iconRotation: 90 * pi / 5.1,
        activeCardPath: 'assets/wheel_segments/Protection.png',
        segmentPath: 'assets/wheel_segments/segment_protection.png',
        centerIconPath: 'assets/wheel_segments/protection_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/networth_wheelIcon.png',
        gradienColor: [const Color(0xFFF06708), const Color(0xFF7F3802)],
      ),
      WheelItem(
        title: "Expenditure",
        iconRotation: 90 * pi / 5.1,
        activeCardPath: 'assets/wheel_segments/Expenditure.png',
        segmentPath: 'assets/wheel_segments/segment_expenditure.png',
        centerIconPath: 'assets/wheel_segments/expenditure_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/networth_wheelIcon.png',
        gradienColor: [const Color(0xFFC61A24), const Color(0xFF6A1116)],
      ),
      WheelItem(
        title: "Liabilities",
        iconRotation: 90 * pi / 5.1,
        activeCardPath: 'assets/wheel_segments/Liabilities.png',
        segmentPath: 'assets/wheel_segments/segment_liabilities.png',
        centerIconPath: 'assets/wheel_segments/liabilities_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/networth_wheelIcon.png',
        gradienColor: [const Color(0xFF560088), const Color(0xFF30034A)],
      ),
    ];

    final sideCards = <WheelItemSideCard>[
      WheelItemSideCard(title: items[0].title,  
        imagePath: 'assets/wheel_segments/networth_icon.png', 
        gradienColor: [const Color(0xFF134EB2), const Color(0xFF0D2D60)],),
      WheelItemSideCard(title: items[1].title, 
        imagePath: 'assets/wheel_segments/assets_icon.png',
        gradienColor: [const Color(0xFF266C26), const Color(0xFF173C17)],),
      WheelItemSideCard(title: items[2].title,  
        imagePath: 'assets/wheel_segments/income_icon.png',
         gradienColor: [const Color(0xFFF6981E), const Color(0xFF825212)],),
      WheelItemSideCard(title: items[3].title, 
        imagePath: 'assets/wheel_segments/strategy_icon.png',
         gradienColor: [const Color(0xFFE85607), const Color(0xFF7B3002)],),
      WheelItemSideCard(title: items[4].title,  
        imagePath: 'assets/wheel_segments/philanthropy_icon.png',  
        gradienColor: [const Color(0xFFB20049), const Color(0xFF5F002A)],),
      WheelItemSideCard(title: items[5].title,  
        imagePath: 'assets/wheel_segments/mortgage_icon.png',
        gradienColor: [const Color(0xFF7A009A), const Color(0xFF420953)],),
      WheelItemSideCard(title: items[6].title,  
        imagePath: 'assets/wheel_segments/cash_icon.png',
        gradienColor: [const Color(0xFF0F73C6), const Color(0xFF09406A)],),
      WheelItemSideCard(title: items[7].title,  
      imagePath: 'assets/wheel_segments/investment_icon.png',
       gradienColor: [const Color(0xFF174E18), const Color(0xFF0F2B10)],),
      WheelItemSideCard(title: items[8].title,  
        imagePath: 'assets/wheel_segments/retirement_icon.png',
        gradienColor: [const Color(0xFFF06708), const Color(0xFF7F3802)],),
      WheelItemSideCard(title: items[9].title,  
        imagePath: 'assets/wheel_segments/protection_icon.png',
       gradienColor: [const Color(0xFFF06708), const Color(0xFF7F3802)],),
      WheelItemSideCard(title: items[10].title, 
        imagePath: 'assets/wheel_segments/expenditure_icon.png',
       gradienColor: [const Color(0xFFC61A24), const Color(0xFF6A1116)],),
      WheelItemSideCard(
        title: items[11].title, 
        imagePath: 'assets/wheel_segments/liabilities_icon.png',
        gradienColor: [const Color(0xFF560088), const Color(0xFF30034A)],),
    ];

    return CarouselState(
      selectedIndex: 0,
      wheelRotation: _rotationForIndex(0, items.length),
      isDragging: false,           // ← NEW
      wheelItems: items,
      sideCardItems: sideCards,
    );
  }

  void selectIndex(int index) {
    final total = state.wheelItems.length;
    if (total == 0) return; // ← guard
    final real = ((index % total) + total) % total;
    HapticFeedback.lightImpact();
    state = state.copyWith(
      selectedIndex: real,
      wheelRotation: _rotationForIndex(real, total),
      isDragging: false,
    );
  }

  void next() => selectIndex(state.selectedIndex + 1);
  void previous() => selectIndex(state.selectedIndex - 1);

  void updateRotation(double delta) {
    final total = state.wheelItems.length;
    if (total == 0) return; // ← guard

    final newRotation = state.wheelRotation + delta;
    final sectionAngle = (2 * pi) / total;

    double norm = newRotation % (2 * pi);
    if (norm < 0) norm += 2 * pi;
    double diff = (-pi / 2 - norm) % (2 * pi);
    final newIndex = (diff / sectionAngle).floor() % total;

    state = state.copyWith(
      wheelRotation: newRotation,
      selectedIndex: newIndex,
      isDragging: true,
    );
  }

  void snapToNearest() {
    // Animate wheel to the clean snap angle, clear drag flag
    selectIndex(state.selectedIndex);
  }
}