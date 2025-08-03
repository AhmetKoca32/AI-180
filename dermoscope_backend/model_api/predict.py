from fastapi import APIRouter, UploadFile, File, Form, HTTPException, Request
import numpy as np
from PIL import Image
import io
import base64
import json
import logging
from pydantic import BaseModel, Field
from tensorflow.keras.models import load_model
import os
from typing import Dict, Any

# Logging ayarları
logging.basicConfig(level=logging.INFO, format='%(levelname)s:%(module)s.%(funcName)s:%(message)s')
logger = logging.getLogger(__name__)

router = APIRouter()

MODEL_PATHS = {
    "skin_canser_model.h5": "model_api/skin_cancer_model.h5",
    "hair_model.h5": "model_api/binary_model.h5",
    "other_model.h5": "model_api/other_model.h5"
}

# Model cache dictionary
model_cache = {}

# Pydantic model for hair analysis request
class HairAnalysisRequest(BaseModel):
    stress_level: float = Field(..., ge=0, le=10, description="Stres seviyesi (0-10 arası)")
    body_water_content: float = Field(..., ge=0, le=100, description="Vücut su oranı (%)")
    total_protein: float = Field(..., ge=0, description="Toplam protein seviyesi (g/dL)")
    total_keratine: float = Field(..., ge=0, description="Keratin seviyesi (µg/mL)")
    iron: float = Field(..., ge=0, description="Demir seviyesi (µg/dL)")
    calcium: float = Field(..., ge=0, description="Kalsiyum seviyesi (mg/dL)")
    vitamin: float = Field(..., ge=0, description="Genel vitamin skoru (0-100 arası)")
    manganese: float = Field(..., ge=0, description="Kandaki mangan seviyesi (µg/L)")
    liver_data: float = Field(..., ge=0, le=100, description="Karaciğer fonksiyon skoru (0-100 arası)")
    hair_texture: float = Field(..., ge=0, le=1, description="Saç dokusu (0: İnce, 1: Kalın)")


async def handle_hair_analysis(hair_analysis: HairAnalysisRequest) -> Dict[str, Any]:
    """
    Process hair analysis data and return results.
    
    Args:
        hair_analysis: Validated hair analysis data
        
    Returns:
        Dict containing analysis results
    """
    try:
        logger.info(f"Processing hair analysis data: {hair_analysis}")
        
        # Burada saç analizi modelini yükleyip tahmin yapılacak
        # Örnek olarak basit bir sonuç döndürüyoruz
        
        # Örnek tahmin sonuçları
        result = {
            "status": "success",
            "analysis": {
                "hair_health_score": 0.85,  # 0-1 arası sağlık skoru
                "recommendations": [
                    "Düzenli saç bakımı yapın.",
                    "Protein açısından zengin besinler tüketin.",
                    "Düzenli su tüketimine özen gösterin."
                ],
                "nutrient_scores": {
                    "protein": 0.7,
                    "iron": 0.8,
                    "vitamins": 0.6,
                    "hydration": 0.9
                }
            },
            "input_data": hair_analysis.dict()
        }
        
        logger.info(f"Hair analysis completed successfully")
        return result
        
    except Exception as e:
        logger.error(f"Error in handle_hair_analysis: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f"Error processing hair analysis: {str(e)}"
        )


def get_model(model_name):
    if model_name not in model_cache:
        model_path = MODEL_PATHS.get(model_name, MODEL_PATHS['skin_canser_model.h5'])
        print(f"[MODEL LOAD] Yüklenen model: {model_name} -> {model_path}")
        
        # Modeli yükle
        model = load_model(model_path)
        print(f"[DEBUG] Model yüklendi. Giriş şekli: {model.input_shape}, Çıkış şekli: {model.output_shape}")
        
        # Eğer model 10 çıkışlıysa (skin_canser_model), özellik çıkarıcı olarak kullan
        if 'skin_canser' in model_name.lower() and model.output_shape[-1] == 10:
            from tensorflow.keras import Model
            from tensorflow.keras.layers import GlobalAveragePooling2D, Dense
            
            # Özellik çıkarıcı olarak son katmandan bir önceki katmanı kullan
            feature_extractor = Model(
                inputs=model.input,
                outputs=model.layers[-2].output
            )
            model_cache[model_name] = feature_extractor
            print("[MODEL] Özellik çıkarıcı olarak ayarlandı")
        else:
            model_cache[model_name] = model
    else:
        print(f"[MODEL CACHE] Kullanılan model (önbellekten): {model_name}")
    
    return model_cache[model_name]

