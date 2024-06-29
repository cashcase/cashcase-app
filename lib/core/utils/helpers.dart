import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

Future<void> delay(int ms) async {
  Future.delayed(Duration(milliseconds: ms), () {});
}

int random(int min, int max) => min + Random().nextInt(max - min);

class DebugCertificate extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Map<String, dynamic> decodeJwt(String token) => JwtDecoder.decode(token);

bool validEmail(String email) => RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
    .hasMatch(email);

DateTime? parseUtc(String? date, DateFormat? format) {
  if (date == null) return null;
  format ??= DateFormat('dd MMMM yyyy hh:mm a');
  try {
    return format.parse(date);
  } catch (e) {
    return null;
  }
}
