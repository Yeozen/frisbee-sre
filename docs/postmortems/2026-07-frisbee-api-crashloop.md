## Incident 4 — frisbee-api CrashLoopBackOff on EC2 (t3.micro)

**Symptoms:** frisbee-api pods restarting repeatedly on EC2, 
restart count climbing to 16+. No error in logs — clean exit 
code 0 with graceful shutdown message.

**Discovery:** kubectl describe pod showed Last State: Terminated, 
Reason: Completed, Exit Code: 0 — indicating clean shutdown rather 
than crash. top showed 23% CPU wait (wa) and 7.2% steal time (st).

**Root cause:** t3.micro (1GB RAM) insufficient for full stack. 
Total workload memory (~1GB) exceeded physical RAM, causing heavy 
swap usage. Swap on EBS disk introduced IO wait, making CPU 
unavailable. frisbee-api responded slowly to liveness probe GET 
/health due to page faults from swapped-out memory. After 3 
consecutive probe timeouts (failureThreshold: 3), Kubernetes sent 
SIGTERM. uvicorn shut down cleanly. Cycle repeated.

**Fix:** Upgraded EC2 instance from t3.micro to t3.small (2GB RAM) 
via Terraform. Updated instance_type in main.tf and ran terraform 
apply. All workloads now fit in physical RAM, no swapping occurs, 
liveness probes pass consistently.

**Lesson:** Liveness probe failures don't always mean the app is 
broken — they can indicate resource starvation at the infrastructure 
level. Always check CPU wait (wa in top) and steal time (st) 
alongside application logs when diagnosing pod restarts on cloud 
instances. Exit code 0 with clean shutdown is a strong signal that 
Kubernetes killed the pod intentionally rather than the app crashing.

**Commands used:**
kubectl describe pod <pod> | grep -A 10 "Last State"
kubectl logs -l app=frisbee-api --previous
top (looked for wa and st columns)
free -h (confirmed swap exhaustion)