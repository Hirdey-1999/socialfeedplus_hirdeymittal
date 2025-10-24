import 'package:flutter/material.dart';

class CommonWidgets {
  static Widget textField(
    BuildContext context, {
    required TextEditingController controller,
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    int? minLines,
    int? maxLines = 1,
    FocusNode? focusNode,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (labelText != null)
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  labelText,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              )
            : SizedBox.shrink(),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          style: TextStyle(fontWeight: FontWeight.w500),
          obscureText: obscureText,
          focusNode: focusNode,
          minLines: minLines,
          maxLines: maxLines,
          decoration: InputDecoration(
            // labelText: labelText,
            hintText: hintText,
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            contentPadding: contentPadding ?? EdgeInsets.only(left: 20),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  static Widget customLoader() {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.25),
    );
  }
}
