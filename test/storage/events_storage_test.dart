import 'dart:convert';

import 'package:events_tracker/app/services/services.dart';
import 'package:events_tracker/data/data.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'events_key';

void main() {
  late SharedWrapper wrapper;
  late EventsStorage storage;

  final task1_1 = EventTask.create(taskName: 'Push-ups', plan: 10000);
  final task1_2 = EventTask.create(taskName: 'Pull-ups', plan: 3000);

  final event1 = EventModel.create(
    eventTitle: 'Trainings',
    tasks: [task1_1, task1_2],
    color: Colors.blue,
  );

  final task2_1 = EventTask.create(taskName: 'Read books', plan: 30);
  final task2_2 = EventTask.create(taskName: 'Write pictures', plan: 10);

  final event2 = EventModel.create(
    eventTitle: 'Creative development',
    tasks: [task2_1, task2_2],
    color: Colors.red,
  );

  setUp(() {
    SharedPreferences.resetStatic();

    wrapper = SharedWrapper();
    storage = EventsStorage(shared: wrapper);
  });

  Future<void> initStorage() async {
    await wrapper.init();
    storage.init();
  }

  group('EventsStorage.init', () {
    test('init without data', () async {
      SharedPreferences.setMockInitialValues({});
      await initStorage();

      expect(storage.eventsList.isEmpty, isTrue);
    });

    test('init with data', () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode(
          [event1.toJson(), event2.toJson()],
        ),
      });
      await initStorage();

      expect(storage.eventsList.length, 2);
    });
  });

  group('EventsStorage.addEvent', () {
    test('addEvent when no data before', () async {
      SharedPreferences.setMockInitialValues({});
      await initStorage();
      await storage.addEvent(event1);

      expect(storage.eventsList.length, 1);
      expect(wrapper.getString(_storageKey), jsonEncode([event1]));
    });

    test('addEvent when was data before', () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode([event1.toJson()]),
      });
      await initStorage();

      await storage.addEvent(event2);

      expect(storage.eventsList.length, 2);
      expect(wrapper.getString(_storageKey), jsonEncode([event1, event2]));
    });
  });

  group('EventsStorage.removeEvent', () {
    test('removeEvent when no data before', () async {
      SharedPreferences.setMockInitialValues({});
      await initStorage();
      await storage.removeEvent(event1.id);

      expect(storage.eventsList.length, 0);
      expect(wrapper.getString(_storageKey), null);
    });

    test('removeEvent when removing single value', () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode([event1.toJson()]),
      });
      await initStorage();

      await storage.removeEvent(event1.id);

      expect(storage.eventsList.length, 0);
      expect(wrapper.getString(_storageKey), null);
    });

    test('removeEvent when there is data after removing', () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode([event1.toJson(), event2.toJson()]),
      });
      await initStorage();

      await storage.removeEvent(event1.id);

      expect(storage.eventsList.length, 1);
      expect(wrapper.getString(_storageKey), jsonEncode([event2]));
    });
  });

  group('EventsStorage.updateEvent', () {
    test('updateEvent when no data before', () async {
      SharedPreferences.setMockInitialValues({});
      await initStorage();
      await storage.updateEvent(event1);

      expect(storage.eventsList.length, 0);
      expect(wrapper.getString(_storageKey), null);
    });

    test('updateEvent when updating single value', () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode([event1.toJson()]),
      });
      await initStorage();
      final updatedEvent1 = event1.copyWith(tasks: [task1_1]);

      await storage.updateEvent(updatedEvent1);

      expect(storage.eventsList.length, 1);
      expect(storage.eventsList.first.tasks.length, 1);
      expect(storage.eventsList.first.tasks.first.id, task1_1.id);
      expect(wrapper.getString(_storageKey), jsonEncode([updatedEvent1]));
    });

    test('updateEvent when there is other values', () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: jsonEncode([event1.toJson(), event2.toJson()]),
      });
      await initStorage();
      final updatedEvent1 = event1.copyWith(tasks: [task1_1]);

      await storage.updateEvent(updatedEvent1);

      expect(storage.eventsList.length, 2);

      expect(storage.eventsList.first.tasks.length, 1);
      expect(storage.eventsList.first.tasks.first.id, task1_1.id);

      expect(storage.eventsList.last.tasks.length, 2);
      expect(
        wrapper.getString(_storageKey),
        jsonEncode([updatedEvent1, event2]),
      );
    });
  });
}