# Sınıf kodları ve Türkçe açıklamaları (HAM10000)
class_info = [
    {"code": "akiec", "name_tr": "Aktinik keratoz ve intraepitelyal karsinom"},
    {"code": "bcc",   "name_tr": "Bazal hücreli karsinom"},
    {"code": "bkl",   "name_tr": "İyi huylu keratoz benzeri lezyonlar"},
    {"code": "df",    "name_tr": "Dermatofibrom"},
    {"code": "nv",    "name_tr": "Melanositik nevüs (ben)"},
    {"code": "mel",   "name_tr": "Melanom"},
    {"code": "vasc",  "name_tr": "Vasküler lezyonlar"}
]

@router.post("/predict")
async def predict(
    request: Request,
    file: UploadFile = File(None),
    model_name: str = Form("skin_canser_model.h5"),
    hair_analysis: HairAnalysisRequest = None
):
    # Log the incoming request method and URL
    logger.info(f"Incoming request: {request.method} {request.url}")
    
    # Log all headers
    logger.info("Request headers:")
    for name, value in request.headers.items():
        logger.info(f"  {name}: {value}")
    
    # Content-Type kontrolü
    content_type = request.headers.get('content-type', '')
    logger.info(f"Content-Type: {content_type}")
    
    # Eğer JSON isteği gelmişse
    if 'application/json' in content_type:
        try:
            json_data = await request.json()
            logger.info("Received JSON data:")
            logger.info(json.dumps(json_data, indent=2, default=str))
            
            # Eğer saç analizi verisi varsa, modeli hair_model.h5 olarak ayarla
            if 'hair_analysis' in json_data:
                model_name = 'hair_model.h5'
                try:
                    # Create the HairAnalysisRequest from the nested data
                    hair_analysis_data = json_data['hair_analysis']
                    logger.info(f"Creating HairAnalysisRequest with data: {hair_analysis_data}")
                    
                    # Ensure all required fields are present and have the correct types
                    hair_analysis = HairAnalysisRequest(
                        stress_level=float(hair_analysis_data.get('stress_level', 0)),
                        body_water_content=float(hair_analysis_data.get('body_water_content', 0)),
                        total_protein=float(hair_analysis_data.get('total_protein', 0)),
                        total_keratine=float(hair_analysis_data.get('total_keratine', 0)),
                        iron=float(hair_analysis_data.get('iron', 0)),
                        calcium=float(hair_analysis_data.get('calcium', 0)),
                        vitamin=float(hair_analysis_data.get('vitamin', 0)),
                        manganese=float(hair_analysis_data.get('manganese', 0)),
                        liver_data=float(hair_analysis_data.get('liver_data', 0)),
                        hair_texture=float(hair_analysis_data.get('hair_texture', 0.5))  # Default to middle value
                    )
                    
                    logger.info(f"Successfully created HairAnalysisRequest: {hair_analysis}")
                    return await handle_hair_analysis(hair_analysis)
                except Exception as e:
                    logger.error(f"Error creating HairAnalysisRequest: {str(e)}")
                    logger.error(f"Input data: {hair_analysis_data}", exc_info=True)
                    raise HTTPException(status_code=400, detail=f"Invalid hair analysis data: {str(e)}")
                
        except Exception as e:
            logger.error(f"Error processing JSON request: {str(e)}")
            raise HTTPException(status_code=400, detail=f"Invalid request: {str(e)}")
    
    # Eğer form-data isteği gelmişse
    logger.info(f"Received form-data - File: {file.filename if file else 'None'}, Model: {model_name}")
    
    # Check if file was provided
    if file is None or file.filename == '':
        if hair_analysis is None:
            raise HTTPException(
                status_code=400,
                detail="No file provided and no hair analysis data found. Please provide either an image or hair analysis data."
            )
        # If no file but we have hair analysis, continue with just the hair analysis
        return await handle_hair_analysis(hair_analysis)
    
    # Read the file content
    try:
        contents = await file.read()
        if not contents:
            raise HTTPException(status_code=400, detail="The file is empty")
            
        # Convert image to base64
        base64_image = base64.b64encode(contents).decode('utf-8')
    except Exception as e:
        raise HTTPException(
            status_code=400,
            detail=f"Error reading the file: {str(e)}"
        )
    
    if model_name == "other_model.h5":
        try:
            from app.services.llm_advice import get_gemini_vision_analysis
            
            logger.info("Gemini API ile görsel analizi başlatılıyor...")
            try:
                gemini_result = await get_gemini_vision_analysis(base64_image)
                
                if not gemini_result:
                    raise ValueError("Boş yanıt alındı")
                    
                logger.info(f"Gemini analiz sonucu: {gemini_result}")
                
                # Güven skorunu sayısal değere çevir
                confidence_map = {"yüksek": 0.9, "orta": 0.7, "düşük": 0.5, "high": 0.9, "medium": 0.7, "low": 0.5}
                confidence_str = str(gemini_result.get("confidence", "")).lower()
                confidence = confidence_map.get(confidence_str, 0.5)
                
                # Tanı metnini temizle
                diagnosis = str(gemini_result.get("diagnosis", "Analiz edilemedi")).strip()
                if not diagnosis or diagnosis.lower() in ["none", "null", ""]:
                    diagnosis = "Tanı belirlenemedi"
                
                return {
                    "class_index": -1,
                    "class_code": "other",
                    "class_name_tr": diagnosis.capitalize(),
                    "confidence": confidence,
                    "llm_result": gemini_result,
                    "analysis_type": "gemini_ai"
                }
                
            except Exception as e:
                logger.error(f"Gemini analiz hatası: {str(e)}", exc_info=True)
                return {
                    "class_index": -1,
                    "class_code": "other",
                    "class_name_tr": "Teknik bir sorun oluştu",
                    "confidence": 0.1,
                    "llm_result": {"error": str(e)},
                    "analysis_type": "error"
                }
            
        except Exception as e:
            logger.error(f"Gemini analiz hatası: {str(e)}", exc_info=True)
            return {
                "class_index": -1,
                "class_code": "error",
                "class_name_tr": "Analiz sırasında hata oluştu",
                "confidence": 0.0,
                "llm_result": {"error": str(e)},
                "analysis_type": "error"
            }
    # Handle hair analysis request
    elif model_name == "hair_model.h5" and hair_analysis is not None:
        try:
            # Prepare feature array in the correct order
            feature_values = [
                hair_analysis.stress_level,
                hair_analysis.body_water_content,
                hair_analysis.total_protein,
                hair_analysis.total_keratine,
                hair_analysis.iron,
                hair_analysis.calcium,
                hair_analysis.vitamin,
                hair_analysis.manganese,
                hair_analysis.liver_data,
                hair_analysis.hair_texture
            ]
            
            # Convert to numpy array with batch dimension
            img_array = np.array([feature_values], dtype=np.float32)
            
            # Get model and predict
            model = get_model(model_name)
            print(f"[PREDICT] Hair analysis with features: {feature_values}")
            
            prediction = model.predict(img_array)
            confidence = float(prediction[0][0] if len(prediction.shape) > 1 else prediction[0])
            class_idx = 1 if confidence > 0.5 else 0
            
            return {
                "class_index": class_idx,
                "class_code": "hair_loss" if class_idx == 1 else "normal",
                "class_name_tr": "Saç Dökülmesi Tespit Edildi" if class_idx == 1 else "Saç Dökülmesi Yok",
                "confidence": confidence if class_idx == 1 else (1 - confidence),
                "analysis_type": "hair_analysis"
            }
            
        except Exception as e:
            logger.error(f"Hair analysis error: {str(e)}", exc_info=True)
            return {
                "class_index": -1,
                "class_code": "error",
                "class_name_tr": "Analiz sırasında hata oluştu",
                "confidence": 0.0,
                "analysis_type": "error"
            }
    
    # Handle image-based prediction for hair analysis with Gemini
    elif model_name == "hair_model.h5" and file is not None:
        try:
            from app.services.llm_advice import get_gemini_vision_analysis
            
            logger.info("Saç analizi için Gemini API ile görsel analizi başlatılıyor...")
            
            # Gemini API'yi çağır
            hair_analysis_prompt = """
            Bu bir saç analizidir. Görseldeki saç durumunu değerlendirin.
            Aşağıdaki bilgileri içeren bir JSON yanıt verin:
            {
                "diagnosis": "Saç durumu teşhisi (örneğin: Saç dökülmesi, Kepek, Saç ucu kırıkları, vb.)",
                "confidence": "yüksek/orta/düşük",
                "description": "Detaylı açıklama",
                "recommendations": ["öneri 1", "öneri 2", "öneri 3"]
            }
            
            Sadece yukarıdaki JSON formatında yanıt verin, başka hiçbir açıklama veya metin eklemeyin.
            """
            
            gemini_result = await get_gemini_vision_analysis(
                base64_image=base64_image,
                prompt=hair_analysis_prompt
            )
            
            if not gemini_result:
                raise ValueError("Gemini'den boş yanıt alındı")
                
            logger.info(f"Gemini saç analiz sonucu: {gemini_result}")
            
            # Güven skorunu sayısala çevir
            confidence_map = {"yüksek": 0.9, "orta": 0.7, "düşük": 0.5, "high": 0.9, "medium": 0.7, "low": 0.5}
            confidence_str = str(gemini_result.get("confidence", "")).lower()
            confidence = confidence_map.get(confidence_str, 0.5)
            
            # Tanı metnini temizle
            diagnosis = str(gemini_result.get("diagnosis", "Analiz edilemedi")).strip()
            if not diagnosis or diagnosis.lower() in ["none", "null", ""]:
                diagnosis = "Saç analizi yapılamadı"
            
            return {
                "class_index": -1,
                "class_code": "hair_analysis",
                "class_name_tr": diagnosis.capitalize(),
                "confidence": confidence,
                "llm_result": gemini_result,
                "analysis_type": "gemini_hair_analysis"
            }
            
        except Exception as e:
            logger.error(f"Saç analizi sırasında hata: {str(e)}", exc_info=True)
            return {
                "class_index": -1,
                "class_code": "error",
                "class_name_tr": "Saç analizi sırasında hata oluştu",
                "confidence": 0.0,
                "llm_result": {"error": str(e)},
                "analysis_type": "error"
            }
    
    # Handle other image-based predictions
    elif file is not None:
        # Load the model first to check its expected input shape
        model = get_model(model_name)
        print(f"[PREDICT] Kullanılan model: {model_name}")
        
        # Check if model expects features (shape=(None, 10)) or image
        if len(model.input_shape) == 2 and model.input_shape[1] == 10:
            # Model expects 10 features, but got an image
            print("[ERROR] Model expects 10 features, but image provided")
            raise HTTPException(status_code=400, detail="This model requires feature inputs, not images")
        else:
            # Handle image input
            image = Image.open(io.BytesIO(contents)).convert('RGB')
            
            # Get target dimensions
            if len(model.input_shape) == 4:  # Shape: (None, height, width, channels)
                target_height, target_width = model.input_shape[1], model.input_shape[2]
            else:  # Handle models with different input shapes
                target_height, target_width = 224, 224  # Default size
                print(f"[WARNING] Unexpected model input shape: {model.input_shape}, using default size {target_height}x{target_width}")
            
            # Resize image to match model's expected input shape
            image = image.resize((target_width, target_height))
            
            # Convert to numpy array and normalize
            img_array = np.asarray(image, dtype=np.float32) / 255.0
            
            # Add batch dimension if needed
            if len(img_array.shape) == 3:  # (H, W, C)
                img_array = np.expand_dims(img_array, axis=0)  # (1, H, W, C)
            elif len(img_array.shape) == 2:  # (H, W)
                img_array = np.expand_dims(img_array, axis=(0, -1))  # (1, H, W, 1)
        
        # Make prediction
        prediction = model.predict(img_array)
        print(f"[DEBUG] Model çıktı şekli: {prediction.shape}")
        
        # Modelin çıktı şekline göre işlem yap
        if len(prediction.shape) == 1 or prediction.shape[1] == 1:
            # Binary classification (hair model)
            confidence = float(prediction[0][0] if len(prediction.shape) > 1 else prediction[0])
            class_idx = 1 if confidence > 0.5 else 0
            
            # For binary classification, we'll use a simplified class info
            binary_class_info = [
                {"code": "normal", "name_tr": "Saç Dökülmesi Yok"},
                {"code": "hair_loss", "name_tr": "Saç Dökülmesi Tespit Edildi"}
            ]
            info = binary_class_info[class_idx]
            confidence = confidence if class_idx == 1 else (1 - confidence)
        elif len(prediction.shape) == 2 and prediction.shape[1] > 1:
            # Multi-class classification (skin cancer model)
            class_idx = int(np.argmax(prediction))
            confidence = float(np.max(prediction))
            info = class_info[class_idx] if class_idx < len(class_info) else {"code": str(class_idx), "name_tr": "Bilinmeyen"}
        else:
            # Özellik vektörü durumu (feature extraction)
            # Burada bir sınıflandırıcı kullanmanız veya başka bir işlem yapmanız gerekebilir
            # Şimdilik sadece debug bilgisi döndürelim
            print("[WARNING] Model özellik vektörü döndürdü, sınıflandırma yapılamadı")
            return {
                "class_index": -1,
                "class_code": "feature_vector",
                "class_name_tr": "Model özellik vektörü döndürdü",
                "confidence": 0.0
            }
        
        return {
            "class_index": class_idx,
            "class_code": info["code"],
            "class_name_tr": info["name_tr"],
            "confidence": confidence
        }
