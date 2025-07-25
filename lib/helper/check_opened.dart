import 'package:intl/intl.dart';
import 'package:mediora/models/working_hours_model.dart';

enum ShopStatus { open, closed, closesSoon, opensSoon }

ShopStatus getShopStatus(
  List<WorkingHourModel> workingHours, {
  DateTime? now,
  int soonThresholdMins = 30,
}) {
  now ??= DateTime.now();
  final currentDay = DateFormat('EEEE').format(now);
  final today = workingHours.firstWhere(
    (e) => e.day.toLowerCase() == currentDay.toLowerCase(),
    orElse: () => WorkingHourModel(day: currentDay, isHoliday: true),
  );

  if (today.isHoliday || today.open == null || today.close == null) {
    final upcoming = workingHours.firstWhere(
      (e) =>
          !e.isHoliday &&
          e.open != null &&
          _parseTime(e.open!, now!, e.day).isAfter(now),
      orElse: () => today,
    );

    final nextOpenTime = _parseTime(
      upcoming.open ?? '12:00 AM',
      now,
      upcoming.day,
    );
    if (nextOpenTime.difference(now).inMinutes <= soonThresholdMins) {
      return ShopStatus.opensSoon;
    }
    return ShopStatus.closed;
  }

  final openTime = _parseTime(today.open!, now, today.day);
  final closeTime = _parseTime(today.close!, now, today.day);

  if (now.isAfter(openTime) && now.isBefore(closeTime)) {
    if (closeTime.difference(now).inMinutes <= soonThresholdMins) {
      return ShopStatus.closesSoon;
    }
    return ShopStatus.open;
  } else if (now.isBefore(openTime) &&
      openTime.difference(now).inMinutes <= soonThresholdMins) {
    return ShopStatus.opensSoon;
  }

  return ShopStatus.closed;
}

DateTime _parseTime(String timeStr, DateTime now, String dayName) {
  final cleanedTimeStr = timeStr
      .replaceAll(
        RegExp(r'[\u202F\u00A0\u2007\u2060]'),
        ' ',
      ) // all invisible spaces
      .replaceAll(RegExp(r'\s+'), ' ') // collapse multiple spaces
      .trim();

  print('Sanitized: "$cleanedTimeStr"');
  print('Code units: ${cleanedTimeStr.codeUnits}');

  final formatter = DateFormat.jm(); // "9:00 AM"
  final parsedTime = formatter.parse(cleanedTimeStr);

  final days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  final todayIndex = now.weekday % 7;
  final dayIndex = days.indexWhere(
    (d) => d.toLowerCase() == dayName.toLowerCase(),
  );
  final dayOffset = dayIndex - todayIndex;

  final adjustedDate = now.add(Duration(days: dayOffset));

  return DateTime(
    adjustedDate.year,
    adjustedDate.month,
    adjustedDate.day,
    parsedTime.hour,
    parsedTime.minute,
  );
}
