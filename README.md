# Frisbee SRE — Observability & Reliability Project

A production-grade observability lab demonstrating failure detection, 
incident response, and system recovery using a match-tracking service 
as the workload.

## Architecture

[paste your architecture here — even a simple text diagram is fine]

App (FastAPI) → Kubernetes (2 replicas) → Prometheus (scrapes /metrics 
every 15s) → Grafana (visualises request rate, error rate, p95 latency)

## Stack
- FastAPI — application layer
- Docker — containerisation
- Kubernetes — orchestration and self-healing
- Prometheus — metrics collection and storage
- Grafana — visualisation

## Dashboards
[insert your Grafana screenshot here]

---

## Incident Walkthrough

### Incident 1 — OOMKilled: Grafana pod crash loop

**Symptoms**
Grafana pod restarting repeatedly shortly after deployment.

**Discovery**
← how did you first notice it? what command did you run?

**Diagnosis**
← what did kubectl get pods show? what did OOMKilled tell you?

**Root cause**
← why did it happen? explain in your own words.

**Fix**
← what did you change in the deployment file and why?

**Result**
← what happened after you applied the fix?

**Lesson learned**
Always set memory limits conservatively on first deployment and 
adjust based on observed usage. Grafana's initialisation spike 
exceeds its steady-state memory consumption significantly.

---

### Incident 2 — High latency detection via Grafana

**Symptoms**
p95 latency panel showing values between 9-10 seconds on the 
/slow endpoint.

**Discovery
← how did you spot it? what were you looking at?

**Diagnosis**
← what did the Grafana panel tell you? what metric revealed it?

**Root cause**
← what was causing the latency? explain what the /slow endpoint does.

**What you would do in production**
← if this were a real system, what would your next steps be?
← how would you find which part of the code was slow?

---

### Incident 3 — Pod self-healing demonstration

**Symptoms**
One pod manually deleted to simulate a node failure.

**Discovery**
Monitored via kubectl get pods -w

**What happened**
← describe what you saw when you deleted the pod. 
← how long did it take to recover?
← what does this tell you about Kubernetes?

---

## Key SRE Concepts Demonstrated

- **Reconciliation loop** — ← explain in one sentence
- **OOMKilled** — ← explain in one sentence  
- **p95 latency** — ← explain in one sentence
- **Liveness probe** — ← explain in one sentence
- **PersistentVolumeClaim** — ← explain in one sentence

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

11/5
grafana kept crashing on initialization due to OOMkilled, 256Mi limit too small for it, increased to 512Mi
## Incident 1 — Grafana OOMKilled

Symptoms: Grafana pod restarting repeatedly, kubectl get pods showing OOMKilled
Diagnosis: Memory limit of 256Mi too low for Grafana initialisation spike
Fix: Increased memory request to 256Mi, limit to 512Mi in deployment.yaml
Applied: kubectl apply -f k8s/grafana/deployment.yaml
Result: Pod stabilised, no further restarts

Lesson: Always check OOMKilled first when pods restart unexpectedly.
Command that revealed it: kubectl get pods

12/5
setting up grafana visualizations, wtf my metrics endpoint shows /health has like 8000+ requests but /slow and /crash have like 1 or 2 only cos i manually
used them, probs due to the liveness probes on the main deployment