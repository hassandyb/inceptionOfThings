# 🚀 PART 2: K3s with Three Web Applications - Complete Implementation Guide

**Goal:** Deploy 3 web apps accessible via different hostnames on a single K3s server.

---

## **📋 Subject Requirements Checklist**

```
✅ 1 VM with K3s in server mode
✅ 3 web applications
✅ Access via HOST header (app1.com, app2.com, default)
✅ IP: 192.168.56.110
✅ Hostname: <login>S (hed-dybS)
✅ App2 has 3 replicas
✅ Ingress controller (Traefik - built into K3s)
✅ Different responses for each app
```

---

## **🎯 Architecture Overview**

```
Browser → http://192.168.56.110
          Host: app1.com        → App1 (1 replica)
          Host: app2.com        → App2 (3 replicas)
          Host: anything else   → App3 (1 replica, default)

All running on: hed-dybS (192.168.56.110)
```

---

## **Phase 0: Analyze Reference Project**

### **Step 0.1: Check Reference Structure**

```bash
cd ~/Desktop/inceptionOfThings/ref/p2
tree
```

**Expected structure:**
```
p2/
├── Vagrantfile
├── scripts/
│   ├── server.sh
│   └── add_hosts.sh
├── confs/
│   └── deployment.yaml
└── rsc/
    ├── app1/
    │   └── index.html
    ├── app2/
    │   └── index.html
    └── app3/
        └── index.html
```

---

### **Step 0.2: Read Reference Files**

```bash
# Check Vagrantfile
cat Vagrantfile

# Check server script
cat scripts/server.sh

# Check deployment config
cat confs/deployment.yaml

# Check HTML files
cat rsc/app1/index.html
cat rsc/app2/index.html
cat rsc/app3/index.html
```

**Paste the contents here so we can analyze them together!**

---

## **Phase 1: Create Project Structure**

### **Step 1.1: Create Directory Structure**

```bash
cd ~/Desktop/inceptionOfThings/z_inceptionOfThings
mkdir -p p2/{scripts,confs,apps/{app1,app2,app3}}
cd p2
```

**Verify:**
```bash
tree
```

**Expected:**
```
p2/
├── scripts/
├── confs/
└── apps/
    ├── app1/
    ├── app2/
    └── app3/
```

---

### **Step 1.2: Create HTML Files for Each App**

#### **App1 - Simple Blue Page**

```bash
nano apps/app1/index.html
```

