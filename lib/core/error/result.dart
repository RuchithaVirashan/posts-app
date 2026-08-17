import 'failures.dart';

sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) ok,
    required R Function(Failure failure) err,
  }) {
    final self = this;
    return switch (self) {
      Ok<T>() => ok(self.data),
      Err<T>() => err(self.failure),
    };
  }

  bool get isOk => this is Ok<T>;

  bool get isErr => this is Err<T>;
}

final class Ok<T> extends Result<T> {
  const Ok(this.data);

  final T data;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
