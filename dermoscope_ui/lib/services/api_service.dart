import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator için, gerçek cihazda backend IP'sini girin

  // Genel amaçlı POST isteği (JSON veri gönderimi için)
  static Future<Map<String, dynamic>?> postJson(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('API Exception: $e');
      return null;
    }
  }

  // Genel amaçlı GET isteği
  static Future<Map<String, dynamic>?> getJson(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('API Exception: $e');
      return null;
    }
  }

  // Fotoğrafı backend'e gönder ve hastalık bilgisini al
  static Future<Map<String, dynamic>?> sendImageForDiagnosis(String imagePath) async {
    return await sendImageToEndpoint('/model_api/predict', imagePath);
  }

  // Genel amaçlı: Sadece fotoğraf dosyası gönderen endpoint fonksiyonu
  static Future<Map<String, dynamic>?> sendImageToEndpoint(String endpoint, String imagePath) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('API Exception: $e');
      return null;
    }
  }
}
