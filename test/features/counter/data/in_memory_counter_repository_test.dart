import 'package:flutter_test/flutter_test.dart';
import 'package:mvi_counter/features/counter/data/repositories/in_memory_counter_repository.dart';
import 'package:mvi_counter/features/counter/domain/entities/counter.dart';

void main() {
  test('conserva el valor solo en la instancia de la sesión', () async {
    final session = InMemoryCounterRepository(latency: Duration.zero);
    expect(await session.read(), const Counter.zero());
    await session.save(Counter(4));
    expect(await session.read(), Counter(4));
    final newSession = InMemoryCounterRepository(latency: Duration.zero);
    expect(await newSession.read(), const Counter.zero());
  });
}
