import 'package:flutter/material.dart';

class TextUtils {
  // Metin temizleme fonksiyonu (JSON, markdown, özel karakterler)
  static String cleanText(String? text, {String fallback = ''}) {
    if (text == null || text.isEmpty) return fallback;
    
    // Önce JSON benzeri yapıları temizle
    String cleaned = text
        // JSON anahtarlarını kaldır ("diagnosis":, "description": gibi)
        .replaceAll(RegExp(r'"?(diagnosis|description|severity|name|confidence)"?\s*:?\s*"?', caseSensitive: false), '')
        // Kalan tırnak işaretlerini ve süslü parantezleri kaldır
        .replaceAll(RegExp(r'["{}]'), '')
        // Markdown formatlamalarını kaldır
        .replaceAll(RegExp(r'\*\*|\*|•|_|\-|\n|\r|\t'), ' ')
        // Tekrarlanan boşlukları temizle
        .replaceAll(RegExp(r'\s+'), ' ')
        // Başta ve sondaki boşlukları kaldır
        .trim();

    // Eğer temizlenmiş metin sadece noktalama işaretleriyse veya çok kısaysa
    if (cleaned.isEmpty || cleaned.length < 2) {
      return fallback;
    }

    // İlk harfi büyük yap
    cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    
    // Eğer son karakter nokta, ünlem veya soru işareti değilse nokta ekle
    if (!cleaned.endsWith('.') && !cleaned.endsWith('!') && !cleaned.endsWith('?')) {
      cleaned += '.';
    }

    return cleaned;
  }

  // LLM yanıtını temizleme fonksiyonu
  static String cleanLlmResponse(String? response) {
    if (response == null || response.isEmpty) return '';
    
    // JSON formatındaysa özel olarak işle
    if (response.trim().startsWith('{') && response.trim().endsWith('}')) {
      try {
        // JSON'dan sadece değerleri çıkar
        return response
            .replaceAllMapped(
              RegExp(r'"([^"]+)"\s*:\s*(("[^"]*")|(true|false|null|\d+))', multiLine: true), 
              (match) => match.group(2) ?? ''
            )
            .replaceAll(RegExp(r'["{}]'), '')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
      } catch (e) {
        debugPrint('JSON parse error: $e');
      }
    }
    
    // JSON değilse normal temizleme işlemi yap
    return cleanText(response);
  }
}
