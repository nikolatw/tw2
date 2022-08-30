import 'dart:convert';
import 'dart:ffi';
import 'dart:io' show Directory;
import 'package:path/path.dart';
import 'package:ffi/ffi.dart';

typedef CallSignature = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);

DynamicLibrary? dylib;
CallSignature? callBinding;

Map<String, dynamic> Function(Map<String, dynamic>) plainCaller(String channel) {
  return (Map<String, dynamic> requestValue) {
    dylib ??= DynamicLibrary.open(join(Directory.current.path, '../dist/ffi.so'));
    callBinding ??= dylib!.lookup<NativeFunction<CallSignature>>('Call').asFunction();

    final request = jsonEncode(requestValue);

    final response = callBinding!(
      channel.toNativeUtf8(),
      request.toNativeUtf8(),
    );
    final responseValue = jsonDecode(response.toDartString());

    return responseValue;
  };
}
