import 'package:equatable/equatable.dart';

class Result<T> extends Equatable {
  const Result.success(T value) : this._(value: value);

  const Result.failure(Object error) : this._(error: error);

  const Result._({T? value, Object? error}) : _value = value, _error = error;

  final T? _value;
  final Object? _error;

  bool get isSuccess => _error == null;

  bool get isFailure => !isSuccess;

  T get value {
    if (isFailure) {
      throw StateError('Cannot read value from a failed result.');
    }
    return _value as T;
  }

  Object get errorObject {
    if (isSuccess) {
      throw StateError('Cannot read error from a successful result.');
    }
    return _error!;
  }

  String get error {
    if (isSuccess) {
      throw StateError('Cannot read error from a successful result.');
    }
    return _error.toString();
  }

  @override
  List<Object?> get props => [_value, _error];
}
