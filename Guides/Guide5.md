# 🚀 PART 2: Building K3s Project - TRUE HANDS-ON LEARNING

**Let's build the reference project step-by-step with LOTS of testing!**

---

## **Phase 0: Clean Start**

### **Step 0.1: Remove Old Project**

```bash
cd ~/Desktop/inceptionOfThings/iot
rm -rf p2
mkdir -p p2
cd p2
```

**Verify you're in clean directory:**
```bash
pwd
ls -la
```

**Expected:** Empty directory (only `.` and `..`)

---

### **Step 0.2: Create Basic Structure**

```bash
mkdir -p apps/app1 apps/app2 apps/app3
mkdir -p confs
mkdir -p scripts
```

**Test:**
```bash
tree
```

**Expected:**
```
.
├── apps
│   ├── app1
│   ├── app2
│   └── app3
├── confs
└── scripts
```

✅ **Structure ready!**

---

## **Phase 1: Create Simple HTML Files**

### **Step 1.1: Create App1 HTML (Very Simple)**

```bash
nano apps/app1/index.html
```

**Type this SIMPLE HTML:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>App1</title>
    <style>
        body {
            font-family: Arial;
            background: #667eea;
            color: white;
            text-align: center;
            padding-top: 100px;
        }
    </style>
</head>
<body>
    <h1>App 1</h1>
    <p>Host: app1.com</p>
</body>
</html>
```

**Save:** Ctrl+O, Enter, Ctrl+X

---

### **Step 1.2: Test App1 HTML**

```bash
cat apps/app1/index.html
```

**Should show the HTML.**

**Count lines:**
```bash
wc -l apps/app1/index.html
```

**Should show:** `17 apps/app1/index.html`

✅ **App1 HTML created!**

---

### **Step 1.3: Create App2 HTML**

```bash
nano apps/app2/index.html
```

```html
<!DOCTYPE html>
<html>
<head>
    <title>App2</title>
    <style>
        body {
            font-family: Arial;
            background: #11998e;
            color: white;
            text-align: center;
            padding-top: 100px;
        }
    </style>
</head>
<body>
    <h1>App 2</h1>
    <p>Host: app2.com</p>
    <p>3 Replicas</p>
</body>
</html>
```

**Save.**

---

### **Step 1.4: Test App2 HTML**

```bash
cat apps/app2/index.html | grep Replicas
```

**Should show:** `<p>3 Replicas</p>`

✅ **App2 HTML created!**

---

### **Step 1.5: Create App3 HTML**

```bash
nano apps/app3/index.html
```

```html
<!DOCTYPE html>
<html>
<head>
    <title>App3</title>
    <style>
        body {
            font-family: Arial;
            background: #f093fb;
            color: white;
            text-align: center;
            padding-top: 100px;
        }
    </style>
</head>
<body>
    <h1>App 3</h1>
    <p>Default App</p>
