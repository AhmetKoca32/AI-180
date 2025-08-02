import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? originalError;
  final String? apiResponse;

  ApiException({
    required this.statusCode,
    required this.message,
    this.originalError,
    this.apiResponse,
  });

  @override
  String toString() => 'API Hatası ($statusCode): $message';
  
  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'message': message,
        if (originalError != null) 'originalError': originalError,
        if (apiResponse != null) 'apiResponse': apiResponse,
      };
}

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator için, gerçek cihazda backend IP'sini girin

  // Genel amaçlı POST isteği (JSON veri gönderimi için)
  static Future<Map<String, dynamic>> postJson(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      
      print('API Response (${response.statusCode}): ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final errorMsg = _parseError(response);
        throw ApiException(
          statusCode: response.statusCode,
          message: errorMsg,
          apiResponse: response.body,
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Sunucuya bağlanılamadı. Lütfen internet bağlantınızı kontrol edin.',
        originalError: e.toString(),
      );
    } catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Beklenmeyen bir hata oluştu',
        originalError: e.toString(),
      );
    }
  }
  
  // Hata mesajını ayrıştır
  static String _parseError(http.Response response) {
    try {
      final errorData = json.decode(response.body);
      if (errorData is Map) {
        return errorData['detail'] ?? 
               errorData['message'] ?? 
               errorData['error'] ?? 
               'Bilinmeyen hata';
      }
    } catch (e) {
      // JSON ayrıştırma hatası
    }
    
    // HTTP durum koduna göre özel mesajlar
    switch (response.statusCode) {
      case 400:
        return 'Geçersiz istek. Lütfen bilgilerinizi kontrol edin.';
      case 401:
        return 'Yetkisiz erişim. Lütfen tekrar giriş yapın.';
      case 403:
        return 'Bu işlem için yetkiniz yok.';
      case 404:
        return 'İstenen kaynak bulunamadı.';
      case 429:
        return 'Çok fazla istek gönderdiniz. Lütfen bir süre sonra tekrar deneyin.';
      case 500:
        return 'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.';
      case 503:
        return 'Sunucu bakımda. Lütfen daha sonra tekrar deneyin.';
      default:
        return 'Beklenmeyen bir hata oluştu (${response.statusCode})';
    }
  }

  // Genel amaçlı GET isteği
  static Future<Map<String, dynamic>> getJson(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(url);
      
      print('API GET Response (${response.statusCode}): ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final errorMsg = _parseError(response);
        throw ApiException(
          statusCode: response.statusCode,
          message: errorMsg,
          apiResponse: response.body,
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Sunucuya bağlanılamadı. Lütfen internet bağlantınızı kontrol edin.',
        originalError: e.toString(),
      );
    } catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Beklenmeyen bir hata oluştu',
        originalError: e.toString(),
      );
    }
  }

  // Fotoğrafı backend'e gönder ve hastalık bilgisini al
  static Future<Map<String, dynamic>?> sendImageForDiagnosis(String imagePath, {String? modelName}) async {
  return await sendImageToEndpoint('/model_api/predict', imagePath, modelName: modelName);
}

  // Genel amaçlı: Sadece fotoğraf dosyası gönderen endpoint fonksiyonu
  static Future<Map<String, dynamic>?> sendImageToEndpoint(String endpoint, String imagePath, {String? modelName}) async {
  final url = Uri.parse('$baseUrl$endpoint');
  final request = http.MultipartRequest('POST', url);
  request.files.add(await http.MultipartFile.fromPath('file', imagePath));
  if (modelName != null && modelName.isNotEmpty) {
    request.fields['model_name'] = modelName;
  }
  try {
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      print('API Error: [33m${response.statusCode}[0m - ${response.body}');
      return null;
    }
  } catch (e) {
    print('API Exception: $e');
    return null;
  }
}

  static Future<String> getAdvice(String question) async {
  final url = Uri.parse('$baseUrl/advice');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'question': question}),
  );
  print('Backend yanıtı: ${response.body}');
  if (response.statusCode == 200) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is String) {
        return decoded;
      } else if (decoded is Map) {
        // 'answer' veya 'advice' anahtarını kontrol et
        if (decoded.containsKey('answer')) {
          return decoded['answer'];
        } else if (decoded.containsKey('advice')) {
          return decoded['advice'];
        } else if (decoded.containsKey('error')) {
          return 'Hata: ${decoded['error']}';
        } else {
          return decoded.toString();
        }
      } else {
        return response.body.toString();
      }
    } catch (e) {
      // JSON parse hatası olursa düz string döndür
      return response.body.toString();
    }
  } else {
    throw Exception('AI cevabı alınamadı: ${response.statusCode}');
  }
}
}
