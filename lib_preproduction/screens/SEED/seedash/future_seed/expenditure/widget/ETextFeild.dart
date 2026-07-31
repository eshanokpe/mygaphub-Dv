import 'package:flutter/material.dart';

class ETextForm extends StatefulWidget {
  const ETextForm({
    super.key, // Use `Key?` instead of `Key`
    this.symbol,
    this.enabled = true,
    this.hintText,
    this.maxLines = 1, // Default to 1 line
    this.onSaved,
    this.keyboardType,
    this.onChanged, // Renamed to follow Dart naming conventions
    this.validator,
    required this.controller, // Mark `controller` as required
  });

  final bool enabled;
  final int maxLines;
  final String? hintText;
  final String? symbol;
  final Function(String)? onChanged; // Use `Function(String)` for `onChanged`
  final TextInputType? keyboardType;
  final TextEditingController controller; // Remove `?` since it's required
  final Function(String?)? onSaved; // Use `Function(String?)` for `onSaved`
  final String? Function(String?)? validator; // Correct type for `validator`

  @override
  State<ETextForm> createState() => _ETextFormState();
}

class _ETextFormState extends State<ETextForm> {
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.all(width * .0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: width * .08,
              top: height * .0,
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
      ),
    );
  }
}
