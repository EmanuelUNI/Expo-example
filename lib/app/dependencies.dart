import '../features/counter/data/repositories/in_memory_counter_repository.dart';
import '../features/counter/domain/use_cases/get_counter.dart';
import '../features/counter/domain/use_cases/update_counter.dart';
import '../features/counter/presentation/mvi/counter_store.dart';

/// Raíz de composición: el único lugar que conoce implementaciones concretas.
CounterStore createCounterStore() {
  final repository = InMemoryCounterRepository();
  return CounterStore(
    getCounter: GetCounter(repository),
    updateCounter: UpdateCounter(repository),
  );
}
