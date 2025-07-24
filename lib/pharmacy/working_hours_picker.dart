import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediora/models/working_hours_model.dart';

/*────────────────────────  MODEL  ────────────────────────*/

/* ----- helpers to switch between String  ⇄  TimeOfDay ----- */

/*────────────────────────  ENCODE / DECODE helpers  ────────────────────────*/

String workingHoursToString(List<WorkingHourModel> list) =>
    jsonEncode(list.map((w) => w.toJson()).toList());

List<WorkingHourModel> workingHoursFromString(String s) {
  final List arr = jsonDecode(s);
  const week = [
    'SUNDAY',
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
  ];
  final map = {
    for (var d in week) d: WorkingHourModel(day: d, isHoliday: true),
  };
  for (final e in arr.cast<Map<String, dynamic>>()) {
    final wh = WorkingHourModel.fromJson(e);
    map[wh.day] = wh;
  }
  return week.map((d) => map[d]!).toList();
}

/*────────────────────────  PICKER  ────────────────────────*/
/* 
class WeeklyHoursPicker extends StatefulWidget {
  const WeeklyHoursPicker({
    super.key,
    required this.initial, // List<WorkingHourModel>
    required this.onChanged, // returns List<WorkingHourModel>
  });
  final List<WorkingHourModel> initial;
  final ValueChanged<List<WorkingHourModel>> onChanged;

  @override
  State<WeeklyHoursPicker> createState() => _WeeklyHoursPickerState();
}

class _WeeklyHoursPickerState extends State<WeeklyHoursPicker> {
  late List<WorkingHourModel> _hours;

  @override
  void initState() {
    super.initState();
    _hours = List.of(widget.initial);
  }

  Future<void> _pick(int index, bool pickOpen) async {
    final wh = _hours[index];
    final loc = MaterialLocalizations.of(context);
    final init = pickOpen ? wh.openTOD : wh.closeTOD;

    final picked = await showTimePicker(
      context: context,
      initialTime: init ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _hours[index] = pickOpen
            ? wh.copyWithTOD(newOpen: picked, loc: loc)
            : wh.copyWithTOD(newClose: picked, loc: loc);
        widget.onChanged(List<WorkingHourModel>.from(_hours));
      });
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final loc = MaterialLocalizations.of(ctx);

    String disp(WorkingHourModel w) => w.isHoliday
        ? 'Holiday'
        : '${w.openTOD != null ? loc.formatTimeOfDay(w.openTOD!) : '--'}'
              ' - '
              '${w.closeTOD != null ? loc.formatTimeOfDay(w.closeTOD!) : '--'}';

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _hours.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (_, i) {
        final w = _hours[i];
        return ListTile(
          title: Text(
            w.day,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(disp(w)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.access_time_outlined),
                tooltip: 'Open',
                onPressed: () => _pick(i, true),
              ),
              IconButton(
                icon: const Icon(Icons.access_time_filled_outlined),
                tooltip: 'Close',
                onPressed: () => _pick(i, false),
              ),
            ],
          ),
        );
      },
    );
  }
}
 */

class WorkingHoursPicker extends StatefulWidget {
  const WorkingHoursPicker({
    super.key,
    required this.hours, // ⇦ always pass a list
    this.onChanged,
    this.onSaved,
  });

  final List<WorkingHourModel> hours;
  final ValueChanged<List<WorkingHourModel>>? onChanged; // fires on any edit
  final ValueChanged<List<WorkingHourModel>>? onSaved; // fires on Save

  @override
  State<WorkingHoursPicker> createState() => _WorkingHoursPickerState();
}

class _WorkingHoursPickerState extends State<WorkingHoursPicker> {
  late final List<WorkingHourModel> _hours;

  @override
  void initState() {
    super.initState();
    // Work on a copy so the parent list is updated only via callbacks
    _hours = widget.hours.map((e) => e.copyWith()).toList();
  }

  void _emit() => widget.onChanged?.call(_hours);

  /// Pick a time (open = true, close = false) for row [idx]
  Future<void> _pick(int idx, {required bool open}) async {
    final m = _hours[idx];
    // Use previous time if available, otherwise 09:00
    final initial =
        (open ? m.open : m.close)?.let((s) => DateFormat('hh:mm a').parse(s)) ??
        DateTime(0, 1, 1, 9);

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => MediaQuery(
        // force 12‑hr picker
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked == null) return;

    final label = DateFormat(
      'hh:mm a',
    ).format(DateTime(0, 1, 1, picked.hour, picked.minute));

    setState(() {
      m.isHoliday = false;
      if (open) {
        m.open = label;
      } else {
        m.close = label;
      }
    });
    _emit();
  }

  Widget _timeChip(int i, {required bool open, String? text}) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [
          open ? Colors.green.shade300 : Colors.orange.shade300,
          open ? Colors.green.shade400 : Colors.orange.shade400,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: (open ? Colors.green : Colors.orange).withOpacity(0.3),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _pick(i, open: open),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                open ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                text ?? (open ? 'Open' : 'Close'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _row(int i) {
    final m = _hours[i];
    final isHoliday = m.isHoliday;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isHoliday
              ? [Colors.grey.shade100, Colors.grey.shade200]
              : [Colors.white, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isHoliday ? Colors.grey.shade300 : Colors.blue.shade100,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Day indicator
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isHoliday
                      ? [Colors.grey.shade300, Colors.grey.shade400]
                      : [Colors.blue.shade300, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isHoliday ? Colors.grey : Colors.blue).withOpacity(
                      0.3,
                    ),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  m.day.substring(0, 3).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Day name and time info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          m.day,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isHoliday
                                ? Colors.grey.shade600
                                : Colors.grey.shade800,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          /*  color: Colors.white, */
                          /* boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ], */
                        ),
                        child: Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value:
                                !isHoliday, // ON = not holiday, OFF = holiday
                            onChanged: (v) {
                              setState(() {
                                m
                                  ..isHoliday =
                                      !v // if switch is ON (!v = false), isHoliday = false
                                  ..open = v ? m.open : null
                                  ..close = v ? m.close : null;
                              });
                              _emit();
                            },
                            activeColor: Colors.green.shade400,
                            activeTrackColor: Colors.green.shade200,
                            inactiveThumbColor: Colors.red.shade400,
                            inactiveTrackColor: Colors.red.shade200,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  if (isHoliday)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.beach_access,
                            size: 14,
                            color: Colors.red.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Holiday',
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        _timeChip(i, open: true, text: m.open),
                        const SizedBox(width: 12),
                        Container(
                          width: 20,
                          height: 2,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _timeChip(i, open: false, text: m.close),
                      ],
                    ),
                ],
              ),
            ),

            // Holiday toggle
          ],
        ),
      ),
    );
  }

  // void _save() => widget.onSaved?.call(_hours);

  @override
  Widget build(BuildContext context) => Container(
    /*  width: 400, */
    // height: 900,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      /*   gradient: LinearGradient(
        colors: [Colors.blue.shade50, Colors.indigo.shade50],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ), */
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        // Header
        // SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          /*  decoration: BoxDecoration(
            /*  gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.indigo.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ), */
            /*  borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ), */
          ), */
          child: Row(
            children: [
              Container(
                /*   padding: const EdgeInsets.all(8), */
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Colors.black54,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Working Hours',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Toggle: ON = Working Day, OFF = Holiday',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _hours.length,
            itemBuilder: (_, i) => _row(i),
          ),
        ),

        // Footer with toggle explanation
      ],
    ),
  );
}

extension<T> on T? {
  /// Handy null‑safe `let`
  R? let<R>(R Function(T) f) => this == null ? null : f(this as T);
}
