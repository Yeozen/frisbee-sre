from fastapi import FastAPI, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time
import random

app = FastAPI()

REQUEST_COUNT = Counter(
    "app_requests_total",
    "Total request count",
    ["method", "endpoint", "status"]
)

REQUEST_LATENCY = Histogram(
    "app_request_latency_seconds",
    "Request latency in seconds",
    ["endpoint"]
)

@app.get("/health")
def health():
    REQUEST_COUNT.labels(method="GET", endpoint="/health", status="200").inc()
    return {"status": "ok"}

@app.get("/slow")
def slow():
    start = time.time()
    delay = random.uniform(1, 10)
    time.sleep(delay)
    REQUEST_LATENCY.labels(endpoint="/slow").observe(time.time() - start)
    REQUEST_COUNT.labels(method="GET", endpoint="/slow", status="200").inc()
    return {"status": f"slow response after {delay:.2f}s"}

@app.get("/crash")
def crash():
    REQUEST_COUNT.labels(method="GET", endpoint="/crash", status="500").inc()
    raise Exception("Simulated crash")

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)