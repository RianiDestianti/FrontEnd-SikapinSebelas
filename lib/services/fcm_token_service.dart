import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FcmTokenService {
  FcmTokenService._internal();

  static final FcmTokenService instance = FcmTokenService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _messaging.requestPermission();

    final token = await _messaging.getToken();
    if (token != null) {
      await _sendToken(token);
    }

    _messaging.onTokenRefresh.listen((newToken) {
      _sendToken(newToken);
    });
  }

  Future<void> syncToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _sendToken(token);
    }
  }

  Future<void> _sendToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final nip = prefs.getString('walikelas_id') ?? '';
    if (nip.isEmpty) {
      return;
    }

    try {
      await http.post(
        Uri.parse('http://sijuwara.student.smkn11bdg.sch.id/api/fcm-token'),
        headers: {'Accept': 'application/json'},
        body: {
          'nip': nip,
          'token': token,
          'device_name': 'android',
        },
      );
    } catch (_) {
      // Ignore token sync errors to avoid blocking app flow.
    }
  }
}