````html
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
            backdrop-filter: blur(10px);
        }
        h1 {
            font-size: 4em;
            margin: 0;
        }
        p {
            font-size: 1.5em;
            margin: 20px 0;
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
````

**Save it.**

---

#### **App2 - Green Page with Replicas Info**

```bash
nano apps/app2/index.html
```

````html
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
            backdrop-filter: blur(10px);
        }
        h1 {
            font-size: 4em;
            margin: 0;
        }
        p {
            font-size: 1.5em;
            margin: 20px 0;
        }
        .badge {
            background: rgba(255, 255, 255, 0.3);
            padding: 10px 20px;
            border-radius: 25px;
            display: inline-block;
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
````

**Save it.**

---

#### **App3 - Orange Default Page**

```bash
nano apps/app3/index.html
```

````html
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
            backdrop-filter: blur(10px);
        }
        h1 {
            font-size: 4em;
            margin: 0;
        }
        p {
            font-size: 1.5em;
            margin: 20px 0;
        }
        .badge {
            background: rgba(255, 255, 255, 0.3);
            padding: 10px 20px;
            border-radius: 25px;
            display: inline-block;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏠 App 3</h1>
        <p>Welcome to Application Three!</p>
        <p>Default Application</p>
        <div class="badge">⭐ Fallback Route</div>
    </div>
</body>
</html>
````

**Save it.**

---

### **Step 1.3: Verify HTML Files**

```bash
ls -la apps/*/
```

**Expected:**
```
apps/app1/:
-rw-r--r-- index.html

apps/app2/:
-rw-r--r-- index.html

apps/app3/:
-rw-r--r-- index.html
```

---

## **Phase 2: Create Kubernetes Manifests**

### **Step 2.1: Understanding What We Need**

For each app, we need:
1. **Deployment** - Runs the pods
2. **Service** - Exposes pods internally
3. **Ingress** - Routes external traffic based on hostname

**We'll create ONE file with ALL resources.**

---

### **Step 2.2: Create Deployment YAML - Start with App1**

```bash
nano confs/deployment.yaml
```

````yaml
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
````

**What's happening:**
- `replicas: 1` = 1 pod for app1
- `image: nginx:alpine` = Lightweight web server
- `volumeMounts` = Mount our HTML file into nginx
- `hostPath: /vagrant/apps/app1` = Vagrant shared folder

**Save it for now. Don't close the file yet!**

---

### **Step 2.3: Add App1 Service**

**In the SAME file, add this below the Deployment:**

````yaml
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
````

**What's happening:**
- `selector: app: app1` = Routes traffic to app1 pods
- `port: 80` = Service listens on port 80
- `type: ClusterIP` = Internal only (Ingress will expose it)

**Keep the file open!**

---

### **Step 2.4: Add App2 Deployment and Service**

**Add this below App1 Service:**

````yaml
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
  replicas: 3  # ← THREE REPLICAS as required
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
````

**Keep going!**

---

### **Step 2.5: Add App3 Deployment and Service**

**Add this below App2 Service:**

````yaml
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
````

**Almost done! Now the Ingress...**

---

### **Step 2.6: Add Ingress for Routing**

**Add this at the BOTTOM of the file:**

````yaml
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
````

**What's happening:**
- `host: app1.com` = If hostname is app1.com → route to app1-service
- `host: app2.com` = If hostname is app2.com → route to app2-service
- No `host:` in last rule = Default/catch-all → route to app3-service

**NOW save the file!** (Ctrl+O, Enter, Ctrl+X)

---

### **Step 2.7: Verify YAML Syntax**

```bash
# Check for syntax errors
cat confs/deployment.yaml | grep -E "^(apiVersion|kind|metadata:|spec:|---)"
```

**Should show clean structure with no weird indentation.**

---

## **Phase 3: Create Vagrantfile**

### **Step 3.1: Create Minimal Vagrantfile**

```bash
nano Vagrantfile
```

````ruby
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
      vb.memory = "2048"  # More RAM for multiple apps
      vb.cpus = 2
    end
    
    # Sync apps folder to VM
    server.vm.synced_folder "./apps", "/vagrant/apps"
    
    # Provisioning script
    server.vm.provision "shell", path: "scripts/server.sh"
  end
end
````

**What's new:**
- `memory: "2048"` = More RAM (3 apps + K3s)
- `cpus: 2` = Better performance
- `synced_folder` = Share apps folder with VM

**Save it.**

---

### **Step 3.2: Validate Vagrantfile**

```bash
vagrant validate
```

**Should say:** "Vagrantfile validated successfully."

---

## **Phase 4: Create Server Provisioning Script**

### **Step 4.1: Create server.sh**

```bash
nano scripts/server.sh
```

````bash
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
````

**What's happening:**
- Installs K3s (includes Traefik ingress controller)
- Waits for Traefik to be ready
- Applies our deployment YAML
- Waits for all apps to be ready
- Shows status

**Save it.**

---

### **Step 4.2: Make Script Executable**

```bash
chmod +x scripts/server.sh
```

---

## **Phase 5: Test Deployment**

### **Step 5.1: Start the VM**

```bash
vagrant up
```

**Watch for:**
```
[1/5] Updating system packages...
[2/5] Installing K3s server...
[3/5] Waiting for K3s to be ready...
[4/5] Waiting for Traefik Ingress controller...
[5/5] Deploying applications...
✅ P2 Server setup complete!
```

**This takes 3-5 minutes.**

---

### **Step 5.2: Verify Deployment**

```bash
vagrant ssh hed-dybS
```

**Inside the VM:**

```bash
# Check all pods are running
kubectl get pods

# Expected output:
# app1-deployment-xxx   1/1   Running
# app2-deployment-xxx   1/1   Running  ← Should see 3 of these
# app2-deployment-yyy   1/1   Running
# app2-deployment-zzz   1/1   Running
# app3-deployment-xxx   1/1   Running
```

---

### **Step 5.3: Check Services**

```bash
kubectl get services
```

**Expected:**
```
NAME           TYPE        CLUSTER-IP     PORT(S)
app1-service   ClusterIP   10.43.x.x      80/TCP
app2-service   ClusterIP   10.43.x.x      80/TCP
app3-service   ClusterIP   10.43.x.x      80/TCP
```

---

### **Step 5.4: Check Ingress**

```bash
kubectl get ingress
```

**Expected:**
```
NAME           CLASS      HOSTS                   ADDRESS         PORTS
apps-ingress   traefik    app1.com,app2.com,...   192.168.56.110  80
```

---

### **Step 5.5: Test from Inside VM**

```bash
# Test app1
curl -H "Host: app1.com" http://localhost | grep -o "<title>.*</title>"

# Test app2
curl -H "Host: app2.com" http://localhost | grep -o "<title>.*</title>"

# Test default (app3)
curl http://localhost | grep -o "<title>.*</title>"
```

**Expected:**
```
<title>App 1</title>
<title>App 2</title>
<title>App 3</title>
```

**Exit VM:**
```bash
exit
```

---

## **Phase 6: Test from Host Machine**

### **Step 6.1: Add Hosts to /etc/hosts**

**On your HOST machine (not in VM):**

```bash
sudo nano /etc/hosts
```

**Add these lines:**
```
192.168.56.110  app1.com
192.168.56.110  app2.com
192.168.56.110  app3.com
```

**Save it.**

---

### **Step 6.2: Test with curl**

```bash
# Test app1
curl http://app1.com | grep -o "<h1>.*</h1>"

# Test app2
curl http://app2.com | grep -o "<h1>.*</h1>"

# Test default (use IP directly)
curl http://192.168.56.110 | grep -o "<h1>.*</h1>"
```

**Expected:**
```
<h1>🎯 App 1</h1>
<h1>🚀 App 2</h1>
<h1>🏠 App 3</h1>
```

---

### **Step 6.3: Test in Browser**

**Open these URLs in your browser:**

1. `http://app1.com` → Should show **purple/blue page** "App 1"
2. `http://app2.com` → Should show **green page** "App 2" with "3 Replicas"
3. `http://192.168.56.110` → Should show **pink page** "App 3" (default)

**Take screenshots for submission!** 📸

---

## **Phase 7: Verification Tests**

### **Step 7.1: Verify App2 Has 3 Replicas**

```bash
vagrant ssh hed-dybS -c "kubectl get pods -l app=app2"
```

**Should show 3 pods, all Running.**

---

### **Step 7.2: Test Load Balancing on App2**

```bash
vagrant ssh hed-dybS
```

**Inside VM:**
```bash
# Make 10 requests and show which pod responded
for i in {1..10}; do
  curl -s -H "Host: app2.com" http://localhost | grep -o "App 2"
done
```

**All should show "App 2".**

---

### **Step 7.3: Test Ingress Routing**

```bash
# Test wrong hostname goes to default
curl -H "Host: wrong.com" http://192.168.56.110 | grep -o "<h1>.*</h1>"
```

**Should show:** `<h1>🏠 App 3</h1>` (default app)

---

### **Step 7.4: Check Traefik Dashboard (Optional)**

```bash
kubectl port-forward -n kube-system deployment/traefik 9000:9000 &
```

**Then open:** `http://localhost:9000/dashboard/`

**You'll see Traefik routes!**

---

## **Phase 8: Stress Testing**

### **Step 8.1: Delete and Recreate App2 Pods**

```bash
vagrant ssh hed-dybS
```

```bash
# Delete all app2 pods
kubectl delete pods -l app=app2

# Watch them recreate
kubectl get pods -l app=app2 --watch
```

**Press Ctrl+C when all 3 are Running again.**

**Test in browser - should still work!**

---

### **Step 8.2: Scale App2 to 5 Replicas**

```bash
kubectl scale deployment app2-deployment --replicas=5

kubectl get pods -l app=app2
```

**Should show 5 pods now!**

---

### **Step 8.3: Full Rebuild Test**

```bash
exit  # Leave VM
vagrant destroy -f
vagrant up
```

**After it finishes, test all 3 apps in browser again.**

---

## **Phase 9: Documentation**

### **Step 9.1: Create README**

```bash
nano README.md
```

````markdown
# Part 2: K3s with Three Web Applications

## 📋 Architecture

- **Single VM**: hed-dybS (192.168.56.110)
- **K3s**: Server mode with Traefik Ingress
- **3 Applications**:
  - App1: Purple/Blue theme (1 replica) - `app1.com`
  - App2: Green theme (3 replicas) - `app2.com`
  - App3: Pink theme (1 replica) - Default fallback

## 🚀 Usage

### Start Server
```bash
vagrant up
```

### Add Hosts (on your machine)
```bash
sudo nano /etc/hosts
# Add:
192.168.56.110  app1.com
192.168.56.110  app2.com
```

### Access Applications
- http://app1.com → App 1
- http://app2.com → App 2 (3 replicas)
- http://192.168.56.110 → App 3 (default)

### Check Status
```bash
vagrant ssh hed-dybS -c "kubectl get all"
```

## 🧪 Verification

```bash
# Check deployments
vagrant ssh hed-dybS -c "kubectl get deployments"

# Check app2 replicas
vagrant ssh hed-dybS -c "kubectl get pods -l app=app2"

# Check ingress
vagrant ssh hed-dybS -c "kubectl get ingress"
```

## ✅ Requirements Met

- [x] Single VM with K3s server mode
- [x] 3 web applications deployed
- [x] Hostname-based routing (app1.com, app2.com)
- [x] App2 has 3 replicas
- [x] Default route to App3
- [x] Traefik Ingress controller working
````

**Save it.**

---

### **Step 9.2: Create Verification Script**

```bash
nano verify.sh
```

````bash
#!/bin/bash

echo "=========================================="
echo "  Part 2 Verification Script"
echo "=========================================="

echo ""
echo "1. Checking VM status..."
vagrant status

echo ""
echo "2. Checking deployments..."
vagrant ssh hed-dybS -c "kubectl get deployments"

echo ""
echo "3. Checking App2 replicas..."
vagrant ssh hed-dybS -c "kubectl get pods -l app=app2"

echo ""
echo "4. Checking services..."
vagrant ssh hed-dybS -c "kubectl get services"

echo ""
echo "5. Checking ingress..."
vagrant ssh hed-dybS -c "kubectl get ingress"

echo ""
echo "6. Testing app1.com..."
curl -s -H "Host: app1.com" http://192.168.56.110 | grep -o "<title>.*</title>"

echo ""
echo "7. Testing app2.com..."
curl -s -H "Host: app2.com" http://192.168.56.110 | grep -o "<title>.*</title>"

echo ""
echo "8. Testing default route..."
curl -s http://192.168.56.110 | grep -o "<title>.*</title>"

echo ""
echo "=========================================="
echo "✅ All checks complete!"
echo "=========================================="
````

**Save and make executable:**
```bash
chmod +x verify.sh
```

**Run it:**
```bash
./verify.sh
```

---

## **✅ Final Checklist**

- [ ] VM starts without errors
- [ ] All 3 apps deploy successfully
- [ ] App2 has exactly 3 pods running
- [ ] `app1.com` shows App 1
- [ ] `app2.com` shows App 2
- [ ] `192.168.56.110` (no host) shows App 3
- [ ] Ingress is configured and working
- [ ] Can access apps in browser
- [ ] Screenshots taken
- [ ] README complete

---

**🎉 Part 2 Complete! Show me your verification output and screenshots!** 📸