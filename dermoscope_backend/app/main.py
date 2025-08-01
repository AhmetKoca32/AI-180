from fastapi import FastAPI
from model_api import predict
from app.routers import advice

app = FastAPI()

# Ana API router'ları buraya eklenebilir
app.include_router(predict.router, prefix="/model_api")
app.include_router(advice.router) 
