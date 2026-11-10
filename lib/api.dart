import 'dart:convert';
import 'package:http/http.dart' as http;

class PortalApi {
  static const base = String.fromEnvironment('API_BASE', defaultValue: 'http://10.0.0.20');

  static Future<List<Map<String, dynamic>>> countries() async {
    final body = await _get('/api/countries');
    return List<Map<String, dynamic>>.from(body['data'] as List);
  }

  static Future<Map<String, dynamic>> channels(String country, {int page = 1}) async {
    return _get('/api/channels?country=$country&page=$page');
  }

  static Future<Map<String, dynamic>> info(String path) => _get('/api$path');

  static Future<void> reportDead(String playUrl) async {
    try {
      await http.post(
        Uri.parse('$base/api/report-dead'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'url': playUrl}),
      );
    } catch (_) {
      // best-effort; filtering still works on next probe
    }
  }

  static Future<Map<String, dynamic>> _get(String path) async {
    final response = await http.get(Uri.parse('$base$path'));
    if (response.statusCode != 200) {
      throw Exception('Portal ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
