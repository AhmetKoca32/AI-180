# llm_advice.py
# OpenAI ile öneri üretimi

import requests
from app.core.config import settings

def get_llm_advice(question: str):
    import requests
    from app.core.config import settings

    api_key = settings.GEMINI_API_KEY
    url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
    headers = {
        "Content-Type": "application/json",
        "X-goog-api-key": api_key
    }
    data = {
        "contents": [
            {"parts": [{"text": question}]}
        ]
    }
    try:
        response = requests.post(url, headers=headers, json=data, timeout=10)
        response.raise_for_status()
        result = response.json()
        return result["candidates"][0]["content"]["parts"][0]["text"]
    except Exception as e:
        return f"LLM API hatası: {e}"