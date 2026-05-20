import 'package:flutter/material.dart';

const double _kScrollbarThickness = 6.0;

class MyScrollbar extends StatefulWidget {
  final ScrollableWidgetBuilder builder;
  final ScrollController? scrollController;

  const MyScrollbar({super.key, this.scrollController, required this.builder});

  @override
  _MyScrollbarState createState() => _MyScrollbarState();
}

class _MyScrollbarState extends State<MyScrollbar> {
  late ScrollbarPainter _scrollbarPainter;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollbarPainter = _buildMaterialScrollbarPainter();
    _updateScrollPainter(_scrollController.position);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollbarPainter = _buildMaterialScrollbarPainter();
  }

  @override
  void dispose() {
    _scrollbarPainter.dispose();
    super.dispose();
  }

  ScrollbarPainter _buildMaterialScrollbarPainter() {
    return ScrollbarPainter(
      color: Theme.of(context).highlightColor.withOpacity(1.0),
      textDirection: Directionality.of(context),
      thickness: _kScrollbarThickness,
      fadeoutOpacityAnimation: const AlwaysStoppedAnimation<double>(1.0),
      padding: MediaQuery.of(context).padding,
    );
  }

  bool _updateScrollPainter(ScrollMetrics position) {
    _scrollbarPainter.update(position, position.axisDirection);
    return false;
  }

  @override
  void didUpdateWidget(MyScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController != oldWidget.scrollController) {
      _scrollController = widget.scrollController ?? ScrollController();
      _updateScrollPainter(_scrollController.position);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _updateScrollPainter(notification.metrics);
        return false;
      },
      child: CustomPaint(
        painter: _scrollbarPainter,
        child: widget.builder(context, _scrollController),
      ),
    );
  }
}
