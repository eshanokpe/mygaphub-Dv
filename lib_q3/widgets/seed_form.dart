import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SeedForm extends StatefulWidget {
  const SeedForm({
    super.key,
    this.name,
    this.symbol,
    this.enabled = true,
    this.hintText,
    this.maxLines = 1,
    this.onSaved,
    this.keyboardType,
    this.onChange,
    this.validator,
    this.inputFormatters,
    required this.controller,
  });

  final bool enabled;
  final int maxLines;
  final String? Function(String?)? validator;
  final String? name;
  final String? hintText;
  final String? symbol;
  final void Function(String)? onChange;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final void Function(String?)? onSaved;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<SeedForm> createState() => _SeedFormState();
}

class _SeedFormState extends State<SeedForm> {
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.all(width * .01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: height * .01),
          Padding(
            padding: EdgeInsets.only(left: width * .08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.name ?? '',
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
              inputFormatters: widget.inputFormatters,
              keyboardType: widget.keyboardType,
              controller: widget.controller,
              maxLines: widget.maxLines,
              validator: widget.validator,
              onChanged: widget.onChange,
              onSaved: widget.onSaved,
              enabled: widget.enabled,
              style: TextStyle(
                fontSize: width * .04,
                fontWeight: FontWeight.w300,
              ),
              decoration: InputDecoration(
                prefix: Text(widget.symbol ?? ''),
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
