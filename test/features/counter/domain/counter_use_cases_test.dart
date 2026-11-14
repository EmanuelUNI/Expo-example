import 'package:flutter_test/flutter_test.dart';
import 'package:mvi_counter/features/counter/domain/entities/counter.dart';
import 'package:mvi_counter/features/counter/domain/use_cases/get_counter.dart';
import 'package:mvi_counter/features/counter/domain/use_cases/update_counter.dart';

import '../../../support/fake_counter_repository.dart';

void main() {
  late FakeCounterRepository repository;
  late UpdateCounter update;

  setUp(() {
    repository = FakeCounterRepository();
    update = UpdateCounter(repository);
  });

  test('la entidad rechaza valores fuera de 0 a 99', () {
    expect(() => Counter(-1), throwsA(isA<CounterBoundaryException>()));
    expect(() => Counter(100), throwsA(isA<CounterBoundaryException>()));
    expect(Counter(99).value, 99);
  });

  test('lee el valor del repositorio', () async {
    repository.saved = Counter(7);
    expect(await GetCounter(repository)(), Counter(7));
  });

  test(
    'incrementa sin modificar la entidad anterior y persiste el resultado',
    () async {
      const before = Counter.zero();
      final after = await update(before, CounterOperation.increment);
      expect(before.value, 0);
      expect(after.value, 1);
      expect(repository.saved, after);
      expect(repository.writes, 1);
    },
  );

  test('decrementa y reinicia', () async {
    expect(await update(Counter(3), CounterOperation.decrement), Counter(2));
    expect(
      await update(Counter(8), CounterOperation.reset),
      const Counter.zero(),
    );
  });

  test('no guarda cuando una operación viola los límites', () async {
    await expectLater(
      update(const Counter.zero(), CounterOperation.decrement),
      throwsA(isA<CounterBoundaryException>()),
    );
    await expectLater(
      update(Counter(99), CounterOperation.increment),
      throwsA(isA<CounterBoundaryException>()),
    );
    expect(repository.writes, 0);
  });
}
