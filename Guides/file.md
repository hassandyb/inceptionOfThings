Perfect! Let's build this **step by step** and **understand every piece**. No copy-paste - we'll construct it line by line with tests!

---

## **🎯 Part 1: Understanding What We Need**

We need 2 Kubernetes resources:
1. **Deployment** - Runs our application
2. **Service** - Exposes the application

Let's build them **incrementally** and test each addition!

---

## **📝 Step 1: Create Empty File**

```bash
cd ~/Desktop/inceptionOfThings/iot/p3/iot-hed-dyb/manifests
nano application.yaml
```

**Start with absolutely nothing - empty file!**

**Save (Ctrl+O, Enter, Ctrl+X)**

---

## **🧪 Step 2: Add Minimal Deployment**

Let's start with the **smallest possible deployment**:

````yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wil
spec:
  selector:
    matchLabels:
      app: wil
  template:
    metadata:
      labels:
        app: wil
    spec:
      containers:
      - name: wil
        image: wil42/playground:v1
````

**What each line means:**
- `apiVersion: apps/v1` - Kubernetes API version for Deployments
- `kind: Deployment` - We're creating a Deployment (not Pod, Service, etc.)
- `metadata.name: wil` - Name of this deployment
- `selector.matchLabels` - How deployment finds its pods
- `template` - The pod template to create
- `containers` - List of containers in the pod
- `image` - Docker image to run

**Save**

---

## **🧪 Test 1: Apply Minimal Deployment**

```bash
kubectl apply -f application.yaml
```

**Expected:**
```
deployment.apps/wil created
```

---

**Check deployment:**

```bash
kubectl get deployment
```

**Expected:**
```
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
wil    0/1     1            0           5s
```

**Problem: `READY 0/1` - Pod isn't ready! Why?**

---

**Check pods:**

```bash
kubectl get pods
```

**Expected:**
```
NAME                   READY   STATUS    RESTARTS   AGE
wil-xxxxxxxxxx-xxxxx   0/1     Pending   0          10s
```

**Status: `Pending` - Why? No namespace specified!**

---

## **🔧 Step 3: Add Namespace**

**Delete what we created:**

```bash
kubectl delete -f application.yaml
```

**Edit file:**

````yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wil
  namespace: dev  # ← ADD THIS
spec:
  selector:
    matchLabels:
      app: wil
  template:
    metadata:
      labels:
        app: wil
    spec:
      containers:
      - name: wil
        image: wil42/playground:v1
````

**Save**

---

## **🧪 Test 2: Apply with Namespace**

```bash
kubectl apply -f application.yaml
```

**Expected:**
```
deployment.apps/wil created
```

---

**Check in dev namespace:**

```bash
kubectl get pods -n dev
```

**Expected:**
```
NAME                   READY   STATUS              RESTARTS   AGE
wil-xxxxxxxxxx-xxxxx   0/1     ContainerCreating   0          5s
```

**Wait 10 seconds:**

```bash
kubectl get pods -n dev
```

**Expected:**
```
NAME                   READY   STATUS    RESTARTS   AGE
wil-xxxxxxxxxx-xxxxx   1/1     Running   0          15s
```

✅ **Pod is running! But we can't access it yet...**

---

## **🧪 Test 3: Try to Access Pod**

**Get pod name:**

```bash
POD_NAME=$(kubectl get pods -n dev -o jsonpath='{.items[0].metadata.name}')
echo $POD_NAME
```

**Try port-forward directly to pod:**

```bash
kubectl port-forward $POD_NAME -n dev 8888:8888
```

**Expected:**
```
Forwarding from 127.0.0.1:8888 -> 8888
```

**Keep this running, open new terminal:**

```bash
curl http://localhost:8888
```

**Expected:**
```json
{"status":"ok", "message": "v1"}
```

✅ **Pod works! But port-forwarding to pod is not ideal...**

**Stop port-forward (Ctrl+C)**

---

## **💡 Why We Need a Service:**

**Problem:** If pod restarts, its name changes!
- Old: `wil-abc123-xyz789`
- New: `wil-def456-uvw012`

**Solution:** Service provides a **stable endpoint** that routes to pods with matching labels!

---

## **🔧 Step 4: Add Labels (Best Practice)**

Before adding Service, let's add more labels for organization:

````yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wil
  namespace: dev
  labels:          # ← ADD LABELS
    app: wil
