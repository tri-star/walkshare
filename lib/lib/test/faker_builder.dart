typedef PrepareFunction<T> = T Function();

class FakerBuilder<T> {
  T create(PrepareFunction<T> prepareFunction) {
    return prepareFunction();
  }

  List<T> createMany(PrepareFunction<T> prepareFunction, int count) {
    List<T> result = [];
    for (var i = 0; i < count; i++) {
      result.add(prepareFunction());
    }
    return result;
  }
}
