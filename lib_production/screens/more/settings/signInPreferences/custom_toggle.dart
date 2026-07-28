import 'package:flutter/material.dart';

enum CustomToggleType { android, ios, square, custom }

class CustomToggle extends StatefulWidget {
  const CustomToggle({
    Key? key,
    required this.onChanged,
    required this.value,
    this.enabledText,
    this.disabledText,
    this.enabledTextStyle,
    this.enabledThumbColor,
    this.enabledTrackColor,
    this.disabledTextStyle,
    this.disabledTrackColor,
    this.disabledThumbColor,
    this.type = CustomToggleType.ios,
    this.boxShape,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 400),
    this.trackWidth,
  }) : super(key: key);

  final String? enabledText;
  final String? disabledText;
  final TextStyle? enabledTextStyle;
  final TextStyle? disabledTextStyle;
  final Color? enabledThumbColor;
  final Color? disabledThumbColor;
  final Color? enabledTrackColor;
  final Color? disabledTrackColor;
  final BoxShape? boxShape;
  final BorderRadius? borderRadius;
  final Duration duration;
  final CustomToggleType? type;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final double? trackWidth;

  @override
  _CustomToggleState createState() => _CustomToggleState();
}

class _CustomToggleState extends State<CustomToggle>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offset;
  late bool isOn;

  double _calculateThumbOffset() {
    final double track = widget.trackWidth ?? 54;
    const double thumbSize = 22;
    const double padding = 3;
    return (track - thumbSize - padding) / thumbSize;
  }

  @override
  void initState() {
    super.initState();
    isOn = widget.value;
    controller = AnimationController(duration: widget.duration, vsync: this);

    final double thumbOffset = _calculateThumbOffset();

    offset = (isOn
            ? Tween<Offset>(
                begin: Offset(thumbOffset, 0),
                end: Offset.zero,
              )
            : Tween<Offset>(
                begin: Offset.zero,
                end: Offset(thumbOffset, 0),
              ))
        .animate(controller);
  }

  @override
  void didUpdateWidget(CustomToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() {
        isOn = widget.value;
      });
      final double thumbOffset = _calculateThumbOffset();
      offset = (isOn
              ? Tween<Offset>(
                  begin: Offset(thumbOffset, 0),
                  end: Offset.zero,
                )
              : Tween<Offset>(
                  begin: Offset.zero,
                  end: Offset(thumbOffset, 0),
                ))
          .animate(controller);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onStatusChange() {
    setState(() {
      isOn = !isOn;
    });
    switch (controller.status) {
      case AnimationStatus.dismissed:
        controller.forward();
        break;
      case AnimationStatus.completed:
        controller.reverse();
        break;
      default:
    }
    widget.onChanged(isOn);
  }

  @override
  Widget build(BuildContext context) {
    final bool isIos = widget.type == CustomToggleType.ios;
    final bool isAndroid = widget.type == CustomToggleType.android;
    final bool isSquare = widget.type == CustomToggleType.square;
    final bool isCustom = widget.type == CustomToggleType.custom;

    final double containerWidth = widget.trackWidth ?? (isAndroid ? 46.5 : 55);
    final double trackWidth = widget.trackWidth ?? (isIos ? 54 : 46);

    return Stack(
      children: <Widget>[
        Container(
          height: isAndroid ? 25 : 30,
          width: containerWidth,
        ),
        Positioned(
          top: 5,
          child: InkWell(
            borderRadius: isSquare
                ? const BorderRadius.all(Radius.circular(0))
                : widget.borderRadius ??
                    const BorderRadius.all(Radius.circular(20)),
            onTap: onStatusChange,
            child: Container(
              width: trackWidth,
              height: isIos ? 25 : 18,
              decoration: BoxDecoration(
                color: isOn
                    ? widget.enabledTrackColor ?? Colors.lightGreen
                    : widget.disabledTrackColor ?? Colors.grey,
                borderRadius: isSquare
                    ? const BorderRadius.all(Radius.circular(0))
                    : widget.borderRadius ??
                        const BorderRadius.all(Radius.circular(20)),
              ),
              padding: isIos
                  ? const EdgeInsets.only(left: 3.5, right: 3.5)
                  : const EdgeInsets.only(left: 7, right: 7),
              child: isOn
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        (widget.enabledText != null &&
                                    widget.enabledText!.length > 4
                                ? widget.enabledText?.substring(0, 4)
                                : widget.enabledText) ??
                            (isCustom ? 'ON' : ''),
                        style: widget.enabledTextStyle ??
                            (isIos
                                ? const TextStyle(
                                    color: Colors.white, fontSize: 12)
                                : const TextStyle(
                                    color: Colors.white, fontSize: 8)),
                      ))
                  : Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        (widget.disabledText != null &&
                                    widget.disabledText!.length > 4
                                ? widget.disabledText?.substring(0, 4)
                                : widget.disabledText) ??
                            (isCustom ? 'OFF' : ''),
                        style: widget.disabledTextStyle ??
                            (isIos
                                ? const TextStyle(
                                    color: Colors.white, fontSize: 12)
                                : const TextStyle(
                                    color: Colors.white, fontSize: 8)),
                      )),
            ),
          ),
        ),
        Positioned(
          top: isIos ? 6.5 : 3,
          left: isIos ? 3 : 0,
          child: InkWell(
            onTap: onStatusChange,
            child: SlideTransition(
              position: offset,
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  shape: isSquare
                      ? BoxShape.rectangle
                      : widget.boxShape ?? BoxShape.circle,
                  color: isOn
                      ? widget.enabledThumbColor ?? Colors.white
                      : widget.disabledThumbColor ?? Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.16),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}