import 'package:mvi_counter/features/counter/domain/entities/counter.dart';
import 'package:mvi_counter/features/counter/domain/repositories/counter_repository.dart';

class FakeCounterRepository implements CounterRepository {
  Counter saved = const Counter.zero();
  int reads = 0;
  int writes = 0;
  bool failNextRead = false;
  bool failNextSave = false;
  Duration latency = Duration.zero;

  @override
  Future<Counter> read() async {
    reads++;
    await Future<void>.delayed(latency);
    if (failNextRead) {
      failNextRead = false;
      throw Exception('Fallo de lectura controlado');
    }
    return saved;
  }

  @override
  Future<void> save(Counter counter) async {
    writes++;
    await Future<void>.delayed(latency);
    if (failNextSave) {
      failNextSave = false;
      throw Exception('Fallo de escritura controlado');
    }
    saved = counter;
  }
}