</body>
</html>
```

**Save.**

---

### **Step 1.6: Verify All HTML Files**

```bash
ls -lh apps/*/index.html
```

**Expected:**
```
-rw-r--r-- apps/app1/index.html
-rw-r--r-- apps/app2/index.html
-rw-r--r-- apps/app3/index.html
```

**Check each has different color:**
```bash
grep "background:" apps/app1/index.html
grep "background:" apps/app2/index.html
grep "background:" apps/app3/index.html
```

**Expected:**
```
background: #667eea;  ← Blue/purple
background: #11998e;  ← Green
background: #f093fb;  ← Pink
```

✅ **All HTML files ready!**

---

## **Phase 2: Build Kubernetes Deployment (App1 Only First)**

### **Step 2.1: Create Minimal Deployment for App1**

```bash
nano confs/deployment.yaml
```

**Type this MINIMAL deployment (ONLY App1 for now):**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1-deployment
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
      - name: nginx
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
```

**Save (Ctrl+O, Enter), DON'T close yet!**

---

### **Step 2.2: Understanding Each Section**

**Let's break it down:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1-deployment
```
**What:** This creates a Deployment named "app1-deployment"

```yaml
spec:
  replicas: 1
```
**What:** Run 1 copy of the pod  
**Test later:** We'll change this to see scaling

```yaml
  selector:
    matchLabels:
      app: app1
  template:
    metadata:
      labels:
        app: app1
```
**What:** Deployment finds pods with label `app: app1`  
**Why:** This is how Deployment knows which pods it manages

```yaml
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
```
**What:** Run nginx:alpine container  
**Why:** Nginx serves HTML files

```yaml
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        hostPath:
          path: /vagrant/apps/app1
```
**What:** Mount `/vagrant/apps/app1` from VM into container  
**Why:** So nginx serves OUR HTML, not default nginx page

---

### **Step 2.3: Add App1 Service**

**In the SAME file, add below (after Deployment):**

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: app1-service
spec:
  selector:
    app: app1
  ports:
  - port: 80
    targetPort: 80
```

**Save and close (Ctrl+O, Enter, Ctrl+X)**

---

### **Step 2.4: Validate YAML Syntax**

```bash
cat confs/deployment.yaml
```

**Check:**
- ✅ Consistent indentation (2 spaces)
- ✅ `---` separator between Deployment and Service
- ✅ No weird characters

**Count resources:**
```bash
grep -c "^kind:" confs/deployment.yaml
```

**Should show:** `2` (1 Deployment + 1 Service)

✅ **YAML looks good!**

---

## **Phase 3: Create Minimal Vagrantfile**

### **Step 3.1: Create Vagrantfile (Manual Deployment First)**

```bash
nano Vagrantfile
```

**Type this (we'll deploy manually first, no automation):**

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  
  config.vm.define "hed-dybS" do |server|
    server.vm.hostname = "hed-dybS"
    server.vm.network "private_network", ip: "192.168.56.110"
    
    server.vm.provider "virtualbox" do |vb|
      vb.name = "hed-dybS"
      vb.memory = "2048"
      vb.cpus = 2
    end
    
    server.vm.synced_folder "./apps", "/vagrant/apps"
    
    server.vm.provision "shell", inline: <<-SHELL
      echo "Installing K3s..."
      curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644
      
      echo "Waiting for K3s..."
      sleep 20
      
      echo "✅ K3s installed!"
      echo "Run: vagrant ssh hed-dybS"
      echo "Then: kubectl get nodes"
    SHELL
  end
end
```

**Save.**

---

### **Step 3.2: Understanding Vagrantfile**

```ruby
config.vm.box = "ubuntu/jammy64"
```
**What:** Use Ubuntu 22.04 LTS

```ruby
server.vm.hostname = "hed-dybS"
```
**What:** VM hostname (your login + S)

```ruby
server.vm.network "private_network", ip: "192.168.56.110"
```
**What:** Static IP  
**Why:** This is where we'll access apps from browser

```ruby
vb.memory = "2048"
vb.cpus = 2
```
**What:** 2GB RAM, 2 CPUs  
**Why:** K3s needs ~512MB, apps need rest

```ruby
server.vm.synced_folder "./apps", "/vagrant/apps"
```
**What:** Share local `./apps` with VM  
**Why:** So pods can access HTML files

```ruby
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644
```
**What:** Install K3s  
**Why:** `--write-kubeconfig-mode 644` makes kubectl config readable

---

### **Step 3.3: Validate Vagrantfile**

```bash
vagrant validate
```

**Expected:** `Vagrantfile validated successfully.`

✅ **Vagrantfile ready!**

---

## **Phase 4: First VM Boot - Install K3s**

### **Step 4.1: Start VM**

```bash
vagrant up
```

**Watch output carefully! You'll see:**

```
==> hed-dybS: Importing base box...
```
**Time:** ~30 seconds

```
==> hed-dybS: Preparing network interfaces...
    hed-dybS: Adapter 1: nat
    hed-dybS: Adapter 2: hostonly
```
**What:** Network setup

```
==> hed-dybS: Mounting shared folders...
    hed-dybS: /vagrant => /home/hassan/.../p2
    hed-dybS: /vagrant/apps => /home/hassan/.../p2/apps
```
**What:** Your apps folder is shared!

```
==> hed-dybS: Running provisioner: shell...
Installing K3s...
[INFO]  Finding release for channel stable
[INFO]  Using v1.33.6+k3s1 as release
[INFO]  Downloading binary...
```
**Time:** 1-2 minutes (downloading K3s)

```
[INFO]  systemd: Starting k3s
Waiting for K3s...
✅ K3s installed!
```

**Success!**

---

### **Step 4.2: SSH into VM**

```bash
vagrant ssh hed-dybS
```

**You're now INSIDE the VM!**

---

### **Step 4.3: Test K3s is Running**

```bash
kubectl get nodes
```

**Expected:**
```
NAME       STATUS   ROLES                  AGE   VERSION
hed-dybs   Ready    control-plane,master   2m    v1.33.6+k3s1
```

✅ **K3s works!**

---

### **Step 4.4: Check What's Running**

```bash
kubectl get pods -A
```

**Expected:**
```
NAMESPACE     NAME                      READY   STATUS
kube-system   coredns-xxx               1/1     Running
kube-system   traefik-xxx               1/1     Running
kube-system   metrics-server-xxx        1/1     Running
kube-system   local-path-provisioner    1/1     Running
```

**❓ What are these?**
- **traefik**: Ingress controller (we need this!)
- **coredns**: DNS for cluster
- **metrics-server**: Resource monitoring
- **local-path**: Storage

✅ **Traefik is running! (we'll use it later)**

---

### **Step 4.5: Check No Apps Deployed Yet**

```bash
kubectl get all
```

**Expected:**
```
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.43.0.1    <none>        443/TCP   2m
```

**Only default kubernetes service, no apps yet.**

✅ **Clean slate!**

---

## **Phase 5: Deploy App1 Manually**

### **Step 5.1: Check YAML is Accessible**

```bash
ls -l /vagrant/confs/deployment.yaml
```

**Should show the file.**

**View it:**
```bash
cat /vagrant/confs/deployment.yaml
```

**Should show your Deployment and Service.**

---

### **Step 5.2: Apply Deployment**

```bash
kubectl apply -f /vagrant/confs/deployment.yaml
```

**Expected:**
```
deployment.apps/app1-deployment created
service/app1-service created
```

✅ **Resources created!**

---

### **Step 5.3: Watch Pod Start**

```bash
kubectl get pods --watch
```

**You'll see:**
```
NAME                               READY   STATUS
app1-deployment-xxxxxxxxxx-yyyyy   0/1     ContainerCreating
```

**Wait 10-20 seconds...**

```
NAME                               READY   STATUS
app1-deployment-xxxxxxxxxx-yyyyy   1/1     Running
```

**Press Ctrl+C**

✅ **Pod is running!**

---

### **Step 5.4: Check Deployment**

```bash
kubectl get deployment
```

**Expected:**
```
NAME              READY   UP-TO-DATE   AVAILABLE   AGE
app1-deployment   1/1     1            1           30s
```

**What `1/1` means:**
- First `1`: Current replicas running
- Second `1`: Desired replicas

---

### **Step 5.5: Check Service**

```bash
kubectl get service
```

**Expected:**
```
NAME           TYPE        CLUSTER-IP      PORT(S)   AGE
app1-service   ClusterIP   10.43.123.45    80/TCP    40s
kubernetes     ClusterIP   10.43.0.1       443/TCP   5m
```

**Note the CLUSTER-IP (e.g., `10.43.123.45`)**

---

### **Step 5.6: Test Pod Directly**

**Get pod IP:**
```bash
kubectl get pod -o wide
```

**Expected:**
```
NAME                    READY   STATUS    IP          NODE
app1-deployment-xxx     1/1     Running   10.42.0.8   hed-dybs
```

**Note the IP (e.g., `10.42.0.8`)**

**Test pod directly:**
```bash
curl http://10.42.0.8
```

**Expected:** Your App1 HTML! (Blue background, "App 1" title)

**Extract just title:**
```bash
curl -s http://10.42.0.8 | grep "<h1>"
```

**Should show:** `<h1>App 1</h1>`

✅ **Pod serves your HTML!**

---

### **Step 5.7: Test Service**

**Use the Service CLUSTER-IP from earlier:**
```bash
curl http://10.43.123.45
```

**Expected:** Same App1 HTML

**Why test Service separately?**
- Pod IP changes if pod restarts
- Service IP stays stable

✅ **Service works!**

---

### **Step 5.8: Test Self-Healing**

**Delete the pod:**
```bash
kubectl delete pod app1-deployment-xxxxxxxxxx-yyyyy
```

**Immediately check:**
```bash
kubectl get pods --watch
```

**You'll see:**
```
NAME                    READY   STATUS        AGE
app1-deployment-xxx     1/1     Terminating   2m
app1-deployment-NEW     0/1     Pending       1s
app1-deployment-NEW     1/1     Running       15s
```

**Press Ctrl+C**

**❓ What happened?**
- Deployment noticed: "I want 1 replica, but I have 0!"
- Deployment created new pod automatically

✅ **Self-healing works!**

---

## **Phase 6: Add Ingress for App1**

### **Step 6.1: Create Ingress YAML**

**Exit VM:**
```bash
exit
```

**Create ingress file:**
```bash
nano confs/ingress.yaml
```

**Type:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: apps-ingress
spec:
  rules:
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
```

**Save.**

---

### **Step 6.2: Understanding Ingress**

```yaml
- host: app1.com
```
**What:** If request has `Host: app1.com` header...

```yaml
  backend:
    service:
      name: app1-service
```
**What:** ...route to `app1-service`

**Flow:**
```
Browser → Traefik (reads Host header)
       → Sees "app1.com"
       → Routes to app1-service
       → Service picks a pod
       → Pod serves HTML
```

---

### **Step 6.3: Apply Ingress**

```bash
vagrant ssh hed-dybS
```

```bash
kubectl apply -f /vagrant/confs/ingress.yaml
```

**Expected:**
```
ingress.networking.k8s.io/apps-ingress created
```

---

### **Step 6.4: Check Ingress**

```bash
kubectl get ingress
```

**Expected:**
```
NAME           CLASS     HOSTS      ADDRESS         PORTS   AGE
apps-ingress   traefik   app1.com   192.168.56.110  80      10s
```

**❓ Key info:**
- **CLASS**: traefik (using Traefik ingress controller)
- **HOSTS**: app1.com (hostname it responds to)
- **ADDRESS**: 192.168.56.110 (VM IP)

✅ **Ingress created!**

---

### **Step 6.5: Test from Inside VM**

```bash
curl -H "Host: app1.com" http://localhost
```

**Expected:** Your App1 HTML

**Why `-H "Host: app1.com"`?**
- We're faking the hostname
- Ingress routes based on Host header

**Extract title:**
```bash
curl -s -H "Host: app1.com" http://localhost | grep "<h1>"
```

**Should show:** `<h1>App 1</h1>`

✅ **Ingress routes correctly!**

---

### **Step 6.6: Test from Host Machine**

**Exit VM:**
```bash
exit
```

**Add to /etc/hosts:**
```bash
sudo nano /etc/hosts
```

**Add at the END:**
```
192.168.56.110  app1.com
```

**Save.**

**Test:**
```bash
curl http://app1.com
```

**Expected:** App1 HTML

**Extract title:**
```bash
curl -s http://app1.com | grep "<h1>"
```

**Should show:** `<h1>App 1</h1>`

✅ **External access works!**

---

### **Step 6.7: Test in Browser**

**Open browser:** `http://app1.com`

**Expected:**
- Blue background
- "App 1" title
- "Host: app1.com" text

✅ **Browser access works!**

---

## **Phase 7: Scale to 3 Replicas (Practice)**

### **Step 7.1: Scale App1 to 3**

```bash
vagrant ssh hed-dybS
```

```bash
kubectl scale deployment app1-deployment --replicas=3
```

**Watch:**
```bash
kubectl get pods --watch
```

**You'll see 3 pods start:**
```
NAME                    READY   STATUS
app1-deployment-xxx     1/1     Running
app1-deployment-yyy     0/1     Pending
app1-deployment-zzz     0/1     Pending
```

**Wait 10 seconds...**

```
app1-deployment-yyy     1/1     Running
app1-deployment-zzz     1/1     Running
```

**Press Ctrl+C**

---

### **Step 7.2: Check Service Endpoints**

```bash
kubectl get endpoints app1-service
```

**Expected:**
```
NAME           ENDPOINTS
app1-service   10.42.0.8:80,10.42.0.9:80,10.42.0.10:80
```

**❓ What does this mean?**
- Service has 3 backend pods
- Traffic load-balances across all 3

---

### **Step 7.3: Test Load Balancing**

```bash
for i in {1..6}; do
  curl -s -H "Host: app1.com" http://localhost | grep "<h1>"
done
```

**Expected:** All show `<h1>App 1</h1>`

**❓ Which pod handled each request?**
- Service picks randomly
- All 3 pods serve same content
- This is **load balancing**!

---

### **Step 7.4: Scale Back to 1**

```bash
kubectl scale deployment app1-deployment --replicas=1
```

**Check:**
```bash
kubectl get pods
```

**Expected:** Only 1 pod remains

---

## **Phase 8: Add App2 with 3 Replicas**

### **Step 8.1: Exit VM and Edit Deployment**

```bash
exit
```

```bash
nano confs/deployment.yaml
```

**Add App2 Deployment at the END:**

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app2-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app2
  template:
    metadata:
      labels:
        app: app2
    spec:
      containers:
      - name: nginx
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
---
apiVersion: v1
kind: Service
metadata:
  name: app2-service
spec:
  selector:
    app: app2
  ports:
  - port: 80
    targetPort: 80
```

**Save.**

---

### **Step 8.2: Update Ingress**

```bash
nano confs/ingress.yaml
```

**Add app2.com rule:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: apps-ingress
spec:
  rules:
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
```

**Save.**

---

### **Step 8.3: Apply Changes**

```bash
vagrant ssh hed-dybS
```

```bash
kubectl apply -f /vagrant/confs/deployment.yaml
kubectl apply -f /vagrant/confs/ingress.yaml
```

**Expected:**
```
deployment.apps/app1-deployment unchanged
service/app1-service unchanged
deployment.apps/app2-deployment created
service/app2-service created
ingress.networking.k8s.io/apps-ingress configured
```

---

### **Step 8.4: Check App2 Pods**

```bash
kubectl get pods -l app=app2
```

**Expected:**
```
NAME                    READY   STATUS    AGE
app2-deployment-xxx     1/1     Running   20s
app2-deployment-yyy     1/1     Running   20s
app2-deployment-zzz     1/1     Running   20s
```

**Count:**
```bash
kubectl get pods -l app=app2 | grep -c Running
```

**Should show:** `3`

✅ **App2 has 3 replicas!**

---

### **Step 8.5: Test App2**

```bash
curl -s -H "Host: app2.com" http://localhost | grep "<h1>"
```

**Should show:** `<h1>App 2</h1>`

**Check replica mention:**
```bash
curl -s -H "Host: app2.com" http://localhost | grep Replicas
```

**Should show:** `<p>3 Replicas</p>`

---

### **Step 8.6: Test from Host Machine**

```bash
exit
```

**Add to /etc/hosts:**
```bash
sudo nano /etc/hosts
```

**Add:**
```
192.168.56.110  app2.com
```

**Save.**

**Test:**
```bash
curl -s http://app2.com | grep "<h1>"
```

**Should show:** `<h1>App 2</h1>`

**Browser test:** `http://app2.com`

**Expected:**
- Green background
- "App 2" title
- "3 Replicas" text

✅ **App2 works with 3 replicas!**

---

## **Phase 9: Add App3 (Default Route)**

### **Step 9.1: Add App3 to Deployment**

```bash
nano confs/deployment.yaml
```

**Add App3 at the END:**

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app3-deployment
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
      - name: nginx
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
---
apiVersion: v1
kind: Service
metadata:
  name: app3-service
spec:
  selector:
    app: app3
  ports:
  - port: 80
    targetPort: 80
```

**Save.**

---

### **Step 9.2: Update Ingress with Default Route**

```bash
nano confs/ingress.yaml
```

**Add default rule at the END:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: apps-ingress
spec:
  rules:
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

**Notice:** Last rule has NO `host:` = default route!

**Save.**

---

### **Step 9.3: Apply Changes**

```bash
vagrant ssh hed-dybS
```

```bash
kubectl apply -f /vagrant/confs/deployment.yaml
kubectl apply -f /vagrant/confs/ingress.yaml
```

---

### **Step 9.4: Check All Apps**

```bash
kubectl get deployments
```

**Expected:**
```
NAME              READY   UP-TO-DATE   AVAILABLE   AGE
app1-deployment   1/1     1            1           10m
app2-deployment   3/3     3            3           5m
app3-deployment   1/1     1            1           30s
```

✅ **All 3 apps deployed!**

---

### **Step 9.5: Test Default Route**

```bash
curl -s http://localhost | grep "<h1>"
```

**Should show:** `<h1>App 3</h1>`

**❓ Why App3?**
- No Host header provided
- Ingress uses default route
- Default route points to app3-service

---

### **Step 9.6: Test All Routes**

```bash
curl -s -H "Host: app1.com" http://localhost | grep "<h1>"
curl -s -H "Host: app2.com" http://localhost | grep "<h1>"
curl -s http://localhost | grep "<h1>"
```

**Expected:**
```
<h1>App 1</h1>
<h1>App 2</h1>
<h1>App 3</h1>
```

✅ **All routes work!**

---

### **Step 9.7: Test from Host Machine**

```bash
exit
```

**Test with IP (no hostname):**
```bash
curl -s http://192.168.56.110 | grep "<h1>"
```

**Should show:** `<h1>App 3</h1>`

**Browser test:** `http://192.168.56.110`

**Expected:**
- Pink background
- "App 3" title
- "Default App" text

✅ **Default route works from outside!**

---

## **Phase 10: Automate with Script**

### **Step 10.1: Create server.sh**

```bash
nano scripts/server.sh
```

**Type:**

```bash
#!/bin/bash

set -e

echo "=========================================="
echo "  P2 Server Setup"
echo "=========================================="

# Install K3s
echo "[1/4] Installing K3s..."
curl -sfL https://get.k3s.io | sh -s - \
  --write-kubeconfig-mode 644 \
  --node-name hed-dybS

# Wait for K3s
echo "[2/4] Waiting for K3s..."
sleep 20

# Wait for Traefik
echo "[3/4] Waiting for Traefik..."
until kubectl get deployment traefik -n kube-system &>/dev/null; do
  sleep 5
done
kubectl wait --namespace kube-system \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=traefik \
  --timeout=180s

# Deploy apps
echo "[4/4] Deploying applications..."
kubectl apply -f /vagrant/confs/deployment.yaml
kubectl apply -f /vagrant/confs/ingress.yaml

# Wait for apps
kubectl wait --for=condition=available --timeout=180s \
  deployment/app1-deployment \
  deployment/app2-deployment \
  deployment/app3-deployment

echo "=========================================="
echo "✅ Setup complete!"
echo "=========================================="
kubectl get deployments
kubectl get ingress
kubectl get pods
```

**Save.**

---

### **Step 10.2: Make Executable**

```bash
chmod +x scripts/server.sh
```

---

### **Step 10.3: Update Vagrantfile**

```bash
nano Vagrantfile
```

**Change provisioning to use script:**

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  
  config.vm.define "hed-dybS" do |server|
    server.vm.hostname = "hed-dybS"
    server.vm.network "private_network", ip: "192.168.56.110"
    
    server.vm.provider "virtualbox" do |vb|
      vb.name = "hed-dybS"
      vb.memory = "2048"
      vb.cpus = 2
    end
    
    server.vm.synced_folder "./apps", "/vagrant/apps"
    server.vm.provision "shell", path: "scripts/server.sh"
  end
end
```

**Save.**

---

## **Phase 11: Test Full Automation**

### **Step 11.1: Destroy Current VM**

```bash
vagrant destroy -f
```

---

### **Step 11.2: Rebuild from Scratch**

```bash
vagrant up
```

**Watch output - should complete automatically in ~3-5 minutes!**

---

### **Step 11.3: Verify Everything**

```bash
vagrant ssh hed-dybS
```

**Check all apps:**
```bash
kubectl get all
```

**Expected:**
- 1 app1 pod
- 3 app2 pods
- 1 app3 pod

**Exit:**
```bash
exit
```

---

### **Step 11.4: Final Browser Tests**

**Test all 3:**
1. `http://app1.com` → Blue, "App 1"
2. `http://app2.com` → Green, "App 2", "3 Replicas"
3. `http://192.168.56.110` → Pink, "App 3", "Default App"

✅ **ALL WORKING!**

---

## **✅ Final Summary**

### **What You Built:**
- [x] 3 simple HTML apps
- [x] 3 Kubernetes Deployments
- [x] 3 Kubernetes Services
- [x] 1 Ingress with hostname routing
- [x] App2 has 3 replicas
- [x] App3 is default route
- [x] Full automation script

### **What You Learned:**
- [x] Pods (smallest unit)
- [x] Deployments (manage pods)
- [x] Services (stable networking)
- [x] Ingress (external routing)
- [x] Replicas (high availability)
- [x] Self-healing (auto-recreate pods)
- [x] Load balancing (traffic distribution)

### **Testing Commands You Used:**
```bash
kubectl get pods
kubectl get deployments
kubectl get services
kubectl get ingress
kubectl get pods -l app=app2
kubectl scale deployment --replicas=3
kubectl describe ingress
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- /bin/sh
curl -H "Host: app1.com" http://localhost
```

---

## **🎉 Congratulations!**

**You built it step-by-step, tested every piece, and understand how it all works!**

**Project structure:**
```
p2/
├── Vagrantfile
├── apps/
│   ├── app1/index.html
│   ├── app2/index.html
│   └── app3/index.html
├── confs/
│   ├── deployment.yaml
│   └── ingress.yaml
└── scripts/
    └── server.sh
```

**Ready for evaluation!** 🚀