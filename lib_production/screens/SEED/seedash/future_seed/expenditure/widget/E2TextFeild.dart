import 'package:flutter/material.dart';

class E2TextForm extends StatefulWidget {
  const E2TextForm({
    super.key,
    this.name,
    this.symbol,
    this.enabled = true,
    this.hintText,
    this.maxLines = 1, // Default to 1 line
    this.onSaved,
    this.keyboardType,
    this.onChanged, // Renamed to follow Dart naming conventions
    this.validator,
    required this.controller,
  });

  final bool enabled;
  final int maxLines;
  final String? name;
  final String? hintText;
  final String? symbol;
  final Function(String)? onChanged; // Use `Function(String)` for `onChanged`
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final Function(String?)? onSaved; // Use `Function(String?)` for `onSaved`
  final String? Function(String?)? validator; // Correct type for `validator`

  @override
  State<E2TextForm> createState() => _E2TextFormState();
}

class _E2TextFormState extends State<E2TextForm> {
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.name != null) // Only show the name if it's provided
          Padding(
            padding: EdgeInsets.only(left: width * .08),
            child: Text(
              widget.name!,
              style: TextStyle(
                fontSize: width * .05,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        SizedBox(height: height * .01),
        Padding(
          padding: EdgeInsets.only(
            left: width * .08,
            top: width * .02,
            right: width * .08,
          ),
          child: TextFormField(
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            controller: widget.controller,
            maxLines: widget.maxLines,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onSaved: widget.onSaved,
            style: TextStyle(
              fontSize: width * .04,
              fontWeight: FontWeight.w300,
            ),
            decoration: InputDecoration(
              prefix: widget.symbol != null ? Text(widget.symbol!) : null,
              filled: true,
              hintText: widget.hintText,
              contentPadding: EdgeInsets.only(
                top: width * .05,
                left: width * .02,
              ),
              disabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width * .02),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 196, 196, 196),
                ),
                borderRadius: BorderRadius.circular(width * .02),
              ),
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width * .01),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
