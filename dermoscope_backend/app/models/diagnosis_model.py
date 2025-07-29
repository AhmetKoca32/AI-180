# diagnosis_model.py
from sqlalchemy import Column, Integer, String, Float, ForeignKey
from ..database.base import Base

class Diagnosis(Base):
    __tablename__ = "diagnoses"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    image_url = Column(String)
    result = Column(String)
    confidence = Column(Float)