spec:
  selector:
    matchLabels:
      app: wil
  template:
    metadata:
      labels:
        app: wil
    spec:
      containers:
      - name: wil
        image: wil42/playground:v1
````

**What changed:**
- Added `labels` under `metadata` - labels for the Deployment itself

**Apply update:**

```bash
kubectl apply -f application.yaml
```

**Expected:**
```
deployment.apps/wil configured
```

**Check deployment labels:**

```bash
kubectl get deployment wil -n dev --show-labels
```

**Expected:**
```
NAME   READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
wil    1/1     1            1           2m    app=wil
```

✅ **Labels added!**

---

## **🔧 Step 5: Add Container Port**

Let's explicitly declare the port:

````yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wil
  namespace: dev
  labels:
    app: wil
spec:
  selector:
    matchLabels:
      app: wil
  template:
    metadata:
      labels:
        app: wil
    spec:
      containers:
      - name: wil
        image: wil42/playground:v1
        ports:                    # ← ADD PORTS
        - containerPort: 8888
````

**What this means:**
- `containerPort: 8888` - Container listens on port 8888

**Apply:**

```bash
kubectl apply -f application.yaml
```

**Verify pod still works:**

```bash
kubectl get pods -n dev
```

**Expected:**
```
NAME                   READY   STATUS    RESTARTS   AGE
wil-xxxxxxxxxx-xxxxx   1/1     Running   0          30s
```

✅ **Port declared!**

---

## **🧪 Test 4: Verify Port in Pod Spec**

```bash
kubectl get pod -n dev -o yaml | grep containerPort
```

**Expected:**
```yaml
    - containerPort: 8888
      protocol: TCP
```

✅ **Port is now documented in pod spec!**

---

## **📋 Current State Summary**

**What we have:**
- ✅ Deployment named `wil`
- ✅ In namespace `dev`
- ✅ With labels `app=wil`
- ✅ Running image `wil42/playground:v1`
- ✅ Container listens on port 8888

**What we're missing:**
- ❌ Service to expose the deployment
- ❌ Stable endpoint to access the app

---

## **🚀 Step 6: Add Service (Minimal)**

**Add separator and minimal service:**

````yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wil
  namespace: dev
  labels:
    app: wil
spec:
  selector:
    matchLabels:
      app: wil
  template:
    metadata:
      labels:
        app: wil
    spec:
      containers:
      - name: wil
        image: wil42/playground:v1
        ports:
        - containerPort: 8888

---                          # ← YAML DOCUMENT SEPARATOR

apiVersion: v1
kind: Service
metadata:
  name: svc-wil
  namespace: dev
spec:
  selector:
    app: wil
  ports:
    - port: 8080
      targetPort: 8888
````

**What this means:**
- `---` - Separator between multiple YAML documents
- `kind: Service` - Creating a Service
- `selector.app: wil` - Route traffic to pods with label `app=wil`
- `port: 8080` - Service exposes on port 8080
- `targetPort: 8888` - Forward to container port 8888

**Save**

---

## **🧪 Test 5: Apply Service**

```bash
kubectl apply -f application.yaml
```

**Expected:**
```
deployment.apps/wil unchanged
service/svc-wil created
```

---

**Check service:**

```bash
kubectl get service -n dev
```

**Expected:**
```
NAME      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
svc-wil   ClusterIP   10.43.123.456   <none>        8080/TCP   5s
```

**Key info:**
- `TYPE: ClusterIP` - Internal cluster IP (not external)
- `PORT(S): 8080/TCP` - Service listens on 8080
- `CLUSTER-IP: 10.43.x.x` - Internal IP address

---

## **🧪 Test 6: Access via Service**

**Port-forward to service (not pod!):**

```bash
kubectl port-forward svc/svc-wil -n dev 8888:8080
```

**What this means:**
- `svc/svc-wil` - Forward to Service (not pod)
- `8888:8080` - Local 8888 → Service 8080 → Pod 8888

**Keep running, open new terminal:**

```bash
curl http://localhost:8888
```

**Expected:**
```json
{"status":"ok", "message": "v1"}
```

✅ **Accessing via Service works!**

---

## **🧪 Test 7: Delete Pod, Service Still Works**

**Get current pod name:**

```bash
kubectl get pods -n dev
```

