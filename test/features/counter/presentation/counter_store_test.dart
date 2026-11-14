import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mvi_counter/features/counter/domain/use_cases/get_counter.dart';
import 'package:mvi_counter/features/counter/domain/use_cases/update_counter.dart';
import 'package:mvi_counter/features/counter/presentation/mvi/counter_intent.dart';
import 'package:mvi_counter/features/counter/presentation/mvi/counter_state.dart';
import 'package:mvi_counter/features/counter/presentation/mvi/counter_store.dart';

import '../../../support/fake_counter_repository.dart';

void main() {
  late FakeCounterRepository repository;
  late CounterStore store;

  setUp(() {
    repository = FakeCounterRepository();
    store = CounterStore(
      getCounter: GetCounter(repository),
      updateCounter: UpdateCounter(repository),
    );
  });

  tearDown(() => store.dispose());

  test(
    'publica carga, listo, actualización y nuevo estado en ese orden',
    () async {
      final statuses = <CounterStatus>[];
      store.addListener(() => statuses.add(store.state.status));
      await store.dispatch(const LoadCounter());
      final oldState = store.state;
      await store.dispatch(const IncrementCounter());
      expect(statuses, [
        CounterStatus.loading,
        CounterStatus.ready,
        CounterStatus.updating,
        CounterStatus.ready,
      ]);
      expect(oldState.counter.value, 0);
      expect(oldState.history, isEmpty);
      expect(store.state.counter.value, 1);
      expect(store.state.history.single.before, 0);
      expect(store.state.history.single.after, 1);
      expect(() => store.state.history.clear(), throwsUnsupportedError);
    },
  );

  test(
    'serializa clics simultáneos y conserva el orden de las acciones',
    () async {
      await store.dispatch(const LoadCounter());
      await Future.wait([
        store.dispatch(const IncrementCounter()),
        store.dispatch(const IncrementCounter()),
        store.dispatch(const DecrementCounter()),
        store.dispatch(const ResetCounter()),
        store.dispatch(const IncrementCounter()),
      ]);
      expect(store.state.counter.value, 1);
      expect(store.state.revision, 5);
      expect(store.state.history.map((t) => t.after), [1, 0, 1, 2, 1]);
    },
  );

  test('ignora cambios antes de cargar', () async {
    await store.dispatch(const IncrementCounter());
    expect(repository.writes, 0);
    expect(store.state.initialized, isFalse);
  });

  test('recupera un fallo de carga con la misma intención', () async {
    repository.failNextRead = true;
    await store.dispatch(const LoadCounter());
    expect(store.state.status, CounterStatus.failure);
    expect(store.state.initialized, isFalse);
    await store.dispatch(const RetryCounter());
    expect(store.state.status, CounterStatus.ready);
    expect(store.state.initialized, isTrue);
    expect(store.state.errorMessage, isNull);
    expect(repository.reads, 2);
  });

  test(
    'un fallo al guardar conserva el valor y el reintento no duplica el cambio',
    () async {
      await store.dispatch(const LoadCounter());
      await store.dispatch(const IncrementCounter());
      repository.failNextSave = true;
      await store.dispatch(const IncrementCounter());
      expect(store.state.status, CounterStatus.failure);
      expect(store.state.counter.value, 1);
      expect(store.state.revision, 1);
      expect(repository.saved.value, 1);
      await store.dispatch(const RetryCounter());
      expect(store.state.status, CounterStatus.ready);
      expect(store.state.counter.value, 2);
      expect(store.state.revision, 2);
      expect(store.state.history.length, 2);
    },
  );

  test('una intención posterior no sobreescribe un error pendiente', () async {
    await store.dispatch(const LoadCounter());
    repository.failNextSave = true;
    await Future.wait([
      store.dispatch(const IncrementCounter()),
      store.dispatch(const IncrementCounter()),
    ]);
    expect(store.state.status, CounterStatus.failure);
    expect(repository.writes, 1);
    await store.dispatch(const RetryCounter());
    expect(store.state.counter.value, 1);
  });

  test('la validación no guarda ni añade una transición falsa', () async {
    await store.dispatch(const LoadCounter());
    await store.dispatch(const DecrementCounter());
    expect(store.state.counter.value, 0);
    expect(store.state.status, CounterStatus.ready);
    expect(store.state.errorMessage, isNotNull);
    expect(store.state.history, isEmpty);
    expect(repository.writes, 0);
    await store.dispatch(const IncrementCounter());
    expect(store.state.errorMessage, isNull);
  });

  test('el historial se limita a ocho cambios sin perder el total', () async {
    await store.dispatch(const LoadCounter());
    for (var i = 0; i < 12; i++) {
      await store.dispatch(const IncrementCounter());
    }
    expect(store.state.history.length, 8);
    expect(store.state.history.first.revision, 12);
    expect(store.state.history.last.revision, 5);
    expect(store.state.revision, 12);
  });

  test('no notifica ni ejecuta trabajo en cola después de dispose', () async {
    final started = Completer<void>();
    var notifications = 0;
    final disposableStore = CounterStore(
      getCounter: GetCounter(repository),
      updateCounter: UpdateCounter(repository),
    );
    disposableStore.addListener(() {
      notifications++;
      if (!started.isCompleted) started.complete();
    });
    final loading = disposableStore.dispatch(const LoadCounter());
    final queued = disposableStore.dispatch(const IncrementCounter());
    await started.future;
    disposableStore.dispose();
    await Future.wait([loading, queued]);
    await disposableStore.dispatch(const IncrementCounter());
    expect(notifications, 1);
    expect(repository.writes, 0);
  });
}
