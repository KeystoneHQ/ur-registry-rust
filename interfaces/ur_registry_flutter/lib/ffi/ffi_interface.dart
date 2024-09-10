abstract class DynamicLibrary {
  const DynamicLibrary();

  lookup<T>(String symbolName);

  factory DynamicLibrary.open(String path) {
    throw UnimplementedError();
  }

  factory DynamicLibrary.process() {
    throw UnimplementedError();
  }
}

abstract class Pointer<T> {
  const Pointer();

  get address;

  get ref;

  toDartString();
}

abstract class Union {
  const Union();
}

abstract class Struct {
  const Struct();
}

abstract class Void {
  const Void();
}

class Bool {
  const Bool();
}

class Uint32 {
  const Uint32();
}

abstract class Utf8 {
  const Utf8();
}

abstract class NativeFunction<T> {
  const NativeFunction();
}

extension StringUtf8Pointer on String {
  toNativeUtf8() {}
}