**Expected:**
```
NAME                   READY   STATUS    RESTARTS   AGE
wil-abc123-xyz789      1/1     Running   0          5m
```

---

**Delete the pod:**

```bash
kubectl delete pod -l app=wil -n dev
```

**Expected:**
```
pod "wil-abc123-xyz789" deleted
```

---

**Immediately check pods:**

```bash
kubectl get pods -n dev
```

**Expected:**
```
NAME                   READY   STATUS              RESTARTS   AGE
wil-def456-uvw012      0/1     ContainerCreating   0          2s
```

**Deployment automatically created new pod!**

---

**Test service still works:**

```bash
curl http://localhost:8888
```

**Expected:**
```json
{"status":"ok", "message": "v1"}
```

✅ **Service routes to new pod automatically!**

---

## **🔧 Step 7: Add Protocol (Best Practice)**

Let's be explicit about TCP:

````yaml
apiVersion: v1
kind: Service
metadata:
  name: svc-wil
  namespace: dev
spec:
  selector:
    app: wil
  ports:
    - protocol: TCP      # ← ADD THIS
      port: 8080
      targetPort: 8888
````

**Apply:**

```bash
kubectl apply -f application.yaml
```

**Expected:**
```
deployment.apps/wil unchanged
service/svc-wil configured
```

---

## **📊 Final File Structure**

**Your final application.yaml:**

````yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wil
  namespace: dev
  labels:
    app: wil
spec:
  selector:
    matchLabels:
      app: wil
  template:
    metadata:
      labels:
        app: wil
    spec:
      containers:
      - name: wil
        image: wil42/playground:v1
        ports:
        - containerPort: 8888

---

apiVersion: v1
kind: Service
metadata:
  name: svc-wil
  namespace: dev
spec:
  selector:
    app: wil
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8888
````

---

## **🎓 Understanding Questions**

### **Q1: Why do we need both Deployment AND Service?**

**Deployment:**
- Creates and manages pods
- Ensures desired number of replicas
- Handles rolling updates
- Restarts failed pods

**Service:**
- Provides stable endpoint
- Load balances between pods
- Survives pod restarts
- Enables pod-to-pod communication

**Analogy:**
- Deployment = Factory that makes workers
- Service = Reception desk that directs customers to workers

---

### **Q2: What happens if I change the image?**

**Test it:**

1. **Edit file:**
   ```yaml
   image: wil42/playground:v2  # ← Change to v2
   ```

2. **Apply:**
   ```bash
   kubectl apply -f application.yaml
   ```

3. **Watch pod recreation:**
   ```bash
   kubectl get pods -n dev -w
   ```

4. **Test new version:**
   ```bash
   curl http://localhost:8888
   ```
   **Expected:** `{"status":"ok", "message": "v2"}`

---

### **Q3: What if I delete the Service?**

```bash
kubectl delete service svc-wil -n dev
```

**Result:**
- Pods still running ✅
- Can't access via service name ❌
- Can still port-forward to pod ✅

**Recreate:**
```bash
kubectl apply -f application.yaml
```

---

### **Q4: Port Mapping Flow**

```
Your Machine
    ↓
localhost:8888 (kubectl port-forward)
    ↓
Service Port: 8080
    ↓
Target Port: 8888 (pod container port)
    ↓
Application running inside container
```

---

## **🧪 Final Verification Tests**

```bash
# 1. Check deployment
kubectl get deployment wil -n dev
```
**Expected:** 1/1 Ready

```bash
# 2. Check service
kubectl get service svc-wil -n dev
```
**Expected:** ClusterIP, 8080/TCP

```bash
# 3. Check pod
kubectl get pods -n dev
```
**Expected:** 1/1 Running

```bash
# 4. Check endpoints (service → pod mapping)
kubectl get endpoints svc-wil -n dev
```
**Expected:** One pod IP:8888

```bash
# 5. Test access
curl http://localhost:8888
```
**Expected:** `{"status":"ok", "message": "v1"}`

---

## **✅ What You Built & Understand**

- [x] Created Deployment from scratch
- [x] Added namespace for organization
- [x] Added labels for selection
- [x] Declared container port
- [x] Created Service to expose deployment
- [x] Understood port mapping (8080 → 8888)
- [x] Tested pod recreation
- [x] Tested service routing

---

**Ready to push to GitHub and let Argo CD manage it?** 🚀