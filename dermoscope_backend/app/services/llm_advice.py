import os
import base64
import json
import logging
from typing import Dict, Any, Optional
import google.generativeai as genai
from google.generativeai.types import HarmCategory, HarmBlockThreshold
from fastapi import HTTPException
from app.core.config import settings

# Logger yapılandırması
logger = logging.getLogger(__name__)

# Gemini API'sini yapılandır
try:
    if not settings.GEMINI_API_KEY or not settings.GEMINI_API_KEY.strip():
        logger.error("HATA: GEMINI_API_KEY bulunamadı veya boş. Lütfen .env dosyanızı kontrol edin.")
        raise ValueError("Geçersiz GEMINI_API_KEY. Lütfen yapılandırmanızı kontrol edin.")
    
    # API anahtarını doğrula (en az 30 karakter olmalı)
    if len(settings.GEMINI_API_KEY) < 30:
        logger.error(f"HATA: Geçersiz GEMINI_API_KEY uzunluğu: {len(settings.GEMINI_API_KEY)}")
        raise ValueError("Geçersiz GEMINI_API_KEY formatı. Lütfen anahtarınızı kontrol edin.")
    
    genai.configure(api_key=settings.GEMINI_API_KEY)
    logger.info("Gemini API başarıyla yapılandırıldı")
    
except Exception as e:
    error_msg = f"Gemini API yapılandırma hatası: {str(e)}"
    logger.error(error_msg, exc_info=True)
    raise ValueError(f"Gemini API yapılandırılamadı: {str(e)}")

