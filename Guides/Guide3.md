# 🚀 PART 2: K3s with Three Web Applications - **LEARNING-FOCUSED** Implementation Guide

**Philosophy:** Build everything step-by-step, understand WHY, test immediately, fix errors, learn from output.

---

## **🎓 What You'll Learn**

```
✅ Kubernetes Deployments - How to run containers
✅ Kubernetes Services - How to expose apps internally
✅ Kubernetes Ingress - How to route external traffic
✅ K3s Architecture - Lightweight Kubernetes
✅ Traefik - Ingress controller built into K3s
✅ Volume Mounts - Share files between host and container
✅ Load Balancing - How traffic spreads across replicas
✅ Hostname-based Routing - Virtual hosts in Kubernetes
```

---

## **📚 Prerequisites - What You Should Know**

Before starting, understand:

### **Vagrant Basics (from Part 1)**
- `vagrant up` = Create and start VM
- `vagrant ssh` = Connect to VM
- `vagrant destroy` = Delete VM
- Vagrantfile = Configuration file

### **Basic Kubernetes Concepts**
- **Pod** = Smallest unit, runs 1+ containers
- **Deployment** = Manages pods (how many, which image)
- **Service** = Internal load balancer for pods
- **Ingress** = External access rules (like nginx virtual hosts)

### **What is K3s?**
- Lightweight Kubernetes (uses 512MB RAM vs 4GB for full K8s)
- Perfect for learning and edge devices
- Includes Traefik ingress controller built-in
- Single binary installation

---

## **🏗️ Architecture We're Building**

```
┌─────────────────────────────────────────────────────┐
│                  Your Computer                       │
│  Browser → http://app1.com (192.168.56.110)         │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│             VM: hed-dybS (192.168.56.110)           │
│                                                      │
│  ┌──────────────────────────────────────────────┐  │
│  │         Traefik Ingress Controller           │  │
│  │  (Reads Host header and routes traffic)      │  │
│  └────┬────────────┬────────────┬────────────┬──┘  │
│       │            │            │            │     │
│   Host:        Host:       Host:       No Host     │
│   app1.com     app2.com    app3.com    (default)   │
│       │            │            │            │     │
│       ▼            ▼            ▼            ▼     │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│  │ Service │ │ Service │ │ Service │ │ Service │ │
│  │  app1   │ │  app2   │ │  app3   │ │  app3   │ │
│  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ │
│       │           │            │            │     │
│       ▼           ▼            ▼            ▼     │
│  ┌────────┐ ┌────────────────────┐    ┌────────┐ │
│  │  Pod   │ │  Pod   Pod   Pod   │    │  Pod   │ │
│  │  App1  │ │  App2  App2  App2  │    │  App3  │ │
│  │(nginx) │ │(nginx)(nginx)(nginx)│    │(nginx) │ │
│  └────────┘ └────────────────────┘    └────────┘ │
│      1          3 Replicas                 1      │
│    replica                               replica   │
└─────────────────────────────────────────────────────┘
```

---

## **Phase 0: Understanding the Task**

### **What the Subject Asks**

Read this carefully:

> "You will set up 3 web applications that will run in your K3s instance. You will have to be able to access them depending on the HOST used when making a request to the IP address 192.168.56.110"

**Translation:**
- **Same IP** (192.168.56.110) for all apps
- **Different HOST header** determines which app you see
- **Virtual hosting** - like Apache/Nginx virtual hosts

### **Example:**

```bash
# Same IP, different Host header:
curl -H "Host: app1.com" http://192.168.56.110  # → Shows App1
curl -H "Host: app2.com" http://192.168.56.110  # → Shows App2
curl http://192.168.56.110                      # → Shows App3 (default)
```

### **Key Requirement:**

> "Application number 2 has 3 replicas"

**Why replicas?**
- **High availability** - If 1 pod dies, 2 others still work
- **Load balancing** - Traffic spreads across 3 pods
- **Real-world scenario** - Production apps always have multiple replicas

---

## **Phase 1: Create Project Structure and Understand Each Part**

### **Step 1.1: Create Directory Structure**

```bash
cd ~/Desktop/inceptionOfThings/iot
mkdir -p p2/{scripts,confs,apps/{app1,app2,app3}}
cd p2
```

**Verify:**
```bash
tree
```

**Expected output:**
```
p2/
├── scripts/       ← Provisioning scripts (server setup)
├── confs/         ← Kubernetes YAML files
└── apps/          ← HTML files for each app
    ├── app1/
    ├── app2/
    └── app3/
```

### **❓ Why This Structure?**

- **`scripts/`** = Bash scripts that run when VM starts (provisioning)
- **`confs/`** = Kubernetes manifests (deployments, services, ingress)
- **`apps/`** = Actual application content (HTML files)
- **Separation of concerns** = Configuration ≠ Code ≠ Scripts

---

## **Phase 2: Create Applications (HTML Pages)**

### **Step 2.1: Create App1 HTML**

```bash
nano apps/app1/index.html
```

