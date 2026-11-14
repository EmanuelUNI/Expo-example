/// Las intenciones describen acciones; no contienen reglas de negocio.
sealed class CounterIntent {
  const CounterIntent();

  String get label => switch (this) {
    LoadCounter() => 'Cargar',
    IncrementCounter() => 'Incrementar',
    DecrementCounter() => 'Decrementar',
    ResetCounter() => 'Reiniciar',
    RetryCounter() => 'Reintentar',
  };

  String get code => switch (this) {
    LoadCounter() => 'LoadCounter()',
    IncrementCounter() => 'IncrementCounter()',
    DecrementCounter() => 'DecrementCounter()',
    ResetCounter() => 'ResetCounter()',
    RetryCounter() => 'RetryCounter()',
  };
}

final class LoadCounter extends CounterIntent {
  const LoadCounter();
}

final class IncrementCounter extends CounterIntent {
  const IncrementCounter();
}

final class DecrementCounter extends CounterIntent {
  const DecrementCounter();
}

final class ResetCounter extends CounterIntent {
  const ResetCounter();
}

final class RetryCounter extends CounterIntent {
  const RetryCounter();
}
