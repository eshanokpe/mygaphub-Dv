import 'package:flutter/material.dart';

class ETextForm extends StatefulWidget {
  const ETextForm({
    super.key,
    this.symbol = "",
    this.enabled = true,
    this.hintText,
    this.maxLines = 1,
    this.onSaved,
    this.keyboardType,
    this.onChange,
    this.validator,
    required this.controller,
  });

  final bool enabled;
  final int maxLines;
  final String? hintText;
  final String symbol;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final void Function(String?)? onSaved;
  final void Function(String)? onChange;
  final String? Function(String?)? validator;

  @override
  State<ETextForm> createState() => _ETextFormState();
}

class _ETextFormState extends State<ETextForm> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.08),
      child: TextFormField(
        keyboardType: widget.keyboardType,
        controller: widget.controller,
        maxLines: widget.maxLines,
        validator: widget.validator,
        onChanged: widget.onChange,
        onSaved: widget.onSaved,
        enabled: widget.enabled,
        style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.w300),
        decoration: InputDecoration(
          prefixText: widget.symbol.isNotEmpty ? "${widget.symbol} " : null,
          filled: true,
          hintText: widget.hintText,
          contentPadding: EdgeInsets.symmetric(
            vertical: width * 0.04,
            horizontal: width * 0.02,
          ),
          disabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(width * 0.02),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFC4C4C4)),
            borderRadius: BorderRadius.circular(width * 0.02),
          ),
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(width * 0.01),
          ),
        ),
      ),
    );
  }
}
