/// Yuklanadigan ma'lumotning uch holati: yuklanmoqda, xato, tayyor.
///
/// Ekranlar shu uchtasini ham ko'rsatishi kerak — "yuklanmoqda" ni
/// unutsangiz, foydalanuvchi bo'sh ekranga qarab turadi.
sealed class Async<T> {
  const Async();

  const factory Async.loading() = AsyncLoading<T>;
  const factory Async.data(T value) = AsyncData<T>;
  const factory Async.error(String message) = AsyncError<T>;

  T? get valueOrNull => this is AsyncData<T> ? (this as AsyncData<T>).value : null;
  bool get isLoading => this is AsyncLoading<T>;

  R when<R>({
    required R Function() loading,
    required R Function(T value) data,
    required R Function(String message) error,
  }) =>
      switch (this) {
        AsyncLoading<T>() => loading(),
        AsyncData<T>(:final value) => data(value),
        AsyncError<T>(:final message) => error(message),
      };
}

final class AsyncLoading<T> extends Async<T> {
  const AsyncLoading();
}

final class AsyncData<T> extends Async<T> {
  const AsyncData(this.value);
  final T value;
}

final class AsyncError<T> extends Async<T> {
  const AsyncError(this.message);
  final String message;
}
