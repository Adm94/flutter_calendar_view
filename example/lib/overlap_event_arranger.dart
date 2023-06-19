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
    var zIndex = 0;
    for (final event in events) {
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

      final startTime = event.startTime!;
      final endTime = event.endTime!;

      final eventStart = startTime.getTotalMinutes;
      final eventEnd = endTime.getTotalMinutes == 0
          ? Constants.minutesADay
          : endTime.getTotalMinutes;

      final arrangeEventLen = arrangedEvents.length;

      //check if currentevent is overlapping with the previous one, if yes, then increase the zIndex
      if(arrangeEventLen > 0){
        final arrangedEventStart =
        arrangedEvents[arrangeEventLen-1].startDuration.getTotalMinutes;
        final arrangedEventEnd =
        arrangedEvents[arrangeEventLen-1].endDuration.getTotalMinutes == 0
            ? Constants.minutesADay
            : arrangedEvents[arrangeEventLen-1].endDuration.getTotalMinutes;
        if(arrangedEventStart < eventStart && arrangedEventEnd > eventEnd){
          zIndex++;
        }
      }


      final top = eventStart * heightPerMinute;
      final bottom = eventEnd * heightPerMinute == height
          ? 0.0
          : height - eventEnd * heightPerMinute;

      final newEvent = OrganizedCalendarEventData<T>(
        top: top,
        bottom: bottom,
        left: 0,
        right: 0,
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

