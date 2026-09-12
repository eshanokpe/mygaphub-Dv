// providers/carousel_notifier.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wheel_item.dart';
import '../models/wheel_side_card.dart';

class CarouselState {
  final int selectedIndex;
  final double wheelRotation;
  final bool isDragging; // ← NEW
  final List<WheelItem> wheelItems;
  final List<WheelItemSideCard> sideCardItems;

  const CarouselState({
    required this.selectedIndex,
    required this.wheelRotation,
    required this.isDragging, // ← NEW
    required this.wheelItems,
    required this.sideCardItems,
  });

  CarouselState copyWith({
    int? selectedIndex,
    double? wheelRotation,
    bool? isDragging, // ← NEW
  }) => CarouselState(
    selectedIndex: selectedIndex ?? this.selectedIndex,
    wheelRotation: wheelRotation ?? this.wheelRotation,
    isDragging: isDragging ?? this.isDragging, // ← NEW
    wheelItems: this.wheelItems,
    sideCardItems: sideCardItems,
  );
}

class CarouselNotifier extends Notifier<CarouselState> {
  // Adjust each active wheel independently.
  static const double wheelRotation = -7 * pi / 12;
  static const double wheelRotation1 = -3 * pi / 4;
  static const double wheelRotation2 = -11 * pi / 12;
  static const double wheelRotation3 = 11 * pi / 12;
  static const double wheelRotation4 = 3 * pi / 4;
  static const double wheelRotation5 = 7 * pi / 12;
  static const double wheelRotation6 = 5 * pi / 12;
  static const double wheelRotation7 = pi / 4;
  static const double wheelRotation8 = pi / 12;
  static const double wheelRotation9 = -pi / 12;
  static const double wheelRotation10 = -pi / 4;
  static const double wheelRotation11 = -5 * pi / 12;

