import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AutocompleteTextFormField extends StatefulWidget {
  final String? initialValue;
  final String title;
  final List<String> options;
  final ValueSetter<String> onChanged;
  final ValueSetter<String>? onSelected;
  final TextInputType textInputType;
  final FormFieldValidator<String>? validator;

  const AutocompleteTextFormField(
      {super.key,
      required this.title,
      required this.options,
      required this.onChanged,
      this.onSelected,
      this.initialValue,
      this.textInputType = TextInputType.text,
      this.validator});

  @override
  State<AutocompleteTextFormField> createState() =>
      _AutocompleteTextFormFieldState();
}

class _AutocompleteTextFormFieldState extends State<AutocompleteTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Autocomplete(
      initialValue: TextEditingValue(text: widget.initialValue ?? ''),
      optionsBuilder: (TextEditingValue textEditingValue) {
        // if (textEditingValue.text == '') {
        return widget.options;
        // } else {
        //   List<String> matches = <String>[];
        //   matches.addAll(widget.options);
        //
        //   matches.retainWhere((s) {
        //     return s
        //         .toLowerCase()
        //         .contains(textEditingValue.text.toLowerCase());
        //   });
        //   return matches;
        // }
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted) {
        return TextFormField(
          controller: fieldTextEditingController,
          focusNode: fieldFocusNode,
          onChanged: widget.onChanged,
          inputFormatters: widget.textInputType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          keyboardType: widget.textInputType,
          decoration: InputDecoration(label: Text(widget.title)),
          validator: widget.validator,
        );
      },
      onSelected: widget.onSelected ?? widget.onChanged,
    );
  }
}
