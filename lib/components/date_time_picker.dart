import 'package:flutter/material.dart';

class DateTimePicker {
  static Future<DateTime?> show(BuildContext context,
      {DateTime? initialDate, DateTime? firstDate, DateTime? lastDate}) async {
    initialDate ??= DateTime.now();
    firstDate ??= DateTime.now();
    lastDate ??= DateTime.now();
    var datePart = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate);

    if (datePart == null) {
      return null;
    }

    var timePart = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(initialDate));

    if (timePart == null) {
      return null;
    }

    return DateTime(datePart.year, datePart.month, datePart.day, timePart.hour,
        timePart.minute, 0);
  }
}
