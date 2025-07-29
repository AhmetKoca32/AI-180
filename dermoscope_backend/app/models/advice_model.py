# advice_model.py
from sqlalchemy import Column, Integer, String, ForeignKey
from ..database.base import Base

class Advice(Base):
    __tablename__ = "advices"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    advice = Column(String)
