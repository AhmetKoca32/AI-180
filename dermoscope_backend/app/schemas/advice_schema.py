# advice_schema.py
from pydantic import BaseModel

class AdviceRequest(BaseModel):
    question: str

class AdviceResponse(BaseModel):
    advice: str