async def get_gemini_vision_analysis(base64_image: str) -> Dict[str, Any]:
    """
    Gemini API'sini kullanarak görsel analizi yapar.
    
    Args:
        base64_image: Base64 kodlanmış görsel verisi
        
    Returns:
        Dict: Analiz sonuçları ve tanı bilgisi
        
    Raises:
        HTTPException: API çağrısı başarısız olursa
    """
    logger.info("Gemini Vision analizi başlatılıyor...")
    
    if not settings.GEMINI_API_KEY:
        error_msg = "HATA: Gemini API anahtarı bulunamadı"
        logger.error(error_msg)
        return {
            "diagnosis": "Sistem şu anda çalışmıyor",
            "confidence": "düşük",
            "description": "API anahtarı yapılandırılmamış"
        }
        
    if not base64_image or len(base64_image) < 100:  # Basit bir uzunluk kontrolü
        error_msg = f"HATA: Geçersiz base64 görsel verisi. Uzunluk: {len(base64_image) if base64_image else 0}"
        logger.error(error_msg)
        return {
            "diagnosis": "Geçersiz görsel",
            "confidence": "düşük",
            "description": "Lütfen farklı bir görsel deneyin"
        }
    try:
        # API istemcisini yapılandır
        logger.info("Gemini API istemcisi yapılandırılıyor...")
        
        # Kullanılabilir modelleri kontrol et
        try:
            models = genai.list_models()
            available_models = [m.name for m in models]
            logger.info(f"Kullanılabilir modeller: {available_models}")
        except Exception as e:
            logger.error(f"Modeller listelenirken hata oluştu: {str(e)}")
        
        # Desteklenen modellerden birini kullan
        supported_models = ['gemini-1.5-flash', 'gemini-1.5-pro', 'gemini-pro']
        model_name = None
        
        # Kullanılabilir modelleri kontrol et ve desteklenen bir model seç
        try:
            models = genai.list_models()
            available_models = [m.name for m in models]
            logger.info(f"Kullanılabilir modeller: {available_models}")
            
            # Desteklenen modellerden mevcut olanı seç
            for m in supported_models:
                if any(m in model for model in available_models):
                    model_name = m
                    break
            
            if not model_name:
                raise ValueError(f"Desteklenen modellerden hiçbiri mevcut değil. Kullanılabilir modeller: {available_models}")
                
        except Exception as e:
            logger.error(f"Model kontrolü sırasında hata: {str(e)}")
            model_name = 'gemini-pro'  # Varsayılan model
        
        logger.info(f"{model_name} modeli kullanılıyor...")
        
        try:
            model = genai.GenerativeModel(
                model_name,
                generation_config={
                    "temperature": 0.3,
                    "top_p": 0.8,
                    "top_k": 32,
                    "max_output_tokens": 2048
                }
            )
        except Exception as e:
            logger.error(f"Model yüklenirken hata: {str(e)}")
            raise ValueError(f"Model yüklenemedi: {str(e)}")
        
        # Görsel analizi için prompt
        prompt = """
        Bu bir cilt lezyonu görüntüsüdür. Lütfen aşağıdaki formatta yanıt verin:
        
        {
            "diagnosis": "olası tanı (Türkçe olarak)",
            "confidence": "yüksek/orta/düşük",
            "description": "kısa açıklama (Türkçe olarak)"
        }
        
        Sadece yukarıdaki JSON formatında yanıt verin, başka hiçbir açıklama veya metin eklemeyin.
        """
        
        # İstek verilerini hazırla - Google'ın beklediği formata uygun hale getiriyoruz
        request_data = {
            "contents": [{
                "role": "user",
                "parts": [
                    {"text": prompt},
                    {
                        "inline_data": {
                            "mime_type": "image/jpeg",
                            "data": base64_image
                        }
                    }
                ]
            }],
            "generation_config": {
                "temperature": 0.3,
                "top_p": 0.8,
                "top_k": 32,
                "max_output_tokens": 2048
            }
        }
        
        logger.info("Gemini API'ye istek gönderiliyor...")
        logger.debug(f"İstek verisi: {str(request_data)[:200]}...")  # İlk 200 karakteri logla
        
        try:
            # Doğrudan generate_content yerine generate_content_async kullanıyoruz
            response = await model.generate_content_async(request_data["contents"][0])
            logger.info(f"Yanıt alındı")
            
            # Yanıtı kontrol et ve işle
            if not response or not hasattr(response, 'text'):
                logger.error(f"Geçersiz yanıt formatı. Yanıt: {response}")
                raise ValueError("Geçersiz yanıt formatı")
            
            # JSON formatındaki yanıtı çıkar
            result_text = response.text
            logger.info(f"Ham yanıt metni: {result_text}")
            
            # JSON formatındaki yanıtı ayıkla (```json ve ``` arasındaki kısmı al)
            if '```json' in result_text and '```' in result_text:
                result_text = result_text.split('```json')[1].split('```')[0].strip()
                logger.info(f"JSON ayıklanmış yanıt: {result_text}")
                
            # JSON'ı ayrıştır
            try:
                import json  # Ensure json is available locally
                result = json.loads(result_text)
                if not all(key in result for key in ["diagnosis", "confidence", "description"]):
                    raise ValueError("Eksik alanlar içeren yanıt")
                return result
            except json.JSONDecodeError as e:
                logger.error(f"JSON ayrıştırma hatası: {e}")
                raise ValueError("Geçersiz JSON formatı")
            except Exception as e:
                logger.error(f"Yanıt işleme hatası: {e}")
                raise
                
        except Exception as api_error:
            logger.error(f"API hatası: {str(api_error)}", exc_info=True)
            # Alternatif yöntem dene
            logger.info("Alternatif istek yöntemi deneniyor...")
            try:
                # Farklı bir istek formatı dene
                response = await model.generate_content_async({
                    "contents": [
                        {
                            "parts": [
                                {"text": prompt},
                                {
                                    "inline_data": {
                                        "mime_type": "image/jpeg",
                                        "data": base64_image
                                    }
                                }
                            ]
                        }
                    ]
                })
            except Exception as fallback_error:
                logger.error(f"Alternatif yöntem de başarısız oldu: {str(fallback_error)}")
                raise
        
    except Exception as e:
        logger.error(f"Gemini API hatası: {str(e)}")
        # Alternatif model ile tekrar dene
        try:
            logger.warning("Gemini 1.5 Flash modeli başarısız oldu, farklı bir model deneniyor...")
            # Daha basit bir model deneyelim
            model = genai.GenerativeModel('gemini-1.5-pro')
            
            # Sadece metin tabanlı bir istek yapalım
            text_only_prompt = f"""
            Aşağıdaki cilt lezyonu görüntüsünü analiz edin:
            
            {prompt}
            
            Lütfen sadece aşağıdaki JSON formatında yanıt verin:
            {{
                "diagnosis": "tanı",
                "confidence": "yüksek/orta/düşük",
                "description": "açıklama"
            }}
            """
            
            # Daha basit bir istek yapısı kullanalım
            response = await model.generate_content_async(text_only_prompt)
            
            # Yanıtı işle
            if not hasattr(response, 'text'):
                raise ValueError("Geçersiz yanıt formatı")
                
            result_text = response.text
            if '```json' in result_text and '```' in result_text:
                result_text = result_text.split('```json')[1].split('```')[0].strip()
                
            return json.loads(result_text)
        except Exception as fallback_error:
            logger.error(f"Alternatif model hatası: {str(fallback_error)}")
            # Son çare olarak sabit bir yanıt döndür
            return {
                "diagnosis": "Sistem şu anda meşgul",
                "confidence": "düşük",
                "description": "Lütfen daha sonra tekrar deneyin"
            }
        
        # Yanıtı işle ve logla
        result_text = response.text.strip()
        logger.info(f"Ham yanıt: {result_text}")
        
        # JSON formatını doğrula ve işle
        try:
            import json
            # Eğer yanıt JSON formatındaysa doğrudan yükle
            if result_text.startswith('{') and result_text.endswith('}'):
                result = json.loads(result_text)
            else:
                # JSON formatında değilse, yanıtı düz metin olarak işle
                logger.warning("JSON formatında yanıt alınamadı, düz metin olarak işleniyor...")
                result = {
                    "diagnosis": "Sistem yanıtı işleyemedi",
                    "confidence": "düşük",
                    "description": "Teknik bir sorun oluştu"
                }
            # Gerekli alanları kontrol et ve varsayılan değerler ata
            if not isinstance(result, dict):
                result = {}
                
            required_fields = {
                "diagnosis": "Tanı belirlenemedi",
                "confidence": "düşük",
                "description": "Teknik bir sorun oluştu"
            }
            
            # Eksik alanlar için varsayılan değerleri ata
            for field, default in required_fields.items():
                if field not in result or not result[field]:
                    result[field] = default
                    logger.warning(f"{field} alanı eksik, varsayılan değer atandı: {default}")
            return {
                "diagnosis": result.get("diagnosis", "Belirlenemedi"),
                "confidence": result.get("confidence", "belirsiz"),
                "description": result.get("description", "")
            }
        except json.JSONDecodeError:
            # Eğer JSON parse edilemezse, ham metni döndür
            return {
                "diagnosis": "Analiz hatası",
                "confidence": "düşük",
                "description": "Tanımlanamayan yanıt formatı"
            }
            
    except Exception as e:
        error_msg = f"Gemini Vision API hatası: {str(e)}"
        print(error_msg)
        raise HTTPException(
            status_code=500,
            detail=error_msg
        )

