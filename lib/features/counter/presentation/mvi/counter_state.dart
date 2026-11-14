import '../../domain/entities/counter.dart';
import 'counter_intent.dart';

enum CounterStatus { initial, loading, updating, ready, failure }

/// Una instantánea inmutable de todo lo necesario para representar la pantalla.
final class CounterState {
  CounterState({
    this.counter = const Counter.zero(),
    this.status = CounterStatus.initial,
    this.initialized = false,
    this.revision = 0,
    this.previousValue = 0,
    this.lastIntent,
    this.errorMessage,
    List<CounterTransition> history = const [],
  }) : history = List.unmodifiable(history);

  final Counter counter;
  final CounterStatus status;
  final bool initialized;
  final int revision;
  final int previousValue;
  final CounterIntent? lastIntent;
  final String? errorMessage;
  final List<CounterTransition> history;

  bool get isBusy => switch (status) {
    CounterStatus.initial ||
    CounterStatus.loading ||
    CounterStatus.updating => true,
    CounterStatus.ready || CounterStatus.failure => false,
  };

  bool get canInteract => initialized && status == CounterStatus.ready;

  CounterState copyWith({
    Counter? counter,
    CounterStatus? status,
    bool? initialized,
    int? revision,
    int? previousValue,
    CounterIntent? lastIntent,
    String? errorMessage,
    List<CounterTransition>? history,
  }) => CounterState(
    counter: counter ?? this.counter,
    status: status ?? this.status,
    initialized: initialized ?? this.initialized,
    revision: revision ?? this.revision,
    previousValue: previousValue ?? this.previousValue,
    lastIntent: lastIntent ?? this.lastIntent,
    // Los errores pertenecen a una transición; se limpian en la siguiente.
    errorMessage: errorMessage,
    history: history ?? this.history,
  );
}

final class CounterTransition {
  const CounterTransition({
    required this.revision,
    required this.intent,
    required this.before,
    required this.after,
  });

  final int revision;
  final CounterIntent intent;
  final int before;
  final int after;
}
