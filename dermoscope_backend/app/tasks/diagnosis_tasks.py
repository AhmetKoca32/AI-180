# diagnosis_tasks.py
# Asenkron görevler (örn. Celery)

def async_diagnosis_task(image_url: str, user_id: int):
    # TODO: Asenkron tanı işlemi
    return {"result": "eczema", "confidence": 0.90}
