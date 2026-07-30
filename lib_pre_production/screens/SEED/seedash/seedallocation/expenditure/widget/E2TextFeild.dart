import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class E2TextForm extends StatefulWidget {
  const E2TextForm({
    super.key,
    this.name,
    this.symbol,
    this.enabled = true,
    this.hintText,
    this.maxLines,
    this.onSaved,
    this.keyboardType,
    this.onChange,
    this.validator,
    this.inputFormatters = const [],
    required this.controller,
  });

  final bool enabled;
  final int? maxLines;
  final String? Function(String?)? validator;
  final String? name;
  final String? hintText;
  final String? symbol;
  final void Function(String?)? onChange;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final void Function(String?)? onSaved;
  final List<TextInputFormatter> inputFormatters;

  @override
  State<E2TextForm> createState() => _E2TextFormState();
}

class _E2TextFormState extends State<E2TextForm> {
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.name != null) // Only display if name is provided
          Padding(
            padding: EdgeInsets.only(left: width * .08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.name!,
                  style: TextStyle(
                    fontSize: width * .04,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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
            inputFormatters: widget.inputFormatters,
            maxLines: widget.maxLines,
            validator: widget.validator,
            onChanged: widget.onChange,
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
