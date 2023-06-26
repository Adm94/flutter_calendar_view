import 'package:calendar_view/calendar_view.dart';
import 'package:calendar_view/src/constants.dart';
import 'package:flutter/foundation.dart';

class OverlapEventArranger<T extends Object?> extends EventArranger<T> {
  /// This class will provide method that will arrange
  /// all events so that they overlap on top of each other.
  const OverlapEventArranger();

  @override
  List<OrganizedCalendarEventData<T>> arrange({
    required List<CalendarEventData<T>> events,
    required double height,
    required double width,
    required double heightPerMinute,
  }) {
    final arrangedEvents = <OrganizedCalendarEventData<T>>[];
    final checkedEvents = <CalendarEventData<T>>[];
    var zIndex = 0;
    for (final event in events.reversed) {
      if (event.startTime == null ||
          event.endTime == null ||
          event.endTime!.getTotalMinutes <= event.startTime!.getTotalMinutes) {
        if (!(event.endTime!.getTotalMinutes == 0 &&
            event.startTime!.getTotalMinutes > 0)) {
          assert(() {
            try {
              debugPrint(
                  "Failed to add event because of one of the given reasons: "
                      "\n1. Start time or end time might be null"
                      "\n2. endTime occurs before or at the same time as startTime."
                      "\nEvent data: \n$event\n");
            } catch (e) {} // Suppress exceptions.

            return true;
          }(), "Can not add event in the list.");
          continue;
        }
      }
      checkedEvents.add(event);
    }

    checkedEvents.sort((a, b) => a.startTime!.compareTo(b.startTime!));

    for (final event in checkedEvents) {
      final startTime = event.startTime!;
      final endTime = event.endTime!;

      final eventStart = startTime.getTotalMinutes;
      final eventEnd = endTime.getTotalMinutes == 0
          ? Constants.minutesADay
          : endTime.getTotalMinutes;

      final arrangeEventLen = arrangedEvents.length;

      if (arrangeEventLen > 0 &&
          arrangedEvents[arrangeEventLen - 1].startDuration
              .isBefore(event.endTime!)) {
        zIndex++;
      } else {
        zIndex = 0;
      }

      final sameStartEvents = events.where((e) =>
          e.startTime != null &&
          e.startTime!.getTotalMinutes == event.startTime!.getTotalMinutes);

      final sameStartEventIndex = sameStartEvents
          .toList()
          .indexWhere((e) => e.title.toString() == event.title.toString());

      var left = 0.0;
      if (sameStartEvents.length > 1 && sameStartEventIndex > 0) {
        left = width / sameStartEvents.length * sameStartEventIndex;
      }

      var right = 0.0;
      if (sameStartEvents.isNotEmpty) {
        right = width / sameStartEvents.length *
            (sameStartEvents.length - sameStartEventIndex - 1);
      }

      final top = eventStart * heightPerMinute;
      final bottom = eventEnd * heightPerMinute == height
          ? 0.0
          : height - eventEnd * heightPerMinute;

      final newEvent = OrganizedCalendarEventData<T>(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        startDuration: startTime.copyFromMinutes(eventStart),
        endDuration: endTime.copyFromMinutes(eventEnd),
        events: [event],
        zIndex: zIndex,
      );

      arrangedEvents.add(newEvent);

    }

    return arrangedEvents;
  }

}

