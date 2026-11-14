import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvi_counter/app/app.dart';
import 'package:mvi_counter/app/theme.dart';
import 'package:mvi_counter/features/counter/domain/use_cases/get_counter.dart';
import 'package:mvi_counter/features/counter/domain/use_cases/update_counter.dart';
import 'package:mvi_counter/features/counter/presentation/mvi/counter_intent.dart';
import 'package:mvi_counter/features/counter/presentation/mvi/counter_store.dart';
import 'package:mvi_counter/features/counter/presentation/pages/counter_page.dart';

import '../../../support/fake_counter_repository.dart';

void main() {
  testWidgets('incrementa, decrementa y reinicia desde la vista', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MviApp());
    await tester.pumpAndSettle();
    Text value() => tester.widget<Text>(find.byKey(const Key('counter-value')));
    expect(value().data, '0');
    final decrement = find.byKey(const Key('decrement'));
    expect(tester.widget<OutlinedButton>(decrement).onPressed, isNull);
    await tester.tap(find.byKey(const Key('increment')));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('increment'))).onPressed,
      isNull,
    );
    await tester.pumpAndSettle();
    expect(value().data, '1');
    expect(find.text('0 → 1'), findsOneWidget);
    expect(find.text('IncrementCounter()'), findsOneWidget);
    await tester.tap(decrement);
    await tester.pumpAndSettle();
    expect(value().data, '0');
    await tester.tap(find.byKey(const Key('increment')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reset')));
    await tester.pumpAndSettle();
    expect(value().data, '0');
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra un error de lectura y permite reintentar', (
    tester,
  ) async {
    final repository = FakeCounterRepository()..failNextRead = true;
    final store = CounterStore(
      getCounter: GetCounter(repository),
      updateCounter: UpdateCounter(repository),
    );
    addTearDown(store.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: CounterPage(store: store),
      ),
    );
    store.dispatch(const LoadCounter());
    await tester.pumpAndSettle();
    expect(
      find.text('No pudimos cargar el contador. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byKey(const Key('retry')));
    await tester.tap(find.byKey(const Key('retry')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('retry')), findsNothing);
    expect(
      tester.widget<Text>(find.byKey(const Key('counter-value'))).data,
      '0',
    );
  });

  for (final scenario in [
    (width: 320.0, scale: 1.0),
    (width: 320.0, scale: 1.8),
    (width: 1280.0, scale: 1.0),
  ]) {
    testWidgets(
      'sin desbordamientos a ${scenario.width}px y texto ${scenario.scale}x',
      (tester) async {
        tester.view.physicalSize = Size(scenario.width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = FakeCounterRepository();
        final store = CounterStore(
          getCounter: GetCounter(repository),
          updateCounter: UpdateCounter(repository),
        );
        addTearDown(store.dispose);
        await tester.pumpWidget(
          MaterialApp(
            theme: buildTheme(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scenario.scale)),
              child: child!,
            ),
            home: CounterPage(store: store),
          ),
        );
        store.dispatch(const LoadCounter());
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('architecture')));
        await tester.tap(find.byKey(const Key('architecture')));
        await tester.pumpAndSettle();
        expect(find.text('Dominio'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
