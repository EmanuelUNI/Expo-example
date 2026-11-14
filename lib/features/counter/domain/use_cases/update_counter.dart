import '../entities/counter.dart';
import '../repositories/counter_repository.dart';

final class UpdateCounter {
  const UpdateCounter(this._repository);

  final CounterRepository _repository;

  /// Valida antes de guardar. Publicar el resultado es tarea de presentación.
  Future<Counter> call(Counter current, CounterOperation operation) async {
    final next = Counter(switch (operation) {
      CounterOperation.increment => current.value + 1,
      CounterOperation.decrement => current.value - 1,
      CounterOperation.reset => 0,
    });
    await _repository.save(next);
    return next;
  }
}
