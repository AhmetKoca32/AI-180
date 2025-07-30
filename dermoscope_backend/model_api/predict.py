from fastapi import APIRouter, UploadFile, File
from tensorflow.keras.models import load_model
import numpy as np
from PIL import Image
import io

router = APIRouter()

# Modeli yükle (dosya adını güncelleyebilirsin)
model = load_model("model_api/skin_cancer_model.h5")

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
async def predict(file: UploadFile = File(...)):
    contents = await file.read()
    image = Image.open(io.BytesIO(contents)).resize((32, 32))
    img_array = np.asarray(image) / 255.0
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