**Type this (don't copy-paste yet! Type it to learn HTML structure):**

```html
<!DOCTYPE html>
<html>
<head>
    <title>App 1</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            text-align: center;
            background: rgba(255, 255, 255, 0.1);
            padding: 50px;
            border-radius: 20px;
        }
        h1 {
            font-size: 4em;
            margin: 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎯 App 1</h1>
        <p>Welcome to Application One!</p>
        <p>Host: app1.com</p>
    </div>
</body>
</html>
```

**Save:** Ctrl+O, Enter, Ctrl+X

### **🧪 TEST: Verify File Creation**

```bash
cat apps/app1/index.html
```

**Should show your HTML.**

### **❓ Understanding What We Built**

- **HTML file** = What nginx will serve
- **Gradient background** = Makes it visually distinct (purple/blue)
- **`Host: app1.com`** = Shows which app this is (helpful for testing)

---

### **Step 2.2: Create App2 HTML (with Replica Info)**

```bash
nano apps/app2/index.html
```

```html
<!DOCTYPE html>
<html>
<head>
    <title>App 2</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            text-align: center;
            background: rgba(255, 255, 255, 0.1);
            padding: 50px;
            border-radius: 20px;
        }
        h1 {
            font-size: 4em;
        }
        .badge {
            background: rgba(255, 255, 255, 0.3);
            padding: 10px 20px;
            border-radius: 25px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 App 2</h1>
        <p>Welcome to Application Two!</p>
        <p>Host: app2.com</p>
        <div class="badge">⚡ 3 Replicas Running</div>
    </div>
</body>
</html>
```

**Save it.**

### **🧪 TEST:**

```bash
cat apps/app2/index.html | grep -i replica
```

**Should show:** `<div class="badge">⚡ 3 Replicas Running</div>`

### **❓ Why Mention Replicas?**

- **Visual confirmation** - When you test, you'll know it's App2
- **Shows understanding** - Demonstrates you know about replicas
- **Useful for evaluation** - Evaluator sees you're aware of the architecture

---

### **Step 2.3: Create App3 HTML (Default App)**

```bash
nano apps/app3/index.html
```

```html
<!DOCTYPE html>
<html>
<head>
    <title>App 3</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            text-align: center;
            background: rgba(255, 255, 255, 0.1);
            padding: 50px;
            border-radius: 20px;
        }
        h1 {
            font-size: 4em;
        }
        .badge {
            background: rgba(255, 255, 255, 0.3);
            padding: 10px 20px;
            border-radius: 25px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏠 App 3</h1>
        <p>Default Application</p>
        <div class="badge">⭐ Fallback Route</div>
    </div>
</body>
</html>
```

**Save it.**

### **🧪 TEST: Verify All Apps**

```bash
ls -lh apps/*/index.html
```

**Expected:**
```
-rw-r--r-- apps/app1/index.html
-rw-r--r-- apps/app2/index.html
-rw-r--r-- apps/app3/index.html
```

### **✅ Checkpoint: Apps Created**

You now have 3 HTML pages. In a real project, these would be full applications (React, Vue, etc.), but for learning, simple HTML is perfect.

---

## **Phase 3: Understanding Kubernetes Deployments**

### **📚 Theory: What is a Deployment?**

**Deployment** tells Kubernetes:
1. **Which image to run** (nginx, apache, custom app)
2. **How many copies** (replicas)
3. **What resources to mount** (volumes, configs)

**Example real-world scenario:**
```
Deployment: "Run 3 copies of nginx serving my website"
Kubernetes: "OK, creating 3 pods with nginx"
```

### **Step 3.1: Create deployment.yaml - Start with App1**

```bash
nano confs/deployment.yaml
```

**Type this SLOWLY, understanding each line:**

```yaml
# ============================================
# APP 1 - Deployment
# ============================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1-deployment
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app1
  template:
    metadata:
      labels:
        app: app1
    spec:
      containers:
      - name: app1
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        hostPath:
          path: /vagrant/apps/app1
          type: Directory
```

**DON'T save yet! Let's understand each section:**

---

### **📖 Line-by-Line Explanation**

```yaml
apiVersion: apps/v1
```
**What:** API version for Deployments  
**Why:** Kubernetes has many APIs, this specifies which one

```yaml
kind: Deployment
```
**What:** Type of resource  
**Why:** Could be Service, Pod, ConfigMap, etc. - this is a Deployment

```yaml
metadata:
  name: app1-deployment
  namespace: default
```
**What:** Name and namespace  
**Why:** 
- `name` = How you reference this deployment (`kubectl get deployment app1-deployment`)
- `namespace` = Logical grouping (default = main namespace)

```yaml
spec:
  replicas: 1
```
**What:** Number of pod copies  
**Why:** `1` = single instance, `3` = three instances (we'll use 3 for App2)

```yaml
  selector:
    matchLabels:
      app: app1
```
**What:** How Deployment finds its pods  
**Why:** Deployment looks for pods with label `app: app1`

```yaml
  template:
    metadata:
      labels:
        app: app1
```
**What:** Labels applied to pods  
**Why:** Must match selector above (this is how they connect)

```yaml
    spec:
      containers:
      - name: app1
        image: nginx:alpine
```
**What:** Container specification  
**Why:** 
- `name` = Container name (can be anything)
- `image` = Docker image to use (`nginx:alpine` = lightweight web server)

```yaml
        ports:
        - containerPort: 80
```
**What:** Which port the container listens on  
**Why:** Nginx serves HTTP on port 80

```yaml
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
```
**What:** Mount a volume inside the container  
**Why:**
- `name: html` = References volume defined below
- `mountPath` = Where nginx looks for files (default HTML directory)

```yaml
      volumes:
      - name: html
        hostPath:
          path: /vagrant/apps/app1
          type: Directory
```
**What:** Volume source  
**Why:**
- `hostPath` = Use a directory from the VM's filesystem
- `/vagrant/apps/app1` = Vagrant shared folder (contains our HTML)
- **Magic:** This connects VM's filesystem → Container's filesystem

---

### **🔍 The Flow:**

```
1. Vagrant shares: /home/hassan/Desktop/.../p2/apps/app1 
                    ↓ (synced folder)
2. VM sees it as: /vagrant/apps/app1
                    ↓ (hostPath volume)
3. Container sees: /usr/share/nginx/html/index.html
                    ↓ (nginx serves this)
4. Browser gets:  App1 HTML page
```

**NOW save the file (Ctrl+O, Enter)** but **DON'T close yet!**

---

### **Step 3.2: Add App1 Service**

**In the SAME file, add this below (after the Deployment):**

```yaml
---
# ============================================
# APP 1 - Service
# ============================================
apiVersion: v1
kind: Service
metadata:
  name: app1-service
  namespace: default
spec:
  selector:
    app: app1
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
```

### **📖 Understanding Services**

**What is a Service?**
- Internal load balancer
- Gives pods a stable DNS name
- Distributes traffic across multiple pods

**Why do we need it?**
- Pods have random IPs that change when they restart
- Service provides a stable endpoint
- Ingress talks to Service, Service talks to Pods

**Line-by-line:**

```yaml
kind: Service
```
**What:** This is a Service (not Deployment)

```yaml
spec:
  selector:
    app: app1
```
**What:** Find pods with label `app: app1`  
**Why:** This connects Service → Pods from Deployment above

```yaml
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```
**What:** Port mapping  
**Why:**
- `port: 80` = Service listens on port 80
- `targetPort: 80` = Forward to pod's port 80
- Usually the same, but can differ

```yaml
  type: ClusterIP
```
**What:** Service type  
**Why:**
- `ClusterIP` = Internal only (not accessible from outside)
- `NodePort` = External access (we don't need this, Ingress handles external access)
- `LoadBalancer` = Cloud load balancer (for AWS/GCP, not needed here)

**Save (Ctrl+O, Enter), DON'T close yet!**

---

### **🧪 CHECKPOINT TEST: Validate YAML Syntax**

**Open a new terminal** (keep nano open) and run:

```bash
cd ~/Desktop/inceptionOfThings/iot/p2

# Check for syntax errors (proper indentation)
cat confs/deployment.yaml
```

**Look for:**
- ✅ Consistent indentation (2 spaces, not tabs)
- ✅ `---` separator between resources
- ✅ No weird characters

**If it looks good, continue to App2...**

---

### **Step 3.3: Add App2 Deployment (3 Replicas)**

**In the SAME file (nano still open), add this:**

```yaml
---
# ============================================
# APP 2 - Deployment (3 Replicas)
# ============================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app2-deployment
  namespace: default
spec:
  replicas: 3  # ← THREE REPLICAS - KEY REQUIREMENT
  selector:
    matchLabels:
      app: app2
  template:
    metadata:
      labels:
        app: app2
    spec:
      containers:
      - name: app2
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        hostPath:
          path: /vagrant/apps/app2
          type: Directory
```

### **❓ What's Different?**

```yaml
spec:
  replicas: 3  # ← Changed from 1 to 3
```

**This single line:**
- Creates 3 pods instead of 1
- Kubernetes manages them automatically
- If 1 dies, Kubernetes creates a new one
- Traffic is load-balanced across all 3

### **Real-World Scenario:**

```
User Request → Service → Randomly picks 1 of 3 pods
              ↓
         Pod 1, Pod 2, or Pod 3
```

**This is HIGH AVAILABILITY!**

---

### **Step 3.4: Add App2 Service**

**Add this below App2 Deployment:**

```yaml
---
# ============================================
# APP 2 - Service
# ============================================
apiVersion: v1
kind: Service
metadata:
  name: app2-service
  namespace: default
spec:
  selector:
    app: app2
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
```

**Notice:**
- `selector: app: app2` → Finds App2 pods
- Service doesn't care about replicas - it handles all 3 automatically

**Save, don't close!**

---

### **Step 3.5: Add App3 Deployment and Service**

**App3 is the DEFAULT app (shown when no matching host).**

```yaml
---
# ============================================
# APP 3 - Deployment (Default)
# ============================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app3-deployment
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app3
  template:
    metadata:
      labels:
        app: app3
    spec:
      containers:
      - name: app3
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        hostPath:
          path: /vagrant/apps/app3
          type: Directory

---
# ============================================
# APP 3 - Service
# ============================================
apiVersion: v1
kind: Service
metadata:
  name: app3-service
  namespace: default
spec:
  selector:
    app: app3
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
```

**Save, don't close! One more piece: Ingress...**

---

## **Phase 4: Understanding Ingress (The Router)**

### **📚 Theory: What is Ingress?**

**Ingress** = Routing rules for external traffic

**Think of it as nginx virtual hosts:**

```nginx
# Traditional nginx config:
server {
    server_name app1.com;
    location / {
        proxy_pass http://backend1;
    }
}

server {
    server_name app2.com;
    location / {
        proxy_pass http://backend2;
    }
}
```

**Ingress does the same, but in Kubernetes!**

---

### **Step 4.1: Add Ingress Resource**

**At the BOTTOM of deployment.yaml, add:**

```yaml
---
# ============================================
# INGRESS - Route traffic based on hostname
# ============================================
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: apps-ingress
  namespace: default
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web
spec:
  rules:
  # Route for app1.com
  - host: app1.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
  
  # Route for app2.com
  - host: app2.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
  
  # Default route (catch-all)
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app3-service
            port:
              number: 80
```

**NOW SAVE AND CLOSE!** (Ctrl+O, Enter, Ctrl+X)

---

### **📖 Understanding Ingress Rules**

```yaml
spec:
  rules:
  - host: app1.com
```
**What:** If Host header is `app1.com`  
**Where:** Route to backend defined below

```yaml
    http:
      paths:
      - path: /
        pathType: Prefix
```
**What:** Match any path starting with `/` (all paths)  
**Why:** `Prefix` means `/`, `/about`, `/contact` all match

```yaml
        backend:
          service:
            name: app1-service
            port:
              number: 80
```
**What:** Send traffic to `app1-service` on port 80  
**Flow:**
```
Request (Host: app1.com) 
  → Ingress sees "app1.com"
  → Routes to app1-service
  → Service routes to app1 pods
  → Pod serves HTML
```

**Third rule (no `host:`):**
```yaml
  - http:
      paths:
      - path: /
```
**What:** No host specified = DEFAULT route  
**Why:** Catches all requests that don't match app1.com or app2.com

---

### **🧪 FINAL YAML VALIDATION**

```bash
# Check structure
cat confs/deployment.yaml | grep -E "^(apiVersion|kind|metadata:|---)"
```

**Expected output:**
```
apiVersion
kind
metadata:
---
apiVersion
kind
metadata:
---
apiVersion
kind
metadata:
---
apiVersion
kind
metadata:
---
apiVersion
kind
metadata:
---
apiVersion
kind
metadata:
---
apiVersion
kind
metadata:
```

**Count:** Should be 7 resources (3 Deployments + 3 Services + 1 Ingress)

---

## **Phase 5: Create Vagrantfile**

### **Step 5.1: Understanding Vagrantfile for Part 2**

**Differences from Part 1:**
- Only 1 VM (not 2)
- More RAM (2GB vs 1GB) - multiple apps need more resources
- Synced folder for apps
- Different provisioning script

```bash
nano Vagrantfile
```

**Type this (understand each part):**

```ruby
Vagrant.configure("2") do |config|
  # Base OS
  config.vm.box = "ubuntu/jammy64"
  config.vm.box_check_update = false

  # ============================================
  # SERVER - Single K3s server
  # ============================================
  config.vm.define "hed-dybS" do |server|
    # Hostname
    server.vm.hostname = "hed-dybS"
    
    # Network - Static IP
    server.vm.network "private_network", ip: "192.168.56.110"
    
    # VirtualBox configuration
    server.vm.provider "virtualbox" do |vb|
      vb.name = "hed-dybS"
      vb.memory = "2048"  # More RAM than Part 1
      vb.cpus = 2
    end
    
    # Sync apps folder to VM
    server.vm.synced_folder "./apps", "/vagrant/apps"
    
    # Provisioning script
    server.vm.provision "shell", path: "scripts/server.sh"
  end
end
```

**Save it.**

### **📖 Understanding Key Lines**

```ruby
vb.memory = "2048"
```
**Why more RAM?**
- K3s server = ~512MB
- 3 nginx pods = ~50MB each
- Traefik = ~128MB
- System = ~512MB
- **Total:** ~1.3GB minimum, 2GB comfortable

```ruby
server.vm.synced_folder "./apps", "/vagrant/apps"
```
**What:** Share local `./apps` directory with VM  
**Where:** VM sees it as `/vagrant/apps`  
**Why:** Allows Kubernetes pods to access HTML files

**Flow:**
```
Your Computer: ~/iot/p2/apps/app1/index.html
                    ↓ (Vagrant shares)
VM Filesystem: /vagrant/apps/app1/index.html
                    ↓ (hostPath volume)
Pod Container: /usr/share/nginx/html/index.html
                    ↓ (nginx serves)
Browser:       Sees App1 page
```

---

### **🧪 TEST: Validate Vagrantfile**

```bash
vagrant validate
```

**Expected:** `Vagrantfile validated successfully.`

**If error:** Check for typos, missing `end` statements

---

## **Phase 6: Create Provisioning Script**

### **Step 6.1: Understanding the Script Flow**

```bash
nano scripts/server.sh
```

**Before typing, understand what it will do:**

```
1. Update system packages
2. Install K3s (includes Traefik)
3. Wait for K3s to be ready
4. Wait for Traefik to be ready (it's our Ingress controller)
5. Deploy our applications (kubectl apply)
6. Wait for deployments to be ready
7. Show status
```

**Now type it:**

```bash
#!/bin/bash

set -e

echo "=========================================="
echo "  P2 Server Setup Started"
echo "=========================================="

# Step 1: Update system
echo "[1/5] Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq > /dev/null 2>&1

# Step 2: Install K3s
echo "[2/5] Installing K3s server..."
curl -sfL https://get.k3s.io | sh -s - \
  --write-kubeconfig-mode 644 \
  --node-name hed-dybS

# Step 3: Wait for K3s to be ready
echo "[3/5] Waiting for K3s to be ready..."
sleep 15

# Step 4: Wait for Traefik (Ingress controller) to be ready
echo "[4/5] Waiting for Traefik Ingress controller..."

# First, wait for Traefik deployment to exist
echo "Waiting for Traefik deployment to be created..."
until kubectl get deployment traefik -n kube-system &>/dev/null; do
  echo "  Still waiting for Traefik deployment..."
  sleep 5
done

# Now wait for Traefik pods to be ready
echo "Traefik deployment found, waiting for pods..."
kubectl wait --namespace kube-system \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=traefik \
  --timeout=180s

# Step 5: Deploy applications
echo "[5/5] Deploying applications..."
kubectl apply -f /vagrant/confs/deployment.yaml

# Wait for deployments to be ready
echo "Waiting for all deployments to be ready..."
kubectl wait --for=condition=available --timeout=180s \
  deployment/app1-deployment \
  deployment/app2-deployment \
  deployment/app3-deployment

echo "=========================================="
echo "✅ P2 Server setup complete!"
echo "=========================================="

# Show status
echo ""
echo "📊 Cluster Status:"
kubectl get nodes
echo ""
echo "📦 Deployments:"
kubectl get deployments
echo ""
echo "🌐 Services:"
kubectl get services
echo ""
echo "🔀 Ingress:"
kubectl get ingress
echo ""
echo "📍 Pods:"
kubectl get pods -o wide
```

**Save it.**

---

### **📖 Understanding Critical Sections**

#### **Why the Traefik Wait Loop?**

```bash
until kubectl get deployment traefik -n kube-system &>/dev/null; do
  echo "  Still waiting for Traefik deployment..."
  sleep 5
done
```

**Problem:** K3s takes 10-20 seconds to create Traefik  
**Solution:** Loop until it exists, then wait for it to be ready  
**Why:** `kubectl wait` fails if resource doesn't exist yet

#### **What is `kubectl apply`?**

```bash
kubectl apply -f /vagrant/confs/deployment.yaml
```

**What:** Apply Kubernetes manifests (create resources)  
**Why:** This is how you deploy to Kubernetes  
**Alternative:** `kubectl create` (but apply is better - it can update existing resources)

#### **What is `kubectl wait`?**

```bash
kubectl wait --for=condition=available deployment/app1-deployment
```

**What:** Wait until deployment is ready (all pods running)  
**Why:** Don't proceed until apps are actually working  
**Timeout:** 180 seconds (3 minutes) - if not ready by then, fail

---

### **🧪 TEST: Make Script Executable**

```bash
chmod +x scripts/server.sh
```

**Verify:**
```bash
ls -lh scripts/server.sh
```

**Should show:** `-rwxr-xr-x` (x = executable)

---

## **Phase 7: First Deployment - THE BIG MOMENT**

### **Step 7.1: Final Pre-Flight Check**

```bash
cd ~/Desktop/inceptionOfThings/iot/p2

# Verify structure
tree -L 2
```

**Expected:**
```
.
├── Vagrantfile
├── apps
│   ├── app1
│   ├── app2
│   └── app3
├── confs
│   └── deployment.yaml
└── scripts
    └── server.sh
```

**Check files exist:**
```bash
ls apps/app1/index.html
ls apps/app2/index.html
ls apps/app3/index.html
ls confs/deployment.yaml
ls scripts/server.sh
```

**All should exist, no errors.**

---

### **Step 7.2: START THE VM**

```bash
vagrant up
```

**Watch the output carefully! This is where you learn what's happening:**

---

#### **📺 Output Analysis - Part 1: VM Creation**

```
Bringing machine 'hed-dybS' up with 'virtualbox' provider...
==> hed-dybS: Importing base box 'ubuntu/jammy64'...
```
**What:** Vagrant creates VM from base image  
**Time:** ~30 seconds

```
==> hed-dybS: Matching MAC address for NAT networking...
==> hed-dybS: Setting the name of the VM: hed-dybS
==> hed-dybS: Clearing any previously set network interfaces...
==> hed-dybS: Preparing network interfaces based on configuration...
    hed-dybS: Adapter 1: nat
    hed-dybS: Adapter 2: hostonly
```
**What:** Network setup  
**Adapter 1 (NAT):** Internet access  
**Adapter 2 (hostonly):** Your computer ↔ VM (192.168.56.110)

```
==> hed-dybS: Mounting shared folders...
    hed-dybS: /home/hassan/Desktop/... => /vagrant
    hed-dybS: .../p2/apps => /vagrant/apps
```
**What:** Vagrant shares folders  
**Why:** Kubernetes pods can access your HTML files

---

#### **📺 Output Analysis - Part 2: Provisioning**

```
==> hed-dybS: Running provisioner: shell...
==========================================
  P2 Server Setup Started
==========================================
```
**What:** Provisioning script started

```
[1/5] Updating system packages...
```
**What:** `apt-get update`  
**Time:** ~20 seconds  
**Why:** Get latest package lists

```
[2/5] Installing K3s server...
[INFO]  Finding release for channel stable
[INFO]  Using v1.33.6+k3s1 as release
[INFO]  Downloading binary https://github.com/k3s-io/k3s/...
```
**What:** Installing K3s  
**Time:** 1-2 minutes (downloads ~80MB)  
**Why:** This is the actual Kubernetes distribution

```
[INFO]  Installing k3s to /usr/local/bin/k3s
[INFO]  Creating /usr/local/bin/kubectl symlink to k3s
```
**What:** K3s binary + kubectl command  
**Why:** `kubectl` is the Kubernetes CLI tool

```
[INFO]  systemd: Creating service file /etc/systemd/system/k3s.service
[INFO]  systemd: Enabling k3s unit
[INFO]  systemd: Starting k3s
```
**What:** K3s service starts automatically  
**Why:** Will restart on reboot, runs in background

```
[3/5] Waiting for K3s to be ready...
```
**What:** 15 second sleep  
**Why:** K3s needs time to initialize

```
[4/5] Waiting for Traefik Ingress controller...
Waiting for Traefik deployment to be created...
```
**What:** Waiting for Traefik (Ingress controller built into K3s)  
**Time:** 10-30 seconds  
**Why:** Traefik takes time to download image and start

```
Traefik deployment found, waiting for pods...
pod/traefik-xxx condition met
```
**What:** Traefik is ready!  
**Why:** Now we can deploy apps (Ingress won't work without Traefik)

```
[5/5] Deploying applications...
deployment.apps/app1-deployment created
service/app1-service created
deployment.apps/app2-deployment created
service/app2-service created
deployment.apps/app3-deployment created
service/app3-service created
ingress.networking.k8s.io/apps-ingress created
```
**What:** All resources created!  
**Why:** `kubectl apply` processed our YAML

```
Waiting for all deployments to be ready...
deployment.apps/app1-deployment condition met
deployment.apps/app2-deployment condition met
deployment.apps/app3-deployment condition met
```
**What:** All apps are running!  
**Time:** 20-40 seconds  
**Why:** Kubernetes downloaded nginx images, started containers

---

#### **📺 Output Analysis - Part 3: Status Report**

```
==========================================
✅ P2 Server setup complete!
==========================================
```
**Success!**

```
📊 Cluster Status:
NAME       STATUS   ROLES                  AGE   VERSION
hed-dybs   Ready    control-plane,master   2m    v1.33.6+k3s1
```
**What:** Node status  
**`Ready`** = Good!  
**`control-plane,master`** = This is the server (not worker)

```
📦 Deployments:
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
app1-deployment    1/1     1            1           45s
app2-deployment    3/3     3            3           45s
app3-deployment    1/1     1            1           45s
```
**What:** Deployment status  
**`app2-deployment 3/3`** = 3 replicas ready! ✅  
**`READY` column** = Current/Desired replicas

```
🌐 Services:
NAME           TYPE        CLUSTER-IP      PORT(S)
app1-service   ClusterIP   10.43.xxx.xxx   80/TCP
app2-service   ClusterIP   10.43.xxx.xxx   80/TCP
app3-service   ClusterIP   10.43.xxx.xxx   80/TCP
```
**What:** Service status  
**`CLUSTER-IP`** = Internal IP (only accessible inside cluster)  
**Why:** Ingress talks to these IPs

```
🔀 Ingress:
NAME           CLASS     HOSTS                 ADDRESS         PORTS
apps-ingress   traefik   app1.com,app2.com,... 192.168.56.110  80
```
**What:** Ingress status  
**`HOSTS`** = Hostnames it handles  
**`ADDRESS`** = External IP (this is what your browser hits!)

```
📍 Pods:
NAME                              READY   STATUS    NODE
app1-deployment-xxx               1/1     Running   hed-dybs
app2-deployment-xxx               1/1     Running   hed-dybs
app2-deployment-yyy               1/1     Running   hed-dybs
app2-deployment-zzz               1/1     Running   hed-dybs
app3-deployment-xxx               1/1     Running   hed-dybs
```
**What:** Pod status  
**Notice:** 3 app2 pods! ✅  
**`Running`** = Everything works!

---

### **✅ SUCCESS CHECKPOINT**

**If you see:**
- ✅ All deployments `READY`
- ✅ App2 shows `3/3`
- ✅ Ingress shows `ADDRESS: 192.168.56.110`
- ✅ All pods `Running`

**You're ready to test!**

---

## **Phase 8: Testing - The Moment of Truth**

### **Step 8.1: Test from Inside VM First**

```bash
vagrant ssh hed-dybS
```

**You're now inside the VM.**

---

#### **Test 1: Check Cluster Health**

```bash
kubectl get all
```

**What to look for:**
- All pods `STATUS: Running`
- No `CrashLoopBackOff` or `Error`

---

#### **Test 2: Test App1 (with Host header)**

```bash
curl -H "Host: app1.com" http://localhost
```

**Expected:** HTML with "App 1"

**Extract just the title:**
```bash
curl -s -H "Host: app1.com" http://localhost | grep -o "<title>.*</title>"
```

**Should show:** `<title>App 1</title>`

---

#### **Test 3: Test App2 (with Host header)**

```bash
curl -s -H "Host: app2.com" http://localhost | grep -o "<title>.*</title>"
```

**Should show:** `<title>App 2</title>`

**Look for replica indicator:**
```bash
curl -s -H "Host: app2.com" http://localhost | grep "3 Replicas"
```

**Should show:** `<div class="badge">⚡ 3 Replicas Running</div>`

---

#### **Test 4: Test App3 (default, no Host header)**

```bash
curl -s http://localhost | grep -o "<title>.*</title>"
```

**Should show:** `<title>App 3</title>`

---

#### **Test 5: Verify Load Balancing (Advanced)**

**Make 10 requests to App2 and see which pod handles them:**

```bash
for i in {1..10}; do
  curl -s -H "Host: app2.com" http://localhost | grep -o "App 2"
done
```

**Expected:** All show "App 2" (traffic distributed across 3 pods)

---

#### **Test 6: Verify App2 Has 3 Pods**

```bash
kubectl get pods -l app=app2
```

**Expected:**
```
NAME                    READY   STATUS    RESTARTS   AGE
app2-deployment-xxx     1/1     Running   0          5m
app2-deployment-yyy     1/1     Running   0          5m
app2-deployment-zzz     1/1     Running   0          5m
```

**Count:** Should be exactly 3 pods ✅

---

#### **Test 7: Check Ingress Routes**

```bash
kubectl describe ingress apps-ingress
```

**Look for:**
```
Rules:
  Host        Path  Backends
  ----        ----  --------
  app1.com
              /   app1-service:80
  app2.com
              /   app2-service:80
  *
              /   app3-service:80
```

**`*` = default route (app3)**

---

### **🎉 ALL TESTS PASSED INSIDE VM?**

**Exit VM:**
```bash
exit
```

**Now test from your host machine...**

---

### **Step 8.2: Test from Host Machine**

#### **Test 1: Can You Reach the IP?**

```bash
ping -c 3 192.168.56.110
```

**Expected:** 3 replies, 0% packet loss

---

#### **Test 2: Add Hosts to /etc/hosts**

```bash
sudo nano /etc/hosts
```

**Add these lines AT THE END:**
```
192.168.56.110  app1.com
192.168.56.110  app2.com
```

**Save (Ctrl+O, Enter, Ctrl+X)**

**Why?**
- Your computer doesn't know `app1.com` is fake
- hosts maps hostnames → IPs
- This simulates DNS

---

#### **Test 3: curl Tests from Host**

```bash
# Test app1.com
curl -s http://app1.com | grep -o "<h1>.*</h1>"

# Test app2.com
curl -s http://app2.com | grep -o "<h1>.*</h1>"

# Test default (using IP directly, no hostname)
curl -s http://192.168.56.110 | grep -o "<h1>.*</h1>"
```

**Expected:**
```
<h1>🎯 App 1</h1>
<h1>🚀 App 2</h1>
<h1>🏠 App 3</h1>
```

**✅ ALL WORKING? Move to browser test...**

---

### **Step 8.3: Browser Testing - THE VISUAL TEST**

**Open your browser and go to:**

1. **http://app1.com**
   - Should show **purple/blue gradient**
   - Title: "🎯 App 1"
   - Text: "Host: app1.com"

2. **http://app2.com**
   - Should show **green gradient**
   - Title: "🚀 App 2"
   - Badge: "⚡ 3 Replicas Running"

3. **http://192.168.56.110** (IP directly, no hostname)
   - Should show **pink/red gradient**
   - Title: "🏠 App 3"
   - Badge: "⭐ Fallback Route"

---

#### **What if wrong app shows?**

**Check Ingress:**
```bash
vagrant ssh hed-dybS -c "kubectl get ingress apps-ingress -o yaml"
```

**Look for `rules:` section - should match our YAML**

---

#### **What if "Connection Refused"?**

**Check Traefik:**
```bash
vagrant ssh hed-dybS -c "kubectl get pods -n kube-system | grep traefik"
```

**Should show:** `traefik-xxx   1/1   Running`

---

#### **What if App2 doesn't show 3 replicas badge?**

**Check HTML file was mounted:**
```bash
vagrant ssh hed-dybS -c "cat /vagrant/apps/app2/index.html | grep Replicas"
```

**Should show the HTML line with "3 Replicas"**

---

## **Phase 9: Advanced Testing & Learning**

### **Test 9.1: Scale App2 to 5 Replicas (Live)**

```bash
vagrant ssh hed-dybS
```

```bash
# Scale up
kubectl scale deployment app2-deployment --replicas=5

# Watch it happen
kubectl get pods -l app=app2 --watch
```

**You'll see:**
```
app2-deployment-xxx   1/1   Running
app2-deployment-yyy   1/1   Running
app2-deployment-zzz   1/1   Running
app2-deployment-aaa   0/1   Pending     ← New pod creating
app2-deployment-bbb   0/1   Pending     ← New pod creating
```

**Wait ~20 seconds, then:**
```
app2-deployment-aaa   1/1   Running
app2-deployment-bbb   1/1   Running
```

**Press Ctrl+C to stop watching.**

**Test in browser - still works!** Traffic now goes to 5 pods.

**Scale back:**
```bash
kubectl scale deployment app2-deployment --replicas=3
```

---

### **Test 9.2: Delete a Pod and Watch Kubernetes Recreate It**

```bash
# Get pod names
kubectl get pods -l app=app2

# Delete one
kubectl delete pod app2-deployment-xxx

# Immediately watch
kubectl get pods -l app=app2 --watch
```

**You'll see:**
```
app2-deployment-xxx   1/1   Terminating   ← Being deleted
app2-deployment-new   0/1   Pending       ← Kubernetes creates replacement
...
app2-deployment-new   1/1   Running       ← New pod ready!
```

**Kubernetes maintains 3 replicas automatically!** This is **self-healing**.

---

### **Test 9.3: Check Logs**

```bash
# Get pod name
kubectl get pods -l app=app1

# View logs
kubectl logs app1-deployment-xxx
```

**Expected:** Nginx access logs (shows HTTP requests)

---

### **Test 9.4: Exec into a Pod**

```bash
# Get pod name
kubectl get pods -l app=app1

# Enter the container
kubectl exec -it app1-deployment-xxx -- /bin/sh
```

**You're now inside the nginx container!**

```bash
# Check files
ls /usr/share/nginx/html

# View HTML
cat /usr/share/nginx/html/index.html

# Exit
exit
```

---

### **Test 9.5: View Traefik Dashboard**

```bash
# Port-forward Traefik dashboard
kubectl port-forward -n kube-system deployment/traefik 9000:9000
```

**Open in browser:** `http://localhost:9000/dashboard/`

**You'll see:**
- **HTTP Routers:** app1.com, app2.com routes
- **Services:** app1-service, app2-service, app3-service
- **Entrypoints:** web (port 80)

**Press Ctrl+C to stop port-forward.**

---

## **Phase 10: Troubleshooting Guide**

### **Problem 1: Pods Not Starting**

```bash
kubectl get pods
```

**If status is `Pending`:**
```bash
kubectl describe pod <pod-name>
```

**Look for:** `Events:` section at bottom  
**Common causes:**
- Image pull error
- Insufficient resources
- Volume mount error

---

### **Problem 2: App Shows Wrong Content**

```bash
# Check volume mount
vagrant ssh hed-dybS
ls -la /vagrant/apps/app1/

# Should show index.html
```

**If missing:** Vagrant didn't sync folder
```bash
exit
vagrant reload --provision
```

---

### **Problem 3: Can't Access from Browser**

```bash
# Check /etc/hosts
cat /etc/hosts | grep 192.168.56.110

# Should show:
# 192.168.56.110  app1.com
# 192.168.56.110  app2.com
```

**If missing, add them:**
```bash
sudo nano /etc/hosts
```

---

### **Problem 4: Ingress Not Working**

```bash
vagrant ssh hed-dybS

# Check Traefik is running
kubectl get pods -n kube-system | grep traefik

# Check Ingress resource
kubectl get ingress
kubectl describe ingress apps-ingress
```

**Look for:** `Rules:` and `Backend:` sections

---

## **Phase 11: Understanding What You Built**

### **🎓 Kubernetes Concepts You Learned**

1. **Deployment**
   - Manages pods
   - Ensures desired number of replicas
   - Handles updates and rollbacks

2. **Service**
   - Internal load balancer
   - Provides stable DNS name
   - Distributes traffic across pods

3. **Ingress**
   - External routing
   - Hostname-based routing
   - Like nginx virtual hosts

4. **Pod**
   - Smallest deployable unit
   - Runs 1+ containers
   - Has IP address

5. **Replica**
   - Multiple copies of same pod
   - High availability
   - Load distribution

---

### **🔍 How Traffic Flows**

```
1. Browser sends: GET / HTTP/1.1
                  Host: app2.com
                  ↓
2. DNS (via /etc/hosts): app2.com → 192.168.56.110
                  ↓
3. Request reaches: 192.168.56.110:80
                  ↓
4. Traefik Ingress Controller:
   - Reads Host header: "app2.com"
   - Matches Ingress rule
   - Routes to: app2-service
                  ↓
5. Service (app2-service):
   - Has 3 backend pods
   - Picks one randomly
   - Forwards request
                  ↓
6. Pod (app2-deployment-xxx):
   - Nginx receives request
   - Serves: /usr/share/nginx/html/index.html
   - (Mounted from /vagrant/apps/app2)
                  ↓
7. Response travels back:
   Pod → Service → Ingress → Your browser
```

---

### **📊 Resource Hierarchy**

```
Cluster (hed-dybS)
  ├─ Namespace: default
  │   ├─ Deployment: app1-deployment
  │   │   └─ Pod: app1-deployment-xxx
  │   │       └─ Container: nginx:alpine
  │   │           └─ Volume: /vagrant/apps/app1
  │   │
  │   ├─ Deployment: app2-deployment (replicas: 3)
  │   │   ├─ Pod: app2-deployment-xxx
  │   │   ├─ Pod: app2-deployment-yyy
  │   │   └─ Pod: app2-deployment-zzz
  │   │
  │   ├─ Service: app1-service → app1 pods
  │   ├─ Service: app2-service → app2 pods
  │   ├─ Service: app3-service → app3 pods
  │   │
  │   └─ Ingress: apps-ingress
  │       ├─ Rule: app1.com → app1-service
  │       ├─ Rule: app2.com → app2-service
  │       └─ Rule: * → app3-service
  │
  └─ Namespace: kube-system
      └─ Deployment: traefik (Ingress Controller)
```

---

## **Phase 12: Cleanup and Rebuild**

### **Step 12.1: Clean Everything**

```bash
# Stop VM
vagrant halt

# OR completely remove
vagrant destroy -f

# Verify
vagrant status
```

---

### **Step 12.2: Rebuild from Scratch**

```bash
# Start fresh
vagrant up

# Should complete in ~3-5 minutes
```

**This tests:**
- ✅ Your configuration is reproducible
- ✅ No manual steps were needed
- ✅ Everything is automated

---

## **✅ Final Checklist - Part 2 Complete**

- [x] **1 VM** with K3s server mode
- [x] **3 web apps** deployed
- [x] **App2 has 3 replicas** (`kubectl get pods -l app=app2` shows 3)
- [x] **Hostname routing** works (app1.com, app2.com)
- [x] **Default route** works (192.168.56.110 → app3)
- [x] **Ingress** configured (`kubectl get ingress`)
- [x] **All pods Running** (`kubectl get pods`)
- [x] **Browser access** works for all 3 apps
- [x] **Self-healing** verified (deleted pod recreates)
- [x] **Understanding** of Deployments, Services, Ingress

---

## **📸 Screenshots for Submission**

**Take these screenshots:**

1. **Browser - App1**
   - URL bar showing `app1.com`
   - Purple/blue page visible

2. **Browser - App2**
   - URL bar showing `app2.com`
   - Green page with "3 Replicas" badge

3. **Browser - App3**
   - URL bar showing `192.168.56.110`
   - Pink/red page

4. **Terminal - kubectl get all**
   ```bash
   vagrant ssh hed-dybS -c "kubectl get all"
   ```

5. **Terminal - App2 replicas**
   ```bash
   vagrant ssh hed-dybS -c "kubectl get pods -l app=app2"
   ```

6. **Terminal - Ingress**
   ```bash
   vagrant ssh hed-dybS -c "kubectl get ingress -o wide"
   ```

---

## **🎉 Congratulations!**

**You now understand:**
- ✅ Kubernetes architecture
- ✅ Deployments, Services, Ingress
- ✅ Load balancing and replicas
- ✅ Hostname-based routing
- ✅ K3s lightweight Kubernetes
- ✅ Traefik Ingress controller

**Next:** Part 3 (CI/CD with GitLab + ArgoCD)

---

**Any errors? Paste them and I'll help you debug!** 🐛