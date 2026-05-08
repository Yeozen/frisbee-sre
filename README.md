# frisbee-sre
SRE portfolio project - observability, failure simulation, Kubernetes


# 🧭 High-Level Architecture

```
[ Client / curl / Postman ]
            ↓
     [ FastAPI Service ]
            ↓
     [ Redis (optional) ]
            ↓
-------------------------------
|        Kubernetes Cluster    |
|  - Deployment (App)          |
|  - Service (ClusterIP)       |
|  - HPA (optional later)      |
-------------------------------
            ↓
     [ Prometheus ]
            ↓
     [ Grafana ]
            ↓
     [ Alertmanager ]
            ↓
     [ Email / Webhook Alert ]
```

---

# 🔧 Core Components (What + Why)

## 1. **FastAPI Service (Python)**

### Why:

* Lightweight
* Fast to build
* Easy to instrument with metrics

### Endpoints:

* `/health` → health check
* `/match` → create match
* `/score` → update score
* `/stats` → get stats

### 🔥 Failure endpoints (VERY IMPORTANT):

* `/slow` → adds artificial delay
* `/crash` → raises exception
* `/memory` → simulate memory leak (optional)

---

## 2. **Docker**

### You will:

* Write a clean `Dockerfile`
* Use slim Python image
* Add proper logging

---

## 3. **Kubernetes**

### Resources:

* **Deployment**

  * 2–3 replicas
* **Service**

  * ClusterIP (NodePort optional)

### You will demonstrate:

* Pod restarts
* Scaling
* Self-healing

---

## 4. **Prometheus (Metrics Collection)**

### Collect:

* CPU / Memory (node exporter or kube metrics)
* HTTP requests
* Latency
* Error rates

👉 Use Python Prometheus client

---

## 5. **Grafana (Visualization)**

### Dashboards:

* Request rate
* Error rate
* Latency (p95 if possible)
* Pod restarts

---

## 6. **Alertmanager**

### Alerts:

* High CPU usage
* High error rate
* Pod crash loop

👉 Even simple alerting is enough

---

## 7. **AWS (Later Phase)**

### Minimal setup:

* EC2 instance
* Run k3s or lightweight K8s

---

## 8. **Terraform**

### Manage:

* EC2 instance
* Security groups

---

## 9. **CI/CD (GitHub Actions)**

### Pipeline:

1. Build Docker image
2. Push to Docker Hub
3. Deploy to K8s (kubectl apply)

---

# 🔄 System Flow (What Happens Step-by-Step)

## 🟢 Normal Flow

1. User sends request (`/score`)
2. FastAPI processes it
3. Logs + metrics generated
4. Prometheus scrapes metrics
5. Grafana visualizes them

---

## 🔴 Failure Scenario (This is what matters)

### Example: `/crash`

1. Request hits API
2. App throws error
3. Error rate spikes
4. Prometheus detects anomaly
5. Alertmanager triggers alert
6. Pod may restart (K8s self-healing)
7. You debug via:

   * `kubectl logs`
   * Grafana dashboards



```
frisbee-sre-project/
│
├── app/
│   ├── main.py
│   ├── routes/
│   └── metrics.py
│
├── docker/
│   └── Dockerfile
│
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── prometheus/
│
├── terraform/
│   └── main.tf
│
├── .github/workflows/
│   └── ci-cd.yaml
│
├── README.md
└── architecture.png
```


5/5
Git push issue asking for auth despite me already setting up the ssh key
Turns out I set the remote option as https instead of the ssh access, changed via the git remote set-url origin command 

6/5
learnt more about kubernetes, deployment.yaml file is to tell kubernetes what you expect it to constantly achieve for you, like a contract
specified 2 replicas of my frisbee-api image so means that there will always be 2 pods of my frisbee-api running
destroyed/deleted one and ran get pods command, saw that one pod's age was starting from 3s meaning kubernetes successfully deleted and recreated a pod automatically based on the deployment specs, pretty cool

8/5
Learnt more about kubernetes and how it interacts with docker, kubernetes is like the conductor of an orchestra and docker is the musicians but it doesn't
have to be docker, as long its something that can run container instances and communicate via the container runtime interface, kubernetes can work with it,
added liveness probes as well as resource specifications (CPU/RAM), liveness probes are kubernetes way of checking pod uptime by probing it with requests and if it doesn't respond based on the faillureThreshold, it will restart the pod. Resource specs are defined by a request and limit, where request is the guaranteed value the app gets but limit is the absolute maximum, if it exceeds these values it will restart/throttle the pod based on the value exceeded

