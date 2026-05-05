from fastapi import FastAPI
import time

app = FastAPI()

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/slow")
def slow():
    time.sleep(5)
    return {"status": "slow response"}

@app.get("/crash")
def crash():
    raise Exception("Simulated crash")