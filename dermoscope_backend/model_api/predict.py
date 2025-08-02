from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from tensorflow.keras.models import load_model
import numpy as np
from PIL import Image
import io
import os
import base64
import logging

# Logging yapılandırması
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter()

MODEL_PATHS = {
    "skin_canser_model.h5": "model_api/skin_cancer_model.h5",
    "hair_model.h5": "model_api/binary_model.h5",
    "other_model.h5": "model_api/other_model.h5"
}

# Model cache dictionary
model_cache = {}

def get_model(model_name):
    if model_name not in model_cache:
        print(f"[MODEL LOAD] Yüklenen model: {model_name} -> {MODEL_PATHS.get(model_name, MODEL_PATHS['skin_canser_model.h5'])}")
        model_cache[model_name] = load_model(MODEL_PATHS.get(model_name, MODEL_PATHS["skin_canser_model.h5"]))
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
    file: UploadFile = File(...),
    model_name: str = Form("skin_canser_model.h5")
):
    contents = await file.read()
    
    # Görseli base64'e çevir
    base64_image = base64.b64encode(contents).decode('utf-8')
    
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
    else:
        image = Image.open(io.BytesIO(contents)).resize((32, 32))
        img_array = np.asarray(image) / 255.0
        img_array = np.expand_dims(img_array, axis=0)
        model = get_model(model_name)
        print(f"[PREDICT] Kullanılan model: {model_name}")
        prediction = model.predict(img_array)
        class_idx = int(np.argmax(prediction))
        confidence = float(np.max(prediction))
        info = class_info[class_idx] if class_idx < len(class_info) else {"code": str(class_idx), "name_tr": "Bilinmeyen"}
        return {
            "class_index": class_idx,
            "class_code": info["code"],
            "class_name_tr": info["name_tr"],
            "confidence": confidence
        }
    img_array = np.expand_dims(img_array, axis=0)  # (1, 32, 32, 3)
    prediction = model.predict(img_array)
    class_idx = int(np.argmax(prediction))
    confidence = float(np.max(prediction))
    info = class_info[class_idx] if class_idx < len(class_info) else {"code": str(class_idx), "name_tr": "Bilinmeyen"}
    return {
        "class_index": class_idx,
        "class_code": info["code"],
        "class_name_tr": info["name_tr"],
        "confidence": confidence
    }
