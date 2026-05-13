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