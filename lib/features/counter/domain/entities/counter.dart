/// Entidad de dominio: no conoce Flutter, la interfaz ni el almacenamiento.
final class Counter {
  const Counter.zero() : value = 0;

  factory Counter(int value) {
    if (value < minimum || value > maximum) {
      throw const CounterBoundaryException();
    }
    return Counter._(value);
  }

  const Counter._(this.value);

  static const minimum = 0;
  static const maximum = 99;
  final int value;

  @override
  bool operator ==(Object other) => other is Counter && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

final class CounterBoundaryException implements Exception {
  const CounterBoundaryException();
}

enum CounterOperation { increment, decrement, reset }
