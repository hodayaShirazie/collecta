import 'auth_headers.dart';


class ApiSource {

    Future<Map<String, String>> headers() async {
      return await AuthHeaders.build();
    }

}
