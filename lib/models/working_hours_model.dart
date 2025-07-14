import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkingHourModel {
  final String day;
  String? open;
  String? close;
  bool isHoliday;

  WorkingHourModel({
    required this.day,
    this.open,
    this.close,
    required this.isHoliday,
  });

  factory WorkingHourModel.fromJson(Map<String, dynamic> json) =>
      WorkingHourModel(
        day: json['day'] as String,
        open: json['open'] as String?,
        close: json['close'] as String?,
        isHoliday: json['open'] != null ? false : json['isHoliday'] as bool,
      );

  Map<String, dynamic> toJson() => {
    'day': day,
    'open': open,
    'close': close,
    'isHoliday': isHoliday,
  };

  WorkingHourModel copyWith({
    String? day,
    String? open,
    String? close,
    bool? isHoliday,
  }) {
    return WorkingHourModel(
      day: day ?? this.day,
      open: open ?? this.open,
      close: close ?? this.close,
      isHoliday: isHoliday ?? this.isHoliday,
    );
  }

  static final _fmt = DateFormat.jm(); // 9:00 AM
  static TimeOfDay? _p(String? s) =>
      (s == null || s.isEmpty) ? null : TimeOfDay.fromDateTime(_fmt.parse(s));
  static String _f(MaterialLocalizations loc, TimeOfDay t) =>
      loc.formatTimeOfDay(t, alwaysUse24HourFormat: false);

  TimeOfDay? get openTOD => _p(open);
  TimeOfDay? get closeTOD => _p(close);

  /// return a NEW model with updated open / close (plus correct isHoliday flag)
  WorkingHourModel copyWithTOD({
    TimeOfDay? newOpen,
    TimeOfDay? newClose,
    required MaterialLocalizations loc,
  }) {
    final strOpen = newOpen == null ? null : _f(loc, newOpen);
    final strClose = newClose == null ? null : _f(loc, newClose);
    return WorkingHourModel(
      day: day,
      open: strOpen ?? open,
      close: strClose ?? close,
      isHoliday: (strOpen ?? open) == null || (strClose ?? close) == null,
    );
  }
}
