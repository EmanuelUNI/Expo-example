import '../../domain/entities/counter.dart';
import '../../domain/repositories/counter_repository.dart';

/// Almacenamiento de sesión. Se sustituye sin cambiar dominio o presentación.
final class InMemoryCounterRepository implements CounterRepository {
  InMemoryCounterRepository({this.latency = const Duration(milliseconds: 250)});

  final Duration latency;
  Counter _counter = const Counter.zero();

  @override
  Future<Counter> read() async {
    await Future<void>.delayed(latency);
    return _counter;
  }

  @override
  Future<void> save(Counter counter) async {
    await Future<void>.delayed(latency);
    _counter = counter;
  }
}