  // Each row belongs to one active wheel and contains angles for the other
  // wheel icons. Use null for the active item's unused child angle.
  static const List<List<double?>> childWheelRotations = [
    [
      null,
      90 * pi / 1.890,
      90 * pi / 1.10,
      90 * pi / 3.16,
      90 * pi / 5.020,
      0.0,
      0.0,
      0.0,
      0.0,
      90 * pi / 2.230,
      90 * pi / 4.950,
      90 * pi / 1.9900,
    ],
    [
      90 * pi / 2.090,
      null,
      90 * pi / 2.280,
      90 * pi / 5.010,
      90 * pi / 5.070,
      0.0,
      0.0,
      0.0,
      0.0,
      90 * pi / 5.090,
      90 * pi / 5.050,
      90 * pi / 1.110,
    ],
    [
      90 * pi / 2.1,
      90 * pi / 2.445, //assets
      null,
      90 * pi / 5.040, //stretegy
      90 * pi / 4.650, //philanthropy
      90 * pi / 1.1026, // Mortage
      0.0,
      0.0,
      0.0,
      90 * pi / 5.300,
      0.0,
      90 * pi / 4.3750, //cash
    ],
    [
      90 * pi / 4.020, //network
      90 * pi / 3.630, //assets
      90 * pi / 4.299, //income
      null,
      90 * pi / 5.300, //philanthropy
      90 * pi / 4.240, //morgage
      90 * pi / 1.899, //cash
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
    [
      90 * pi / 2.1,
      90 * pi / 1.9,
      90 * pi / 1.099990 * 0.1,
      90 * pi / 5.010,
      null,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      90 * pi / 5.020,
      90 * pi / 1.9900,
    ],
    [
      90 * pi / 2.1,
      90 * pi / 1.9,
      90 * pi / 1.099990 * 0.1,
      90 * pi / 5.010,
      90 * pi / 5.020,
      null,
      0.0,
      0.0,
      0.0,
      0.0,
      90 * pi / 5.020,
      90 * pi / 1.9900,
    ],
    [
      90 * pi / 2.1,
      90 * pi / 1.9,
      90 * pi / 1.099990 * 0.1,
      90 * pi / 5.010,
      90 * pi / 5.020,
      0.0,
      null,
      0.0,
      0.0,
      0.0,
      90 * pi / 5.020,
      90 * pi / 1.9900,
    ],
    [
      90 * pi / 2.1,
      90 * pi / 1.9,
      90 * pi / 1.099990 * 0.1,
      90 * pi / 5.010,
      90 * pi / 5.020,
      0.0,
      0.0,
      null,
      0.0,
      0.0,
      90 * pi / 5.020,
      90 * pi / 1.9900,
    ],
    [
      90 * pi / 2.1,
      90 * pi / 1.9,
      90 * pi / 1.099990 * 0.1,
      90 * pi / 5.010,
      90 * pi / 5.020,
      0.0,
      0.0,
      0.0,
      null,
      0.0,
      90 * pi / 5.020,
      90 * pi / 1.9900,
    ],
    // Protection
    [
      90 * pi / 1.900,
      90 * pi / 1.200,
      90 * pi / 5.010,
      90 * pi / 5.020,
      0.0,
      0.0,
      0.0,
      90 * pi / 0.190, // investment
      90 * pi / 0.090, //retirement
      null,
      90 * pi / 5.020,
      90 * pi / 1.9900,
    ],
    [
      90 * pi / 2.1,
      90 * pi / 1.9,
      90 * pi / 1.099990 * 0.1,
      90 * pi / 5.010,
      90 * pi / 5.020,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      null,
      90 * pi / 1.9900,
    ],
    [
      90 * pi / 2.390,
      90 * pi / 1.880,
      90 * pi / 1.099990 * 0.1,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      90 * pi / 5.430,
      90 * pi / 5.430,
      90 * pi / 5.430,
      null,
    ],
  ];

  static const List<double> wheelRotations = [
    wheelRotation,
    wheelRotation1,
    wheelRotation2,
    wheelRotation3,
    wheelRotation4,
    wheelRotation5,
    wheelRotation6,
    wheelRotation7,
    wheelRotation8,
    wheelRotation9,
    wheelRotation10,
    wheelRotation11,
  ];

  double _rotationForIndex(int index) {
    return wheelRotations[index];
  }

  @override
  CarouselState build() {
    final items = <WheelItem>[
      WheelItem(
        title: "Net \n   Worth",
        iconRotation: 90 * pi / 2.4055,
        activeCardPath: 'assets/wheel_segments/networth_icon.png',
        segmentPath: 'assets/wheel_segments/segment_networth.png',
        centerIconPath: 'assets/wheel_segments/networth_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/networth_icon.png',
        gradienColor: [const Color(0xFF134EB2), const Color(0xFF0D2D60)],
      ),
      WheelItem(
        title: "Assets",
        iconRotation: 90 * pi / 2.1800,
        activeCardPath: 'assets/wheel_segments/Assets.png',
        segmentPath: 'assets/wheel_segments/segment_assets.png',
        centerIconPath: 'assets/wheel_segments/assets_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/assets_wheelIcon.png',
        gradienColor: [const Color(0xFF266C26), const Color(0xFF173C17)],
      ),
      WheelItem(
        title: "Income",
        iconRotation: 90 * pi / 2.900,
        activeCardPath: 'assets/wheel_segments/Income.png',
        segmentPath: 'assets/wheel_segments/segment_income.png',
        centerIconPath: 'assets/wheel_segments/income_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/income_wheelIcon.png',
        gradienColor: [const Color(0xFFF6981E), const Color(0xFF825212)],
      ),
      WheelItem(
        title: "Strategy",
        iconRotation: 90 * pi / 5.320,
        activeCardPath: 'assets/wheel_segments/Strategy.png',
        segmentPath: 'assets/wheel_segments/segment_strategy.png',
        centerIconPath: 'assets/wheel_segments/strategy_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/strategy_wheelIcon.png',
        gradienColor: [const Color(0xFFE85607), const Color(0xFF7B3002)],
      ),
      WheelItem(
        title: "Philanthropy",
        iconRotation: 90 * pi / 1.980,
        activeCardPath: 'assets/wheel_segments/Philanthropy.png',
        segmentPath: 'assets/wheel_segments/segment_philanthropy.png',
        centerIconPath: 'assets/wheel_segments/philanthropy_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/philanthropy_wheelIcon.png',
        gradienColor: [const Color(0xFFB20049), const Color(0xFF5F002A)],
      ),
      WheelItem(
        title: "Mortgage",
        iconRotation: 1.5,
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
        iconRotation: 90 * pi / 5.210,
        activeCardPath: 'assets/wheel_segments/Protection.png',
        segmentPath: 'assets/wheel_segments/segment_protection.png',
        centerIconPath: 'assets/wheel_segments/protection_icon.png',
        centerIconRotation: 90 * pi / 2.1112,
        centerWheelIconPath: 'assets/wheel_segments/networth_wheelIcon.png',
        gradienColor: [const Color(0xFFF06708), const Color(0xFF7F3802)],
      ),
      WheelItem(
        title: "Expenditure",
        iconRotation: 90 * pi / 1.270,
        activeCardPath: 'assets/wheel_segments/Expenditure.png',
        segmentPath: 'assets/wheel_segments/segment_expenditure.png',
        centerIconPath: 'assets/wheel_segments/expenditure_icon.png',
        centerIconRotation: 90 * pi / 2.20,
        // centerWheelIconPath: 'assets/wheel_segments/networth_wheelIcon.png',
        gradienColor: [const Color(0xFFC61A24), const Color(0xFF6A1116)],
      ),
      WheelItem(
        title: "Liabilities",
        iconRotation: 90 * pi / 1.680,
        activeCardPath: 'assets/wheel_segments/Liabilities.png',
        segmentPath: 'assets/wheel_segments/segment_liabilities.png',
        centerIconPath: 'assets/wheel_segments/liabilities_icon.png',
        centerWheelIconPath: 'assets/wheel_segments/networth_wheelIcon.png',
        gradienColor: [const Color(0xFF560088), const Color(0xFF30034A)],
      ),
    ];

    final sideCards = <WheelItemSideCard>[
      WheelItemSideCard(
        title: items[0].title,
        imagePath: 'assets/wheel_segments/networth_icon.png',
        gradienColor: [const Color(0xFF134EB2), const Color(0xFF0D2D60)],
      ),
      WheelItemSideCard(
        title: items[1].title,
        imagePath: 'assets/wheel_segments/assets_icon.png',
        gradienColor: [const Color(0xFF266C26), const Color(0xFF173C17)],
      ),
      WheelItemSideCard(
        title: items[2].title,
        imagePath: 'assets/wheel_segments/income_icon.png',
        gradienColor: [const Color(0xFFF6981E), const Color(0xFF825212)],
      ),
      WheelItemSideCard(
        title: items[3].title,
        imagePath: 'assets/wheel_segments/strategy_icon.png',
        gradienColor: [const Color(0xFFE85607), const Color(0xFF7B3002)],
      ),
      WheelItemSideCard(
        title: items[4].title,
        imagePath: 'assets/wheel_segments/philanthropy_icon.png',
        gradienColor: [const Color(0xFFB20049), const Color(0xFF5F002A)],
      ),
      WheelItemSideCard(
        title: items[5].title,
        imagePath: 'assets/wheel_segments/mortgage_icon.png',
        gradienColor: [const Color(0xFF7A009A), const Color(0xFF420953)],
      ),
      WheelItemSideCard(
        title: items[6].title,
        imagePath: 'assets/wheel_segments/cash_icon.png',
        gradienColor: [const Color(0xFF0F73C6), const Color(0xFF09406A)],
      ),
      WheelItemSideCard(
        title: items[7].title,
        imagePath: 'assets/wheel_segments/investment_icon.png',
        gradienColor: [const Color(0xFF174E18), const Color(0xFF0F2B10)],
      ),
      WheelItemSideCard(
        title: items[8].title,
        imagePath: 'assets/wheel_segments/retirement_icon.png',
        gradienColor: [const Color(0xFFF06708), const Color(0xFF7F3802)],
      ),
      WheelItemSideCard(
        title: items[9].title,
        imagePath: 'assets/wheel_segments/protection_icon.png',
        gradienColor: [const Color(0xFFF06708), const Color(0xFF7F3802)],
      ),
      WheelItemSideCard(
        title: items[10].title,
        imagePath: 'assets/wheel_segments/expenditure_icon.png',
        gradienColor: [const Color(0xFFC61A24), const Color(0xFF6A1116)],
      ),
      WheelItemSideCard(
        title: items[11].title,
        imagePath: 'assets/wheel_segments/liabilities_icon.png',
        gradienColor: [const Color(0xFF560088), const Color(0xFF30034A)],
      ),
    ];

    return CarouselState(
      selectedIndex: 0,
      wheelRotation: _rotationForIndex(0),
      isDragging: false, // ← NEW
      wheelItems: items,
      sideCardItems: sideCards,
    );
  }

  void selectIndex(int index) {
    final total = state.wheelItems.length;
    if (total == 0) return; // ← guard
    final real = ((index % total) + total) % total;
    state = state.copyWith(
      selectedIndex: real,
      wheelRotation: _rotationForIndex(real),
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
