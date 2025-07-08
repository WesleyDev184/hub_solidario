// Definindo AsyncResult baseado no uso no ApiClient
import 'package:result_dart/result_dart.dart';

typedef AsyncResult<T extends Object> = Future<Result<T>>;
