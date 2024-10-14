import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:events_tracker/data/models/models.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import 'services.dart';

/// Сервис, который объединяет [CalendarActivitiesStorage] и [EventsStorage]
/// и строит логику на основе этих данных.
@singleton
class CalendarService {
  final CalendarActivitiesStorage calendarStorage;
  final EventsStorage eventsStorage;

  CalendarService({
    required this.calendarStorage,
    required this.eventsStorage,
  });

  /// См. [mappedEventsActivityStream] для документации
  final _mappedEventsActivitySubject = BehaviorSubject<Map<DateTime, CalendarDayStatistics>>();

  /// См. [mappedEventsStream]
  final _mappedEventsSubject = BehaviorSubject<List<EventModelWithStatistic>>();

  @PostConstruct()
  void init() {
    /// skip 1 чтобы избежать дублирования
    calendarStorage.calendarActivitiesStream.skip(1).listen(
          (acts) => _mapCalendarAndEvents(
            events: eventsStorage.eventsList,
            activities: acts,
          ),
        );
    eventsStorage.eventsStream.skip(1).listen(
          (events) => _mapCalendarAndEvents(
            events: events,
            activities: calendarStorage.calendarActivities,
          ),
        );

    _mapCalendarAndEvents(
      events: eventsStorage.eventsList,
      activities: calendarStorage.calendarActivities,
    );
  }

  /// Сопоставленные активности, где статистика для каждого дня содержит всю необходимую информацию.

  /// Лучше использовать этот метод в UI вместо
  /// [CalendarActivitiesStorage.calendarActivitiesStream], так как последний не
  /// проверяет удаление событий.
  /// TODO(alex-a4): заменить хранилище SP на SQL с отношениями
  Stream<Map<DateTime, CalendarDayStatistics>> get mappedEventsActivityStream =>
      _mappedEventsActivitySubject.stream;

  /// Получатель для [mappedEventsActivityStream]
  Map<DateTime, CalendarDayStatistics> get mappedEventsActivity =>
      _mappedEventsActivitySubject.value;

  /// Сопоставленные события, где каждая задача содержит весь прогресс за все дни с информацией.
  ///
  /// Лучше использовать этот метод в UI вместо [EventsStorage.eventsStream].
  Stream<List<EventModelWithStatistic>> get mappedEventsStream => _mappedEventsSubject.stream;

  /// Геттер для [mappedEventsActivityStream]
  List<EventModelWithStatistic> get mappedEvents => _mappedEventsSubject.value;

  /// Прокси для получения текущих доступных событий
  Stream<List<EventModel>> get eventsStream => eventsStorage.eventsStream;

  void _mapCalendarAndEvents({
    required List<EventModel> events,
    required Map<DateTime, CalendarDayActivities> activities,
  }) {
    final dayStatistics = <DateTime, CalendarDayStatistics>{};
    final mappedEvents = Map.fromEntries(events.map((e) => MapEntry(e.id, e)));

    // ключ - taskId, значение - general completed count
    final tasksStatistics = <String, int>{};
    // Позволяет упростить поиск объектов после заполнения [tasksStatistics], чтобы избежать долгих
    final tasksObjects = <String, List<CalendarDayTaskStatistics>>{};
    // ключ1 - task id, ключ2 - date of activity, значение - activity of task
    final tasksMappedByDay = <String, Map<DateTime, CalendarDayTaskStatistics>>{};

    activities.forEach((date, activities) {
      final mappedTasks = <String, List<CalendarDayTaskStatistics>>{};
      final allTasks = <CalendarDayTaskStatistics>[];

      for (final activity in activities.tasks) {
        final event = mappedEvents[activity.eventId];
        if (event == null) continue;

        final task = event.tasks.firstWhere((t) => t.id == activity.taskId);

        if (tasksStatistics[task.id] == null) {
          tasksStatistics[task.id] = activity.completedCount;
        } else {
          tasksStatistics[task.id] = tasksStatistics[task.id]! + activity.completedCount;
        }

        final taskStat = CalendarDayTaskStatistics(
          eventColor: event.color,
          eventId: event.id,
          eventTitle: event.eventTitle,
          completedInDay: activity.completedCount,
          plan: task.plan,
          taskId: task.id,
          taskName: task.taskName,
        );

        if (tasksObjects[task.id] == null) {
          tasksObjects[task.id] = [taskStat];
          tasksMappedByDay[task.id] = {date: taskStat};
        } else {
          tasksObjects[task.id]!.add(taskStat);
          tasksMappedByDay[task.id]![date] = taskStat;
        }

        if (mappedTasks[event.id] == null) {
          mappedTasks[event.id] = [taskStat];
        } else {
          mappedTasks[event.id]!.add(taskStat);
        }

        allTasks.add(taskStat);
      }

      dayStatistics[date] = CalendarDayStatistics(
        date: date,
        tasksByEvent: mappedTasks,
        allTasks: allTasks,
      );
    });

    // устанавливаем общую подсчитанную статистику
    tasksStatistics.forEach(
      // ignore: avoid_function_literals_in_foreach_calls
      (key, value) => tasksObjects[key]!.forEach((task) => task.completedGeneral = value),
    );

    _mappedEventsActivitySubject.add(dayStatistics);

    _mappedEventsSubject.add(events.map((e) {
      return EventModelWithStatistic(
        id: e.id,
        eventTitle: e.eventTitle,
        tasks: e.tasks.map((t) {
          return EventTaskWithStatistic(
            id: t.id,
            taskName: t.taskName,
            plan: t.plan,
            completedGeneral: tasksStatistics[t.id] ?? 0,
            completionsByDays: tasksMappedByDay[t.id] ?? {},
          );
        }).toList(),
        color: e.color,
      );
    }).toList());
  }

  /// Прокси метод для удаления события по его id
  Future<void> removeEvent(String id) => eventsStorage.removeEvent(id);

  /// Получить событие по id или null, если такого события нет
  EventModel? getEventById(String eventId) =>
      eventsStorage.eventsList.firstWhereOrNull((e) => e.id == eventId);

  /// Прокси метод для увеличения активности на указанный день для конкретного события и задачи
  Future<void> increaseDayActivity({
    required String eventId,
    required String taskId,
    required DateTime date,
    int increaseCount = 1,
  }) =>
      calendarStorage.increaseDayActivity(
        eventId: eventId,
        taskId: taskId,
        date: date,
        increaseCount: increaseCount,
      );

  /// Создать новое событие
  Future<void> createEvent({
    required String eventName,
    required Color color,
    required List<EventTask> tasks,
  }) async {
    await eventsStorage.addEvent(
      EventModel.create(eventTitle: eventName, tasks: tasks, color: color),
    );
  }

  /// Обновить старое событие в хранилище новыми данными
  Future<void> updateEvent({
    required String eventId,
    required String eventName,
    required Color color,
    required List<EventTask> tasks,
  }) async {
    await eventsStorage.updateEvent(
      EventModel(
        id: eventId,
        eventTitle: eventName,
        tasks: tasks,
        color: color,
      ),
    );
  }
}
