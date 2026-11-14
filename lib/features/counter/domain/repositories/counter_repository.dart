import '../entities/counter.dart';

/// El dominio declara el contrato; la capa de datos lo implementa.
abstract interface class CounterRepository {
  Future<Counter> read();
  Future<void> save(Counter counter);
}
