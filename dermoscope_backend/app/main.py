from fastapi import FastAPI
from model_api import predict

app = FastAPI()

# Ana API router'ları buraya eklenebilir
app.include_router(predict.router, prefix="/model_api")