def get_llm_advice(question: str) -> str:
    """
    Kullanıcı sorusuna yanıt vermek için Gemini API'sini kullanır.
    
    Args:
        question: Kullanıcının sorusu
        
    Returns:
        str: LLM'den gelen yanıt
        
    Raises:
        Exception: API çağrısı başarısız olursa
    """
    try:
        # Kullanılabilir modelleri kontrol et
        supported_models = ['gemini-1.5-flash', 'gemini-1.5-pro', 'gemini-pro']
        model_name = None
        
        try:
            models = genai.list_models()
            available_models = [m.name for m in models]
            logger.info(f"Kullanılabilir modeller: {available_models}")
            
            # Desteklenen modellerden mevcut olanı seç
            for m in supported_models:
                if any(m in model for model in available_models):
                    model_name = m
                    break
            
            if not model_name:
                raise ValueError(f"Desteklenen modellerden hiçbiri mevcut değil. Kullanılabilir modeller: {available_models}")
                
            logger.info(f"{model_name} modeli seçildi")
            
            # Modeli başlat
            model = genai.GenerativeModel(model_name)
            
            # İstek yap
            response = model.generate_content(question)
            
            # Yanıtı işle
            if not hasattr(response, 'text'):
                raise ValueError("Geçersiz yanıt formatı")
                
            return response.text
            
        except Exception as model_error:
            logger.error(f"Model seçimi hatası: {str(model_error)}")
            # Son çare olarak varsayılan modeli dene
            try:
                logger.warning("Varsayılan model deneniyor...")
                model = genai.GenerativeModel('gemini-1.5-flash')
                response = model.generate_content(question)
                return response.text
            except Exception as fallback_error:
                logger.error(f"Varsayılan model hatası: {str(fallback_error)}")
                raise
                
    except Exception as e:
        return f"LLM API hatası: {e}"