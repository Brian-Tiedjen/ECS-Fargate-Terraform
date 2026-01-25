import os

from fastapi import FastAPI
app = FastAPI()

APP_VERSION = os.getenv("APP_VERSION", "local")

@app.get("/")
def root():
    return {
        "version": APP_VERSION
    }

@app.get("/version")
def version():
    return {
        "version": APP_VERSION
    }

@app.get("/health")
def health():
    return {"status": "ok"}
