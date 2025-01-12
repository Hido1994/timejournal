import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';

class DateTimePickerTextFormField extends StatefulWidget {
  final DateTime? initialValue;
  final String title;
  final ValueSetter<DateTime> onChanged;
  final FormFieldValidator<String>? validator;

  const DateTimePickerTextFormField({
    super.key,
    required this.title,
    required this.onChanged,
    this.initialValue,
    this.validator,
  });

  @override
  State<DateTimePickerTextFormField> createState() =>
      _DateTimePickerTextFormFieldState();
}

class _DateTimePickerTextFormFieldState
    extends State<DateTimePickerTextFormField> {
  static final DateFormat dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');

  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _dateController.text = dateTimeFormat.format(widget.initialValue!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(label: Text(widget.title)),
      readOnly: true,
      controller: _dateController,
      onTap: () {
        DatePicker.showDateTimePicker(context, showTitleActions: true,
            onConfirm: (date) {
          widget.onChanged(date);
          _dateController.text = dateTimeFormat.format(date);
        }, currentTime: widget.initialValue, locale: LocaleType.de);
      },
      validator: widget.validator,
    );
  }
}
