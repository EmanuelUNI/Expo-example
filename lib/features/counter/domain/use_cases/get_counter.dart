import '../entities/counter.dart';
import '../repositories/counter_repository.dart';

final class GetCounter {
  const GetCounter(this._repository);

  final CounterRepository _repository;

  Future<Counter> call() => _repository.read();
}
