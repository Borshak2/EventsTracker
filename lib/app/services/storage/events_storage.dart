import 'dart:convert';

import 'package:events_tracker/app/services/storage/storage.dart';
import 'package:events_tracker/data/data.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/subjects.dart';

const _eventsStorageKey = 'events_key';

/// Хранилище, которое сохраняет информацию о событиях, созданных пользователем
@singleton
class EventsStorage {
  final SharedWrapper shared;

  EventsStorage({required this.shared});

  @PostConstruct()
  void init() {
    final events = shared.getString(_eventsStorageKey);

    if (events != null) {
      final jsonList = (jsonDecode(events) as List<dynamic>).cast<Map<String, dynamic>>();

      _eventsListSubject.add(jsonList.map((e) => EventModel.fromJson(e)).toList());
    } else {
      _eventsListSubject.add([]);
    }
  }

  final _eventsListSubject = BehaviorSubject<List<EventModel>>();

  /// Получить поток для отслеживания текущих доступных событий

  Stream<List<EventModel>> get eventsStream => _eventsListSubject;

  /// Получить текущие доступные события
  List<EventModel> get eventsList => _eventsListSubject.value;

  /// Добавить новое событие в хранилище и обновить поток
  Future<void> addEvent(EventModel event) async {
    final events = List<EventModel>.from(eventsList);
    events.add(event);
    await saveEvents(events);
  }

  /// Удалить событие из списка.
  /// Если после удаления не осталось событий, очистить хранилище по ключу.
  Future<void> removeEvent(String id) async {
    final events = List<EventModel>.from(eventsList);
    events.removeWhere((e) => e.id == id);

    if (events.isEmpty) {
      await shared.remove(_eventsStorageKey);
      _eventsListSubject.add([]);
    } else {
      await saveEvents(events);
    }
  }

  /// Обновить событие по его идентификатору id
  Future<void> updateEvent(EventModel event) async {
    final events = List<EventModel>.from(eventsList);
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      await saveEvents(events);
    }
  }

  /// Сохранить события в хранилище и обновить данные в subject
  Future<void> saveEvents(List<EventModel> events) async {
    await shared.setString(
      _eventsStorageKey,
      jsonEncode(events.map((e) => e.toJson()).toList()),
    );
    _eventsListSubject.add(events);
  }
}
