import 'dart:convert';

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
        message:
            'Sunucuya bağlanılamadı. Lütfen internet bağlantınızı kontrol edin.',
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

  // Genel amaçlı PUT isteği
  static Future<Map<String, dynamic>> putJson(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      print('API PUT Response (${response.statusCode}): ${response.body}');

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
        message:
            'Sunucuya bağlanılamadı. Lütfen internet bağlantınızı kontrol edin.',
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

  // Backend bağlantısını test et
  static Future<bool> testBackendConnection() async {
    try {
      print('API: Backend bağlantısı test ediliyor...');
      final response = await http.get(Uri.parse('$baseUrl/user/test'));
      print(
        'API: Backend test response: ${response.statusCode} - ${response.body}',
      );
      return response.statusCode == 200;
    } catch (e) {
      print('API: Backend bağlantı hatası: $e');
      return false;
    }
  }

  // Kullanıcı profil bilgilerini getir
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      print('API: getUserProfile çağrılıyor...');

      // Önce backend bağlantısını test et
      final isBackendAvailable = await testBackendConnection();
      print('API: Backend erişilebilir: $isBackendAvailable');

      if (!isBackendAvailable) {
        print('API: Backend erişilemedi, test verileri döndürülüyor...');
        return {
          "id": 1,
          "username": "ahmet_koca",
          "email": "ahmet.koca@email.com",
          "first_name": "Ahmet",
          "last_name": "Koca",
          "phone": "+90 532 123 4567",
          "age": 32,
          "gender": "Erkek",
        };
      }

      // TODO: Token'ı auth service'den al
      final response = await getJson('/user/profile');
      print('API: getUserProfile başarılı: $response');
      return response;
    } on ApiException catch (e) {
      print('API: Kullanıcı profil hatası: ${e.message}');
      print('API: Status code: ${e.statusCode}');
      print('API: API Response: ${e.apiResponse}');
      // Backend çalışmıyorsa test verilerini döndür
      print('API: Test verileri döndürülüyor...');
      return {
        "id": 1,
        "username": "ahmet_koca",
        "email": "ahmet.koca@email.com",
        "first_name": "Ahmet",
        "last_name": "Koca",
        "phone": "+90 532 123 4567",
        "age": 32,
        "gender": "Erkek",
      };
    } catch (e) {
      print('API: Beklenmeyen kullanıcı profil hatası: $e');
      // Backend çalışmıyorsa test verilerini döndür
      print('API: Test verileri döndürülüyor...');
      return {
        "id": 1,
        "username": "ahmet_koca",
        "email": "ahmet.koca@email.com",
        "first_name": "Ahmet",
        "last_name": "Koca",
        "phone": "+90 532 123 4567",
        "age": 32,
        "gender": "Erkek",
      };
    }
  }

  // Kullanıcı profil bilgilerini güncelle
  static Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> userData,
  ) async {
    try {
      // TODO: Token'ı auth service'den al
      final response = await putJson('/user/profile', userData);
      return response;
    } on ApiException catch (e) {
      print('Kullanıcı profil güncelleme hatası: ${e.message}');
      // Backend çalışmıyorsa güncellenmiş test verilerini döndür
      return {
        "id": 1,
        "username": "ahmet_koca",
        "email": "ahmet.koca@email.com",
        "first_name": userData['first_name'] ?? "Ahmet",
        "last_name": userData['last_name'] ?? "Koca",
        "phone": userData['phone'] ?? "+90 532 123 4567",
        "age": userData['age'] ?? 32,
        "gender": userData['gender'] ?? "Erkek",
      };
    } catch (e) {
      print('Beklenmeyen kullanıcı profil güncelleme hatası: $e');
      // Backend çalışmıyorsa güncellenmiş test verilerini döndür
      return {
        "id": 1,
        "username": "ahmet_koca",
        "email": "ahmet.koca@email.com",
        "first_name": userData['first_name'] ?? "Ahmet",
        "last_name": userData['last_name'] ?? "Koca",
        "phone": userData['phone'] ?? "+90 532 123 4567",
        "age": userData['age'] ?? 32,
        "gender": userData['gender'] ?? "Erkek",
      };
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

  // Saç analiz formu gönderimi için
  static Future<Map<String, dynamic>> submitHairAnalysis(
    Map<String, dynamic> formData,
  ) async {
    try {
      // Make a copy of the form data to avoid modifying the original
      final normalizedData = Map<String, dynamic>.from(formData);

      // Debug log for input data
      print('Original form data: $formData');

      // Normalize hair_texture from 1-5 range to 0-1 range
      if (normalizedData.containsKey('hair_texture')) {
        print(
          'Original hair_texture: ${normalizedData['hair_texture']} (${normalizedData['hair_texture'].runtimeType})',
        );

        // Ensure we have a double value
        final hairTexture = normalizedData['hair_texture'] is int
            ? (normalizedData['hair_texture'] as int).toDouble()
            : double.tryParse(normalizedData['hair_texture'].toString()) ?? 0.5;

        // Ensure the value is in 0-1 range
        // If the value is > 1, it's likely in 1-5 range, so normalize it
        final normalizedHairTexture = hairTexture > 1.0
            ? (hairTexture - 1) /
                  4.0 // Convert from 1-5 to 0-1 range
            : hairTexture.clamp(0.01, 1.0); // Ensure it's not 0 and not > 1

        normalizedData['hair_texture'] = normalizedHairTexture;

        print('Normalized hair_texture: $normalizedHairTexture');
      }

      // Create the request data with the normalized values
      final requestData = {
        'hair_analysis': normalizedData,
        'model_name': 'hair_model.h5',
      };

      print('Sending request with data: $requestData');

      final response = await postJson('/model_api/predict', requestData);

      return response;
    } on ApiException catch (e) {
      print('Saç analiz hatası: ${e.message}');
      rethrow;
    } catch (e) {
      print('Beklenmeyen saç analiz hatası: $e');
      throw ApiException(
        statusCode: 0,
        message: 'Saç analizi sırasında bir hata oluştu',
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
        print('API Error: [33m${response.statusCode}[0m - ${response.body}');
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

  // Basit network test
  static Future<void> testNetworkConnection() async {
    try {
      print('API: Network test başlatılıyor...');
      print('API: Base URL: $baseUrl');

      // Test endpoint'ini çağır
      final testUrl = Uri.parse('$baseUrl/user/test');
      print('API: Test URL: $testUrl');

      final response = await http.get(testUrl);
      print('API: Test response status: ${response.statusCode}');
      print('API: Test response body: ${response.body}');

      if (response.statusCode == 200) {
        print('API: Backend erişilebilir!');
      } else {
        print(
          'API: Backend erişilebilir ama hata döndürüyor: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('API: Network test hatası: $e');
    }
  }

  // Test kullanıcısı oluştur
  static Future<Map<String, dynamic>> createTestUser() async {
    try {
      print('API: Test kullanıcısı oluşturuluyor...');
      final response = await postJson('/user/create-test-user', {});
      print('API: Test kullanıcısı oluşturma sonucu: $response');
      return response;
    } on ApiException catch (e) {
      print('API: Test kullanıcısı oluşturma hatası: ${e.message}');
      rethrow;
    } catch (e) {
      print('API: Beklenmeyen test kullanıcısı oluşturma hatası: $e');
      throw ApiException(
        statusCode: 0,
        message: 'Test kullanıcısı oluşturulurken bir hata oluştu',
        originalError: e.toString(),
      );
    }
  }
}
