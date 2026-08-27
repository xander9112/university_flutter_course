# Лекция 5 - Dart - Асинхронное программирование

Тема лекции — асинхронное программирование в Dart: Future, async/await и Stream.

Лекция объясняет однопоточную модель Dart с event loop и разбирает `Future<T>` — его состояния, методы `.then()`, `.catchError()`, `.whenComplete()`, а также конструкцию `async`/`await` и обработку ошибок через `try/catch/finally`. Отдельно рассматриваются параллельное выполнение с `Future.wait` и `Future.any`, работа с `Stream<T>` и `StreamController` (в том числе broadcast-потоки), генераторы `async*`/`yield`/`yield*`, а также первое знакомство с `StreamBuilder`.
