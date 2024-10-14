import 'dart:convert';

import 'package:events_tracker/app/services/services.dart';
import 'package:events_tracker/data/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'calendarActivities';

void main() {
  late SharedWrapper wrapper;
  late CalendarActivitiesStorage storage;

  const event1Id = 'event1';
  final (task1_1Id, task1_2Id) = ('task1_1', 'task1_2');

  const event2Id = 'event2';
  final (task2_1Id, task2_2Id) = ('task2_1', 'task2_2');

  // task 1_1
  final day1ActivityEvent1Task1_1 = DayActivity(
    eventId: event1Id,
    taskId: task1_1Id,
    completedCount: 5,
  );
  final day2ActivityEvent1Task1_1 = DayActivity(
    eventId: event1Id,
    taskId: task1_1Id,
    completedCount: 2,
  );

  // task 1_2
  final day1ActivityEvent1Task1_2 = DayActivity(
    eventId: event1Id,
    taskId: task1_2Id,
    completedCount: 1,
  );

  // task 2_1
  final day1ActivityEvent2Task2_1 = DayActivity(
    eventId: event2Id,
    taskId: task2_1Id,
    completedCount: 100,
  );
  final day2ActivityEvent2Task2_1 = DayActivity(
    eventId: event2Id,
    taskId: task2_1Id,
    completedCount: 5,
  );

  // task 2_2
  final day2ActivityEvent2Task2_2 = DayActivity(
    eventId: event2Id,
    taskId: task2_2Id,
    completedCount: 2,
  );

  final day1 = CalendarDayActivities(
    date: DateTime(2024, 1, 3),
    tasks: [
      day1ActivityEvent1Task1_1,
      day1ActivityEvent1Task1_2,
      day1ActivityEvent2Task2_1,
    ],
  );
  final day2 = CalendarDayActivities(
    date: DateTime(2024, 1, 8),
    tasks: [
      day2ActivityEvent1Task1_1,
      day2ActivityEvent2Task2_1,
      day2ActivityEvent2Task2_2,
    ],
  );

  setUp(() {
    SharedPreferences.resetStatic();

    wrapper = SharedWrapper();
    storage = CalendarActivitiesStorage(shared: wrapper);
  });

  Future<void> initStorage() async {
    await wrapper.init();
    storage.init();
  }

  group('CalendarActivitiesStorage.init', () {
    test('init without data', () async {
      SharedPreferences.setMockInitialValues({});
      await initStorage();

      expect(storage.calendarActivities.isEmpty, isTrue);
    });

    test('init with data', () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode(
          [day1.toJson(), day2.toJson()],
        ),
      });
      await initStorage();

      expect(storage.calendarActivities.length, 2);
      expect(storage.calendarActivities[day1.date]!.tasks.length, 3);
      expect(storage.calendarActivities[day2.date]!.tasks.length, 3);

      expect(storage.calendarActivities[day1.date]!.getEventActivity(event1Id).length, 2);
      expect(storage.calendarActivities[day1.date]!.getEventActivity(event2Id).length, 1);

      expect(storage.calendarActivities[day2.date]!.getEventActivity(event1Id).length, 1);
      expect(storage.calendarActivities[day2.date]!.getEventActivity(event2Id).length, 2);
    });
  });

  group('CalendarActivitiesStorage.increaseDayActivity', () {
    test('increaseDayActivity when no data before with increaseCount', () async {
      SharedPreferences.setMockInitialValues({});
      await initStorage();
      await storage.increaseDayActivity(
        date: day1.date,
        eventId: event1Id,
        taskId: task1_1Id,
        increaseCount: day1ActivityEvent1Task1_1.completedCount,
      );
      final dayActivity = storage.calendarActivities[day1.date]!;
      final eventActivity = dayActivity.getEventActivity(event1Id);

      expect(dayActivity.tasks.length, 1);
      expect(eventActivity.length, 1);
      expect(
        eventActivity[task1_1Id]!.completedCount,
        day1ActivityEvent1Task1_1.completedCount,
      );
    });

    test('increaseDayActivity when no data before without increaseCount', () async {
      SharedPreferences.setMockInitialValues({});
      await initStorage();
      await storage.increaseDayActivity(
        date: day1.date,
        eventId: event1Id,
        taskId: task1_1Id,
      );
      final dayActivity = storage.calendarActivities[day1.date]!;
      final eventActivity = dayActivity.getEventActivity(event1Id);

      expect(dayActivity.tasks.length, 1);
      expect(eventActivity.length, 1);
      expect(eventActivity[task1_1Id]!.completedCount, 1);
    });

    test('increaseDayActivity when was data before', () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode([day1.toJson()]),
      });
      await initStorage();
      await storage.increaseDayActivity(
        date: day1.date,
        eventId: event1Id,
        taskId: task1_1Id,
        increaseCount: 3,
      );
      final dayActivity = storage.calendarActivities[day1.date]!;
      final eventActivity = dayActivity.getEventActivity(event1Id);

      expect(dayActivity.tasks.length, 3);
      expect(eventActivity.length, 2);
      expect(dayActivity.getEventActivity(event2Id).length, 1);

      expect(
        eventActivity[task1_1Id]!.completedCount,
        day1ActivityEvent1Task1_1.completedCount + 3,
      );
      // didnt change
      expect(
        eventActivity[task1_2Id]!.completedCount,
        day1ActivityEvent1Task1_2.completedCount,
      );
      expect(
        dayActivity.getEventActivity(event2Id)[task2_1Id]!.completedCount,
        day1ActivityEvent2Task2_1.completedCount,
      );
    });

    test('increaseDayActivity when was data for event but for another task', () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode([day1.toJson()]),
      });
      await initStorage();
      await storage.increaseDayActivity(
        date: day1.date,
        eventId: event2Id,
        taskId: task2_2Id,
        increaseCount: 5,
      );
      final dayActivity = storage.calendarActivities[day1.date]!;
      final event1Activity = dayActivity.getEventActivity(event1Id);
      final event2Activity = dayActivity.getEventActivity(event2Id);

      expect(dayActivity.tasks.length, 4);
      expect(event1Activity.length, 2);
      expect(event2Activity.length, 2);

      // new
      expect(event2Activity[task2_2Id]!.completedCount, 5);

      // didnt change
      expect(
        event1Activity[task1_1Id]!.completedCount,
        day1ActivityEvent1Task1_1.completedCount,
      );
      expect(
        event1Activity[task1_2Id]!.completedCount,
        day1ActivityEvent1Task1_2.completedCount,
      );
      expect(
        event2Activity[task2_1Id]!.completedCount,
        day1ActivityEvent2Task2_1.completedCount,
      );
    });
  });

  group('CalendarActivitiesStorage.decreaseDayActivity', () {
    test('decreaseDayActivity when no data before', () async {
      SharedPreferences.setMockInitialValues({});
      await initStorage();

      await storage.decreaseDayActivity(
        date: day1.date,
        eventId: event1Id,
        taskId: task1_1Id,
      );

      expect(storage.calendarActivities.isEmpty, isTrue);
    });

    test('decreaseDayActivity when no task for found event', () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode([day1.toJson()]),
      });
      await initStorage();

      await storage.decreaseDayActivity(
        date: day1.date,
        eventId: event2Id,
        taskId: task2_2Id,
      );

      final dayActivity = storage.calendarActivities[day1.date]!;
      final event1Activity = dayActivity.getEventActivity(event1Id);
      final event2Activity = dayActivity.getEventActivity(event2Id);

      expect(storage.calendarActivities.length, 1);
      expect(dayActivity.tasks.length, 3);
      expect(event1Activity.length, 2);
      expect(event2Activity.length, 1);

      // didnt change
      expect(
        event1Activity[task1_1Id]!.completedCount,
        day1ActivityEvent1Task1_1.completedCount,
      );
      expect(
        event1Activity[task1_2Id]!.completedCount,
        day1ActivityEvent1Task1_2.completedCount,
      );
      expect(
        event2Activity[task2_1Id]!.completedCount,
        day1ActivityEvent2Task2_1.completedCount,
      );
    });

    test('decreaseDayActivity common situation just decrease count without decreaseCount',
        () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode([day1.toJson()]),
      });
      await initStorage();

      await storage.decreaseDayActivity(
        date: day1.date,
        eventId: event2Id,
        taskId: task2_1Id,
      );

      final dayActivity = storage.calendarActivities[day1.date]!;
      final event1Activity = dayActivity.getEventActivity(event1Id);
      final event2Activity = dayActivity.getEventActivity(event2Id);

      expect(storage.calendarActivities.length, 1);
      expect(dayActivity.tasks.length, 3);
      expect(event1Activity.length, 2);
      expect(event2Activity.length, 1);

      // didnt change
      expect(
        event1Activity[task1_1Id]!.completedCount,
        day1ActivityEvent1Task1_1.completedCount,
      );
      expect(
        event1Activity[task1_2Id]!.completedCount,
        day1ActivityEvent1Task1_2.completedCount,
      );
      expect(
        event2Activity[task2_1Id]!.completedCount,
        day1ActivityEvent2Task2_1.completedCount - 1,
      );
    });

    test('decreaseDayActivity common situation just decrease count with decreaseCount', () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode([day1.toJson()]),
      });
      await initStorage();

      await storage.decreaseDayActivity(
        date: day1.date,
        eventId: event2Id,
        taskId: task2_1Id,
        decreaseCount: 30,
      );

      final dayActivity = storage.calendarActivities[day1.date]!;
      final event1Activity = dayActivity.getEventActivity(event1Id);
      final event2Activity = dayActivity.getEventActivity(event2Id);

      expect(storage.calendarActivities.length, 1);
      expect(dayActivity.tasks.length, 3);
      expect(event1Activity.length, 2);
      expect(event2Activity.length, 1);

      // didnt change
      expect(
        event1Activity[task1_1Id]!.completedCount,
        day1ActivityEvent1Task1_1.completedCount,
      );
      expect(
        event1Activity[task1_2Id]!.completedCount,
        day1ActivityEvent1Task1_2.completedCount,
      );
      expect(
        event2Activity[task2_1Id]!.completedCount,
        day1ActivityEvent2Task2_1.completedCount - 30,
      );
    });

    test('decreaseDayActivity do not affect other day', () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode([day1.toJson(), day2.toJson()]),
      });
      await initStorage();

      await storage.decreaseDayActivity(
        date: day1.date,
        eventId: event2Id,
        taskId: task2_1Id,
        decreaseCount: 30,
      );

      final day1Activity = storage.calendarActivities[day1.date]!;
      final day1event1Activity = day1Activity.getEventActivity(event1Id);
      final day1event2Activity = day1Activity.getEventActivity(event2Id);

      final day2Activity = storage.calendarActivities[day2.date]!;
      final day2event1Activity = day2Activity.getEventActivity(event1Id);
      final day2event2Activity = day2Activity.getEventActivity(event2Id);

      expect(storage.calendarActivities.length, 2);

      expect(day1Activity.tasks.length, 3);
      expect(day1event1Activity.length, 2);
      expect(day1event2Activity.length, 1);

      expect(day2Activity.tasks.length, 3);
      expect(day2event1Activity.length, 1);
      expect(day2event2Activity.length, 2);

      // changed
      expect(
        day1event2Activity[task2_1Id]!.completedCount,
        day1ActivityEvent2Task2_1.completedCount - 30,
      );

      // didnt change
      expect(
        day1event1Activity[task1_1Id]!.completedCount,
        day1ActivityEvent1Task1_1.completedCount,
      );
      expect(
        day1event1Activity[task1_2Id]!.completedCount,
        day1ActivityEvent1Task1_2.completedCount,
      );

      expect(
        day2event1Activity[task1_1Id]!.completedCount,
        day2ActivityEvent1Task1_1.completedCount,
      );
      expect(
        day2event2Activity[task2_1Id]!.completedCount,
        day2ActivityEvent2Task2_1.completedCount,
      );
      expect(
        day2event2Activity[task2_2Id]!.completedCount,
        day2ActivityEvent2Task2_2.completedCount,
      );
    });

    test('decreaseDayActivity remove task but event still there', () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode([day1.toJson()]),
      });
      await initStorage();

      await storage.decreaseDayActivity(
        date: day1.date,
        eventId: event1Id,
        taskId: task1_1Id,
        decreaseCount: 5,
      );

      final dayActivity = storage.calendarActivities[day1.date]!;
      final event1Activity = dayActivity.getEventActivity(event1Id);
      final event2Activity = dayActivity.getEventActivity(event2Id);

      expect(storage.calendarActivities.length, 1);
      expect(dayActivity.tasks.length, 2);
      expect(event1Activity.length, 1);
      expect(event2Activity.length, 1);

      // removed
      expect(event1Activity[task1_1Id], isNull);

      // didnt change
      expect(
        event1Activity[task1_2Id]!.completedCount,
        day1ActivityEvent1Task1_2.completedCount,
      );
      expect(
        event2Activity[task2_1Id]!.completedCount,
        day1ActivityEvent2Task2_1.completedCount,
      );
    });

    test('decreaseDayActivity remove event completely', () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode([day1.toJson()]),
      });
      await initStorage();

      await storage.decreaseDayActivity(
        date: day1.date,
        eventId: event2Id,
        taskId: task2_1Id,
        decreaseCount: 100,
      );

      final dayActivity = storage.calendarActivities[day1.date]!;
      final event1Activity = dayActivity.getEventActivity(event1Id);
      final event2Activity = dayActivity.getEventActivity(event2Id);

      expect(storage.calendarActivities.length, 1);
      expect(dayActivity.tasks.length, 2);
      expect(event1Activity.length, 2);
      expect(event2Activity.length, 0);

      // removed
      expect(event2Activity[task2_1Id], isNull);

      // didnt change
      expect(
        event1Activity[task1_1Id]!.completedCount,
        day1ActivityEvent1Task1_1.completedCount,
      );
      expect(
        event1Activity[task1_2Id]!.completedCount,
        day1ActivityEvent1Task1_2.completedCount,
      );
    });
  });
}
