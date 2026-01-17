import 'package:dio/dio.dart';
import 'constants.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );
}
