import 'package:flutter/foundation.dart';

import '../../domain/entities/counter.dart';
import '../../domain/use_cases/get_counter.dart';
import '../../domain/use_cases/update_counter.dart';
import 'counter_intent.dart';
import 'counter_state.dart';

/// Única fuente de estado. Vista → intención → caso de uso → estado → vista.
final class CounterStore extends ChangeNotifier {
  CounterStore({
    required GetCounter getCounter,
    required UpdateCounter updateCounter,
  }) : _getCounter = getCounter,
       _updateCounter = updateCounter;

  final GetCounter _getCounter;
  final UpdateCounter _updateCounter;
  CounterState _state = CounterState();
  CounterState get state => _state;

  Future<void> _pending = Future<void>.value();
  CounterIntent? _failedIntent;
  bool _disposed = false;

  /// La cola evita que dos lecturas del mismo valor pierdan incrementos.
  Future<void> dispatch(CounterIntent intent) {
    if (_disposed) return Future<void>.value();
    _pending = _pending.then((_) => _process(intent));
    return _pending;
  }

  Future<void> _process(CounterIntent requested) async {
    if (_disposed) return;
    final intent = requested is RetryCounter ? _failedIntent : requested;
    if (intent == null) return;
    if (intent is! LoadCounter && !_state.initialized) return;
    // Después de un fallo, se resuelve esa intención antes de aceptar más.
    if (_state.status == CounterStatus.failure && requested is! RetryCounter) {
      return;
    }

    final previous = _state.counter;
    _emit(
      _state.copyWith(
        status: intent is LoadCounter
            ? CounterStatus.loading
            : CounterStatus.updating,
        lastIntent: intent,
        previousValue: previous.value,
      ),
    );

    try {
      final operation = switch (intent) {
        IncrementCounter() => CounterOperation.increment,
        DecrementCounter() => CounterOperation.decrement,
        ResetCounter() => CounterOperation.reset,
        LoadCounter() || RetryCounter() => null,
      };
      final next = operation == null
          ? await _getCounter()
          : await _updateCounter(previous, operation);
      if (_disposed) return;

      final revision = _state.revision + (operation == null ? 0 : 1);
      final history = operation == null
          ? _state.history
          : [
              CounterTransition(
                revision: revision,
                intent: intent,
                before: previous.value,
                after: next.value,
              ),
              ..._state.history,
            ].take(8).toList();
      _failedIntent = null;
      _emit(
        _state.copyWith(
          counter: next,
          status: CounterStatus.ready,
          initialized: true,
          revision: revision,
          history: history,
        ),
      );
    } on CounterBoundaryException {
      // La validación no modifica el último estado válido ni se reintenta.
      _failedIntent = null;
      _emit(
        _state.copyWith(
          status: CounterStatus.ready,
          errorMessage: 'El contador debe estar entre 0 y 99.',
        ),
      );
    } on Exception {
      _failedIntent = intent;
      _emit(
        _state.copyWith(
          status: CounterStatus.failure,
          errorMessage: intent is LoadCounter
              ? 'No pudimos cargar el contador. Inténtalo de nuevo.'
              : 'No pudimos guardar el cambio. Tu valor anterior está a salvo.',
        ),
      );
    }
  }

  void _emit(CounterState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
