# 🚀 PART 3: K3d + Argo CD - COMPLETE HANDS-ON GUIDE

**Goal:** Reverse engineer p3 by building it piece by piece with extensive testing!

---

## **📋 What We're Building**

```
ref/p3/
├── scripts/
│   ├── k3d.sh        ← Install Docker, kubectl, K3d, create cluster
│   ├── argocd.sh     ← Install Argo CD, create namespaces
│   └── init.sh       ← Deploy application via Argo CD
└── confs/
    └── deploy.yaml   ← Argo CD Application definition

GitHub repo (wil_app):
└── manifests/
    └── application.yaml  ← Kubernetes deployment (v1/v2)
```

---

## **🎯 Final Architecture**

```
Your Machine
    │
    ├─> Docker
    │     └─> K3d Cluster (hed-dybS)
    │           ├─> Namespace: argocd
    │           │     └─> Argo CD Pods (GitOps engine)
    │           │           │
    │           │           │ Watches GitHub repo
    │           │           ▼
    │           └─> Namespace: dev
    │                 └─> wil-app Pod (v1 or v2)
    │
    ├─> Browser → localhost:8085 (Argo CD UI)
    └─> Browser → localhost:8888 (wil-app)

GitHub Repository
    └─> manifests/application.yaml
          image: wil42/playground:v1  (can change to v2)
```

---

## **Phase 0: Clean Slate**

### **Step 0.1: Remove Old Clusters**

```bash
# List existing k3d clusters
k3d cluster list
```

**Expected:**
```
NAME   SERVERS   AGENTS   LOADBALANCER
```

**If you see old clusters:**

```bash
k3d cluster delete <cluster-name>
```

---

### **Step 0.2: Clean Docker**

```bash
# Stop all containers
docker stop $(docker ps -aq) 2>/dev/null

# Remove all containers
docker rm $(docker ps -aq) 2>/dev/null

# Verify clean
docker ps -a
```

**Expected:**
```
CONTAINER ID   IMAGE   COMMAND   CREATED   STATUS   PORTS   NAMES
```

✅ **Clean slate!**

---

### **Step 0.3: Create Project Structure**

```bash
cd ~/Desktop/inceptionOfThings/iot
mkdir -p p3/{scripts,confs}
cd p3
```

**Verify:**

```bash
tree
```

**Expected:**
```
.
├── confs
└── scripts

2 directories, 0 files
```

---

## **Phase 1: Install Prerequisites (k3d.sh)**

### **Step 1.1: Analyze Reference Script**

```bash
cat ~/Desktop/inceptionOfThings/ref/p3/scripts/k3d.sh
```

**What it does:**
1. Updates apt packages
2. Installs Docker
3. Installs kubectl
4. Installs K3d
5. Creates K3d cluster named `buthorS`

**Let's build this step-by-step!**

---

### **Step 1.2: Create k3d.sh Script (Empty)**

```bash
nano scripts/k3d.sh
```

**Add shebang:**

```bash
#!/bin/bash

echo "Starting Part 3 Setup..."
```

**Save (Ctrl+O, Enter, Ctrl+X)**

**Make executable:**

```bash
chmod +x scripts/k3d.sh
```

**Test:**

```bash
./scripts/k3d.sh
```

**Expected:**
```
Starting Part 3 Setup...
```

✅ **Script skeleton works!**

---

### **Step 1.3: Add Docker Installation**

```bash
nano scripts/k3d.sh
```

**Add:**

```bash
#!/bin/bash

set -e  # Exit on error

echo "============================================"
echo "     Part 3: K3d + Argo CD Setup"
echo "============================================"

echo ""
echo "[1/5] Installing Docker..."

# Check if Docker already installed
if command -v docker &> /dev/null; then
    echo "Docker already installed: $(docker --version)"
else
    # Download and install Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    
    echo "Docker installed successfully!"
    echo "Note: You may need to logout/login for docker group to take effect"
fi

# Verify Docker
docker --version
```

**Save**

**Run:**

```bash
./scripts/k3d.sh
```

**Expected output:**
```
============================================
     Part 3: K3d + Argo CD Setup
============================================

[1/5] Installing Docker...
Docker already installed: Docker version 24.0.7, build ...
```

**Or if not installed:**
```
[1/5] Installing Docker...
# ... installation output ...
Docker installed successfully!
Docker version 24.0.7, build ...
```

**Test Docker manually:**

```bash
docker run hello-world
```

**Expected:**
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

✅ **Docker working!**

---

### **Step 1.4: Add kubectl Installation**

```bash
nano scripts/k3d.sh
```

**Add after Docker section:**

```bash
echo ""
echo "[2/5] Installing kubectl..."

# Check if kubectl already installed
if command -v kubectl &> /dev/null; then
    echo "kubectl already installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
else
    # Download kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    
    # Verify checksum (optional but good practice)
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    
    # Install kubectl
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    
    # Cleanup
    rm kubectl kubectl.sha256
    
    echo "kubectl installed successfully!"
fi

# Verify kubectl
kubectl version --client
```

**Save**

**Run:**

```bash
./scripts/k3d.sh
```

**Expected:**
```
[2/5] Installing kubectl...
kubectl already installed: v1.31.4
```

**Or if installing:**
```
[2/5] Installing kubectl...
kubectl: OK
kubectl installed successfully!
Client Version: v1.31.4
```

**Test kubectl:**

```bash
kubectl version --client
```

**Expected:**
```
Client Version: v1.31.4
Kustomize Version: v5.4.2
```

✅ **kubectl working!**

---

### **Step 1.5: Add K3d Installation**

```bash
nano scripts/k3d.sh
```

**Add after kubectl section:**

```bash
echo ""
echo "[3/5] Installing K3d..."

# Check if k3d already installed
if command -v k3d &> /dev/null; then
    echo "K3d already installed: $(k3d version | head -n1)"
else
    # Install k3d
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    
    echo "K3d installed successfully!"
fi

# Verify k3d
k3d version
```

**Save**

**Run:**

```bash
./scripts/k3d.sh
```

**Expected:**
```
[3/5] Installing K3d...
K3d already installed: k3d version v5.7.4
```

**Or if installing:**
```
[3/5] Installing K3d...
Preparing to install k3d into /usr/local/bin
k3d installed into /usr/local/bin/k3d
K3d installed successfully!
k3d version v5.7.4
k3s version v1.30.6-k3s1 (default)
```

**Test k3d:**

```bash
k3d version
```

**Expected:**
```
k3d version v5.7.4
k3s version v1.30.6-k3s1 (default)
```

✅ **K3d working!**

---

### **Step 1.6: Add Cluster Creation**

```bash
nano scripts/k3d.sh
```

**Add after K3d installation:**

```bash
echo ""
echo "[4/5] Creating K3d cluster..."

CLUSTER_NAME="hed-dybS"

# Check if cluster already exists
if k3d cluster list | grep -q "$CLUSTER_NAME"; then
    echo "Cluster '$CLUSTER_NAME' already exists"
    echo "Deleting old cluster..."
    k3d cluster delete $CLUSTER_NAME
fi

# Create cluster
echo "Creating cluster '$CLUSTER_NAME'..."
k3d cluster create $CLUSTER_NAME

echo ""
echo "[5/5] Verifying cluster..."

# Wait for cluster to be ready
sleep 5

# Check nodes
kubectl get nodes

echo ""
echo "============================================"
echo "     K3d Setup Complete!"
echo "============================================"
echo ""
echo "Cluster: $CLUSTER_NAME"
echo "Nodes: $(kubectl get nodes --no-headers | wc -l)"
echo ""
echo "Next step: Run argocd.sh to install Argo CD"
echo ""
```

**Save**

**Run full script:**

```bash
./scripts/k3d.sh
```

**Expected output:**
```
============================================
     Part 3: K3d + Argo CD Setup
============================================

[1/5] Installing Docker...
Docker already installed: Docker version 24.0.7

[2/5] Installing kubectl...
kubectl already installed: v1.31.4

[3/5] Installing K3d...
K3d already installed: k3d version v5.7.4

[4/5] Creating K3d cluster...
Creating cluster 'hed-dybS'...
INFO[0000] Prep: Network
INFO[0000] Created network 'k3d-hed-dybS'
INFO[0000] Created image volume k3d-hed-dybS-images
INFO[0000] Starting new tools node...
INFO[0001] Creating node 'k3d-hed-dybS-server-0'
INFO[0002] Pulling image 'ghcr.io/k3d-io/k3s:v1.30.6-k3s1'
INFO[0010] Starting Node 'k3d-hed-dybS-server-0'
INFO[0015] All agents already running.
INFO[0015] All helpers already running.
INFO[0015] Cluster 'hed-dybS' created successfully!

[5/5] Verifying cluster...
NAME                     STATUS   ROLES                  AGE   VERSION
k3d-hed-dybs-server-0    Ready    control-plane,master   10s   v1.30.6+k3s1

============================================
     K3d Setup Complete!
============================================

Cluster: hed-dybS
Nodes: 1

Next step: Run argocd.sh to install Argo CD
```

✅ **K3d cluster created!**

---

### **Step 1.7: Test Cluster Manually**

```bash
# List clusters
k3d cluster list
```

**Expected:**
```
NAME       SERVERS   AGENTS   LOADBALANCER
hed-dybS   1/1       0/0      true
```

---

```bash
# List nodes
kubectl get nodes
```

**Expected:**
```
NAME                     STATUS   ROLES                  AGE   VERSION
k3d-hed-dybs-server-0    Ready    control-plane,master   2m    v1.30.6+k3s1
```

---

```bash
# Check namespaces
kubectl get namespaces
```

**Expected:**
```
NAME              STATUS   AGE
default           Active   2m
kube-system       Active   2m
kube-public       Active   2m
kube-node-lease   Active   2m
```

---

```bash
# Check pods in all namespaces
kubectl get pods -A
```

**Expected:**
```
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE
kube-system   coredns-...                               1/1     Running   0          2m
kube-system   local-path-provisioner-...                1/1     Running   0          2m
kube-system   metrics-server-...                        1/1     Running   0          2m
kube-system   traefik-...                               1/1     Running   0          2m
```

✅ **Cluster healthy!**

---

```bash
# Test creating a pod
kubectl run test-nginx --image=nginx
kubectl get pods
```

**Expected:**
```
NAME         READY   STATUS    RESTARTS   AGE
test-nginx   1/1     Running   0          5s
```

---

```bash
# Delete test pod
kubectl delete pod test-nginx
```

**Expected:**
```
pod "test-nginx" deleted
```

✅ **Cluster fully functional!**

---

## **Phase 2: Install Argo CD (argocd.sh)**

### **Step 2.1: Analyze Reference Script**

```bash
cat ~/Desktop/inceptionOfThings/ref/p3/scripts/argocd.sh
```

**What it does:**
1. Creates `argocd` namespace
2. Creates `dev` namespace
3. Installs Argo CD in `argocd` namespace
4. Adds hosts entry for `argocd.mydomain.com`
5. Waits for all Argo CD pods to be ready
6. Gets Argo CD admin password
7. Port-forwards Argo CD UI to localhost:8085

**Let's build it!**

---

### **Step 2.2: Create argocd.sh (Empty)**

```bash
nano scripts/argocd.sh
```

**Add:**

```bash
#!/bin/bash

set -e

echo "============================================"
echo "     Installing Argo CD"
echo "============================================"
```

**Save**

**Make executable:**

```bash
chmod +x scripts/argocd.sh
```

---

### **Step 2.3: Add Namespace Creation**

```bash
nano scripts/argocd.sh
```

**Add:**

```bash
#!/bin/bash

set -e

GREEN="\033[32m"
RED="\033[31m"
BLUE="\033[34m"
RESET="\033[0m"

echo "============================================"
echo "     Installing Argo CD"
echo "============================================"

echo ""
echo "[1/6] Creating namespaces..."

# Create argocd namespace
if kubectl get namespace argocd &> /dev/null; then
    echo "Namespace 'argocd' already exists"
else
    kubectl create namespace argocd
    echo "Created namespace 'argocd'"
fi

# Create dev namespace
if kubectl get namespace dev &> /dev/null; then
    echo "Namespace 'dev' already exists"
else
    kubectl create namespace dev
    echo "Created namespace 'dev'"
fi

# Verify namespaces
echo ""
echo "Current namespaces:"
kubectl get namespaces
```

**Save**

**Run:**

```bash
./scripts/argocd.sh
```

**Expected:**
```
============================================
     Installing Argo CD
============================================

[1/6] Creating namespaces...
Created namespace 'argocd'
Created namespace 'dev'

Current namespaces:
NAME              STATUS   AGE
default           Active   5m
kube-system       Active   5m
kube-public       Active   5m
kube-node-lease   Active   5m
argocd            Active   1s
dev               Active   1s
```

**Test manually:**

```bash
kubectl get namespaces
```

**Expected:**
```
NAME              STATUS   AGE
default           Active   5m
kube-system       Active   5m
kube-public       Active   5m
kube-node-lease   Active   5m
argocd            Active   1m
dev               Active   1m
```

✅ **Namespaces created!**

---

### **Step 2.4: Add Argo CD Installation**

```bash
nano scripts/argocd.sh
```

**Add after namespace creation:**

```bash
echo ""
echo "[2/6] Installing Argo CD..."

# Check if Argo CD already installed
if kubectl get deployment argocd-server -n argocd &> /dev/null; then
    echo "Argo CD already installed"
else
    echo "Downloading Argo CD manifests..."
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    echo "Argo CD installation started"
fi
```

**Save**

**Run:**

```bash
./scripts/argocd.sh
```

**Expected:**
```
[2/6] Installing Argo CD...
Downloading Argo CD manifests...
customresourcedefinition.apiextensions.k8s.io/applications.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/applicationsets.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/appprojects.argoproj.io created
serviceaccount/argocd-application-controller created
serviceaccount/argocd-applicationset-controller created
serviceaccount/argocd-dex-server created
serviceaccount/argocd-notifications-controller created
serviceaccount/argocd-redis created
serviceaccount/argocd-repo-server created
serviceaccount/argocd-server created
role.rbac.authorization.k8s.io/argocd-application-controller created
... (many more resources)
deployment.apps/argocd-server created
deployment.apps/argocd-repo-server created
deployment.apps/argocd-dex-server created
deployment.apps/argocd-redis created
deployment.apps/argocd-applicationset-controller created
deployment.apps/argocd-notifications-controller created
statefulset.apps/argocd-application-controller created
Argo CD installation started
```

**Check Argo CD pods:**

```bash
kubectl get pods -n argocd
```

**Expected (pods creating):**
```
NAME                                                READY   STATUS              RESTARTS   AGE
argocd-application-controller-0                     0/1     ContainerCreating   0          10s
argocd-applicationset-controller-...                0/1     ContainerCreating   0          10s
argocd-dex-server-...                               0/1     Init:0/1            0          10s
argocd-notifications-controller-...                 0/1     ContainerCreating   0          10s
argocd-redis-...                                    0/1     ContainerCreating   0          10s
argocd-repo-server-...                              0/1     Init:0/1            0          10s
argocd-server-...                                   0/1     ContainerCreating   0          10s
```

**Wait 30 seconds and check again:**

```bash
sleep 30
kubectl get pods -n argocd
```

**Expected (pods running):**
```
NAME                                                READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                     1/1     Running   0          40s
argocd-applicationset-controller-...                1/1     Running   0          40s
argocd-dex-server-...                               1/1     Running   0          40s
argocd-notifications-controller-...                 1/1     Running   0          40s
argocd-redis-...                                    1/1     Running   0          40s
argocd-repo-server-...                              1/1     Running   0          40s
argocd-server-...                                   1/1     Running   0          40s
```

✅ **Argo CD pods running!**

---

### **Step 2.5: Add Waiting for Pods**

```bash
nano scripts/argocd.sh
```

**Add after Argo CD installation:**

```bash
echo ""
echo "[3/6] Waiting for Argo CD pods to be ready..."
echo "This may take 2-3 minutes..."

kubectl wait --for=condition=ready --timeout=600s pod --all -n argocd

echo -e "${GREEN}All Argo CD pods are ready!${RESET}"

# Show pod status
echo ""
echo "Argo CD pods:"
kubectl get pods -n argocd
```

**Save**

**Run:**

```bash
./scripts/argocd.sh
```

**Expected:**
```
[3/6] Waiting for Argo CD pods to be ready...
This may take 2-3 minutes...
pod/argocd-application-controller-0 condition met
pod/argocd-applicationset-controller-... condition met
pod/argocd-dex-server-... condition met
pod/argocd-notifications-controller-... condition met
pod/argocd-redis-... condition met
pod/argocd-repo-server-... condition met
pod/argocd-server-... condition met
All Argo CD pods are ready!

Argo CD pods:
NAME                                                READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                     1/1     Running   0          2m
argocd-applicationset-controller-...                1/1     Running   0          2m
argocd-dex-server-...                               1/1     Running   0          2m
argocd-notifications-controller-...                 1/1     Running   0          2m
argocd-redis-...                                    1/1     Running   0          2m
argocd-repo-server-...                              1/1     Running   0          2m
argocd-server-...                                   1/1     Running   0          2m
```

✅ **All pods ready!**

---

### **Step 2.6: Add /etc/hosts Entry**

```bash
nano scripts/argocd.sh
```

**Add:**

```bash
echo ""
echo "[4/6] Adding /etc/hosts entry..."

HOST_ENTRY="127.0.0.1 argocd.mydomain.com"
HOSTS_FILE="/etc/hosts"

if grep -q "argocd.mydomain.com" "$HOSTS_FILE"; then
    echo "/etc/hosts entry already exists"
else
    echo "Adding argocd.mydomain.com to /etc/hosts"
    echo "$HOST_ENTRY" | sudo tee -a "$HOSTS_FILE" > /dev/null
    echo "Entry added"
fi

# Verify
echo ""
echo "/etc/hosts content (argocd related):"
grep "argocd" /etc/hosts
```

**Save**

**Run:**

```bash
./scripts/argocd.sh
```

**Expected:**
```
[4/6] Adding /etc/hosts entry...
Adding argocd.mydomain.com to /etc/hosts
Entry added

/etc/hosts content (argocd related):
127.0.0.1 argocd.mydomain.com
```

**Test:**

```bash
cat /etc/hosts | grep argocd
```

**Expected:**
```
127.0.0.1 argocd.mydomain.com
```

✅ **/etc/hosts configured!**

---

### **Step 2.7: Get Argo CD Password**

```bash
nano scripts/argocd.sh
```

**Add:**

```bash
echo ""
echo "[5/6] Getting Argo CD admin password..."

PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode)

echo ""
echo "============================================"
echo -e "${GREEN}Argo CD Credentials:${RESET}"
echo "============================================"
echo -e "Username: ${BLUE}admin${RESET}"
echo -e "Password: ${GREEN}$PASSWORD${RESET}"
echo "============================================"
echo ""
```

**Save**

**Run:**

```bash
./scripts/argocd.sh
```

**Expected:**
```
[5/6] Getting Argo CD admin password...

============================================
Argo CD Credentials:
============================================
Username: admin
Password: xK8jP2mQrL9nVbH3
============================================
```

**Copy the password! You'll need it later.**

---

### **Step 2.8: Add Port Forwarding**

```bash
nano scripts/argocd.sh
```

**Add:**

```bash
echo "[6/6] Starting port forwarding..."

# Kill any existing port-forward on 8085
sudo pkill -f "port-forward.*8085" 2>/dev/null || true

# Start port-forward in background
kubectl port-forward svc/argocd-server -n argocd 8085:443 > /dev/null 2>&1 &

echo "Port forwarding started (PID: $!)"
echo ""
echo "============================================"
echo "     Argo CD Installation Complete!"
echo "============================================"
echo ""
echo -e "${GREEN}Access Argo CD UI:${RESET}"
echo "  http://localhost:8085"
echo "  OR"
echo "  https://argocd.mydomain.com:8085"
echo ""
echo -e "${GREEN}Login:${RESET}"
echo "  Username: admin"
echo "  Password: $PASSWORD"
echo ""
echo -e "${BLUE}Next step: Run init.sh to deploy application${RESET}"
echo ""
```

**Save**

**Run complete script:**

```bash
./scripts/argocd.sh
```

**Expected final output:**
```
[6/6] Starting port forwarding...
Port forwarding started (PID: 12345)

============================================
     Argo CD Installation Complete!
============================================

Access Argo CD UI:
  http://localhost:8085
  OR
  https://argocd.mydomain.com:8085

Login:
  Username: admin
  Password: xK8jP2mQrL9nVbH3

Next step: Run init.sh to deploy application
```

---

### **Step 2.9: Test Argo CD Access**

**Open browser:**

```
http://localhost:8085
```

**OR (if on remote VM):**

```bash
# Create SSH tunnel first
ssh -L 8085:localhost:8085 user@your-vm-ip
```

**Expected:**
- Argo CD login page
- Username: `admin`
- Password: (from script output)

**Login and you should see empty Argo CD dashboard!**

✅ **Argo CD UI accessible!**

---

### **Step 2.10: Test with curl**

```bash
# Accept self-signed cert
curl -k https://localhost:8085
```

**Expected:**
```html
<!doctype html><html lang="en"><head><meta charset="UTF-8">...
```

✅ **Argo CD responding!**

---

## **Phase 3: Create GitHub Repository**

### **Step 3.1: Understanding wil_app Structure**

```bash
tree ~/Desktop/inceptionOfThings/ref/wil_app/
```

**Expected:**
```
wil_app/
├── README.md
└── manifests/
    └── application.yaml
```

**Let's read the deployment:**

```bash
cat ~/Desktop/inceptionOfThings/ref/wil_app/manifests/application.yaml
```

**Contents:**
```yaml
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
        image: wil42/playground:v1  # ← VERSION HERE
        ports:
        - containerPort: 8888

---

apiVersion: v1
kind: Service
metadata:
  name: svc-wil
spec:
  selector:
    app: wil
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8888
```

**Key points:**
- Deployment named `wil` in `dev` namespace
- Uses image `wil42/playground:v1` (can change to `v2`)
- Service exposes on port 8080 → 8888

---

### **Step 3.2: Create GitHub Repository**

**Go to GitHub:**
1. Go to https://github.com
2. Click "New repository"
3. Name: `iot-hed-dyb` (or `iot-<yourlogin>`)
4. **Public** repository
5. Click "Create repository"

**Clone it:**

```bash
cd ~/Desktop/inceptionOfThings/iot/p3
git clone https://github.com/<your-username>/iot-hed-dyb.git
cd iot-hed-dyb
```

---

### **Step 3.3: Create manifests Folder**

```bash
mkdir manifests
```

---

### **Step 3.4: Create application.yaml**

```bash
nano manifests/application.yaml
```

**Copy from reference:**

```yaml
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
```

**Save**

---

### **Step 3.5: Push to GitHub**

```bash
git add manifests/
git commit -m "Add wil application v1"
git push origin main
```

**Verify on GitHub:**
- Go to your repo
- You should see application.yaml

✅ **GitHub repo ready!**

---

## **Phase 4: Deploy with Argo CD (init.sh)**

### **Step 4.1: Create deploy.yaml (Argo CD Application)**

```bash
cd ~/Desktop/inceptionOfThings/iot/p3
nano confs/deploy.yaml
```

**Important: Replace GitHub URL with YOUR repo!**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: wil-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/<your-username>/iot-hed-dyb.git  # ← YOUR REPO
    targetRevision: HEAD
    path: manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

**What this means:**
- `repoURL`: Your GitHub repo
- `path: manifests`: Folder with Kubernetes manifests
- `destination.namespace: dev`: Deploy to dev namespace
- `syncPolicy.automated`: Auto-sync when GitHub changes

**Save**

---

### **Step 4.2: Create init.sh**

```bash
nano scripts/init.sh
```

```bash
#!/bin/bash

set -e

GREEN="\033[32m"
BLUE="\033[34m"
RESET="\033[0m"

echo "============================================"
echo "     Deploying Application via Argo CD"
echo "============================================"

echo ""
echo "[1/2] Applying Argo CD Application..."

kubectl apply -f ../confs/deploy.yaml

echo ""
echo "[2/2] Waiting for application to sync..."

# Wait a bit for Argo to detect the app
sleep 5

echo ""
echo "============================================"
echo "     Application Deployed!"
echo "============================================"
echo ""
echo -e "${GREEN}Check Argo CD UI:${RESET}"
echo "  http://localhost:8085"
echo ""
echo -e "${BLUE}Access application:${RESET}"
echo "  Port forward: kubectl port-forward svc/svc-wil -n dev 8888:8080"
echo "  Then visit: http://localhost:8888"
echo ""
```

**Save**

**Make executable:**

```bash
chmod +x scripts/init.sh
```

---

### **Step 4.3: Run init.sh**

```bash
./scripts/init.sh
```

**Expected:**
```
============================================
     Deploying Application via Argo CD
============================================

[1/2] Applying Argo CD Application...
application.argoproj.io/wil-app created

[2/2] Waiting for application to sync...

============================================
     Application Deployed!
============================================

Check Argo CD UI:
  http://localhost:8085

Access application:
  Port forward: kubectl port-forward svc/svc-wil -n dev 8888:8080
  Then visit: http://localhost:8888
```

---

### **Step 4.4: Check Argo CD Application**

```bash
kubectl get application -n argocd
```

**Expected:**
```
NAME      SYNC STATUS   HEALTH STATUS
wil-app   Synced        Healthy
```

**If `Synced` and `Healthy`:** ✅ **Perfect!**

**If `OutOfSync`:**

```bash
# Check application details
kubectl describe application wil-app -n argocd
```

---

### **Step 4.5: Check Dev Namespace**

```bash
kubectl get pods -n dev
```

**Expected:**
```
NAME                   READY   STATUS    RESTARTS   AGE
wil-...                1/1     Running   0          30s
```

**If pod is `Running`:** ✅ **Application deployed!**

---

```bash
kubectl get service -n dev
```

**Expected:**
```
NAME      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
svc-wil   ClusterIP   10.43.123.45   <none>        8080/TCP   30s
```

---

```bash
kubectl get deployment -n dev
```

**Expected:**
```
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
wil    1/1     1            1           30s
```

✅ **Everything deployed correctly!**

---

## **Phase 5: Access Application (Test v1)**

### **Step 5.1: Port Forward Service**

```bash
kubectl port-forward svc/svc-wil -n dev 8888:8080
```

**Keep this running!**

**Expected:**
```
Forwarding from 127.0.0.1:8888 -> 8888
Forwarding from [::1]:8888 -> 8888
```

---

### **Step 5.2: Test with curl (v1)**

**Open NEW terminal:**

```bash
curl http://localhost:8888
```

**Expected:**
```json
{"status":"ok", "message": "v1"}
```

✅ **Application v1 working!**

---

### **Step 5.3: Test in Browser**

**Open browser:**

```
http://localhost:8888
```

**Expected:**
```
{"status":"ok", "message": "v1"}
```

✅ **v1 accessible!**

---

### **Step 5.4: Check Deployment Image**

```bash
kubectl get deployment wil -n dev -o yaml | grep image:
```

**Expected:**
```yaml
        image: wil42/playground:v1
```

✅ **Confirms v1 deployed!**

---

## **Phase 6: Update to v2 (GitOps Magic)**

### **Step 6.1: Update GitHub Repo**

```bash
cd ~/Desktop/inceptionOfThings/iot/p3/iot-hed-dyb
```

**Edit application.yaml:**

```bash
nano manifests/application.yaml
```

**Change line:**

```yaml
FROM:
        image: wil42/playground:v1

TO:
        image: wil42/playground:v2
```

**Save**

---

### **Step 6.2: Commit and Push**

```bash
git add manifests/application.yaml
git commit -m "Update to v2"
git push origin main
```

**Expected:**
```
[main xyz1234] Update to v2
 1 file changed, 1 insertion(+), 1 deletion(-)
To https://github.com/<your-username>/iot-hed-dyb.git
   abc5678..xyz1234  main -> main
```

✅ **v2 pushed to GitHub!**

---

### **Step 6.3: Watch Argo CD Sync**

**Argo CD checks GitHub every 3 minutes by default.**

**Check sync status:**

```bash
kubectl get application wil-app -n argocd
```

**Initially:**
```
NAME      SYNC STATUS   HEALTH STATUS
wil-app   OutOfSync     Healthy
```

**Wait 30 seconds, check again:**

```bash
kubectl get application wil-app -n argocd
```

**After sync:**
```
NAME      SYNC STATUS   HEALTH STATUS
wil-app   Synced        Healthy
```

✅ **Argo detected GitHub change and synced!**

---

### **Step 6.4: Watch Pod Recreation**

```bash
kubectl get pods -n dev -w
```

**You'll see:**
```
NAME                   READY   STATUS    RESTARTS   AGE
wil-xxx-old            1/1     Running   0          5m
wil-yyy-new            0/1     Pending   0          1s
wil-yyy-new            0/1     ContainerCreating   0          2s
wil-yyy-new            1/1     Running             0          10s
wil-xxx-old            1/1     Terminating         0          5m
wil-xxx-old            0/1     Terminating         0          5m
```

**Argo CD:**
1. Created new pod with v2
2. Waited for it to be ready
3. Terminated old pod with v1

✅ **Rolling update complete!**

**Press Ctrl+C to stop watching**

---

### **Step 6.5: Verify v2 Deployed**

```bash
kubectl get deployment wil -n dev -o yaml | grep image:
```

**Expected:**
```yaml
        image: wil42/playground:v2
```

---

**Test with curl:**

```bash
curl http://localhost:8888
```

**Expected:**
```json
{"status":"ok", "message": "v2"}
```

✅ **v2 deployed successfully via GitOps!**

---

### **Step 6.6: Test in Browser**

**Refresh browser:**

```
http://localhost:8888
```

**Expected:**
```
{"status":"ok", "message": "v2"}
```

✅ **v2 accessible!**

---

## **Phase 7: Argo CD UI Testing**

### **Step 7.1: Login to Argo CD**

**Open browser:**

```
http://localhost:8085
```

**Login:**
- Username: `admin`
- Password: (from argocd.sh output)

---

### **Step 7.2: View Application**

**You should see:**
- Application: `wil-app`
- Status: `Synced` + `Healthy`
- Sync Status: Green checkmark

**Click on `wil-app`**

---

### **Step 7.3: View Resource Tree**

**You should see:**
- Deployment: `wil`
- ReplicaSet: `wil-xxx`
- Pod: `wil-xxx-yyy`
- Service: `svc-wil`

**Click on Pod to see details**

---

### **Step 7.4: View Live Manifest**

**Click "Live Manifest" tab**

**You should see:**
```yaml
apiVersion: apps/v1
kind: Deployment
...
spec:
  containers:
  - image: wil42/playground:v2  # ← v2!
```

✅ **Argo CD shows current state!**

---

### **Step 7.5: View Git Diff**

**Click "Diff" tab**

**If synced:** "No changes"

**If you just pushed v2:**
```diff
- image: wil42/playground:v1
+ image: wil42/playground:v2
```

✅ **Argo tracks Git changes!**

---

## **Phase 8: Test Self-Healing**

### **Step 8.1: Delete Pod Manually**

```bash
kubectl delete pod -l app=wil -n dev
```

**Expected:**
```
pod "wil-xxx-yyy" deleted
```

---

### **Step 8.2: Watch Argo CD Recreate It**

```bash
kubectl get pods -n dev -w
```

**Expected:**
```
NAME                   READY   STATUS    RESTARTS   AGE
wil-xxx-new            0/1     Pending   0          1s
wil-xxx-new            0/1     ContainerCreating   0          2s
wil-xxx-new            1/1     Running             0          10s
```

**Argo CD detected missing pod and recreated it!**

✅ **Self-healing works!**

---

### **Step 8.3: Verify Application Still Works**

```bash
curl http://localhost:8888
```

**Expected:**
```json
{"status":"ok", "message": "v2"}
```

✅ **Zero downtime!**

---

## **Phase 9: Test Rollback (v2 → v1)**

### **Step 9.1: Edit GitHub Repo**

```bash
cd ~/Desktop/inceptionOfThings/iot/p3/iot-hed-dyb
nano manifests/application.yaml
```

**Change back:**

```yaml
FROM:
        image: wil42/playground:v2

TO:
        image: wil42/playground:v1
```

**Save**

---

### **Step 9.2: Push Changes**

```bash
git add manifests/application.yaml
git commit -m "Rollback to v1"
git push origin main
```

---

### **Step 9.3: Wait for Sync**

```bash
watch kubectl get application wil-app -n argocd
```

**Wait for `Synced` status**

**Press Ctrl+C when synced**

---

### **Step 9.4: Verify Rollback**

```bash
curl http://localhost:8888
```

**Expected:**
```json
{"status":"ok", "message": "v1"}
```

✅ **Rolled back to v1!**

---

## **Phase 10: Cleanup & Testing**

### **Step 10.1: Test Full Cleanup**

```bash
# Delete application
kubectl delete application wil-app -n argocd
```

**Expected:**
```
application.argoproj.io "wil-app" deleted
```

---

```bash
# Check dev namespace (should be empty)
kubectl get all -n dev
```

**Expected:**
```
No resources found in dev namespace.
```

✅ **Argo CD cleaned up everything!**

---

### **Step 10.2: Redeploy from Scratch**

```bash
cd ~/Desktop/inceptionOfThings/iot/p3
./scripts/init.sh
```

**Wait 30 seconds:**

```bash
kubectl get pods -n dev
```

**Expected:**
```
NAME                   READY   STATUS    RESTARTS   AGE
wil-xxx                1/1     Running   0          20s
```

✅ **Can redeploy anytime!**

---

### **Step 10.3: Test Namespace Deletion**

```bash
# Delete entire dev namespace
kubectl delete namespace dev
```

**Wait a bit, then check:**

```bash
kubectl get namespace dev
```

**Expected:**
```
NAME   STATUS   AGE
dev    Active   5s
```

**Argo CD recreated the namespace because it's in Git!**

✅ **Self-healing at namespace level!**

---

### **Step 10.4: Full Cluster Reset**

```bash
# Delete cluster
k3d cluster delete hed-dybS

# Recreate everything
./scripts/k3d.sh
./scripts/argocd.sh
./scripts/init.sh
```

**This tests your entire automation!**

---

## **Phase 11: Final Verification**

### **Step 11.1: Verify All Components**

```bash
# Check cluster
kubectl get nodes
```

**Expected:** 1 node, Ready

---

```bash
# Check namespaces
kubectl get namespaces
```

**Expected:** `argocd`, `dev` exist

---

```bash
# Check Argo CD
kubectl get pods -n argocd
```

**Expected:** All Running

---

```bash
# Check Application
kubectl get application -n argocd
```

**Expected:** `wil-app`, Synced, Healthy

---

```bash
# Check Dev Pods
kubectl get pods -n dev
```

**Expected:** wil pod Running

---

```bash
# Test Application
curl http://localhost:8888
```

**Expected:** `{"status":"ok", "message": "v1"}` or `v2`

---

### **Step 11.2: Document Your Setup**

```bash
cd ~/Desktop/inceptionOfThings/iot/p3
nano README.md
```

```markdown
# Part 3: K3d + Argo CD

## Setup

1. Install prerequisites:
   ```bash
   ./scripts/k3d.sh
   ```

2. Install Argo CD:
   ```bash
   ./scripts/argocd.sh
   ```

3. Deploy application:
   ```bash
   ./scripts/init.sh
   ```

## Access

- **Argo CD UI:** http://localhost:8085
  - Username: admin
  - Password: (see argocd.sh output)

- **Application:** http://localhost:8888
  - Port forward: `kubectl port-forward svc/svc-wil -n dev 8888:8080`

## Update Version

1. Edit GitHub repo: `manifests/application.yaml`
2. Change `image: wil42/playground:v1` to `v2`
3. Commit and push
4. Argo CD syncs automatically (3min)

## Cleanup

```bash
k3d cluster delete hed-dybS
```
```

**Save**

---

## **🎓 FINAL CHECKPOINT**

### **What You Built:**

- [x] K3d cluster (K3s in Docker)
- [x] Argo CD (GitOps engine)
- [x] GitHub repository (source of truth)
- [x] Application (v1/v2 deployable)
- [x] Automated scripts (k3d.sh, argocd.sh, init.sh)
- [x] Self-healing system
- [x] Rolling updates via Git

---

### **Expected Final State:**

```bash
k3d cluster list
```
**Output:**
```
NAME       SERVERS   AGENTS   LOADBALANCER
hed-dybS   1/1       0/0      true
```

---

```bash
kubectl get namespaces
```
**Output:**
```
NAME              STATUS   AGE
default           Active   10m
kube-system       Active   10m
argocd            Active   8m
dev               Active   5m
```

---

```bash
kubectl get pods -A
```
**Output:**
```
NAMESPACE     NAME                                      READY   STATUS
argocd        argocd-application-controller-0           1/1     Running
argocd        argocd-server-...                         1/1     Running
argocd        ... (7 total pods)
dev           wil-...                                   1/1     Running
kube-system   coredns-...                               1/1     Running
kube-system   traefik-...                               1/1     Running
```

---

```bash
curl http://localhost:8888
```
**Output:**
```json
{"status":"ok", "message": "v1"}
```

---

### **Can You Answer These?**

1. **What's the difference between K3s and K3d?**
2. **How does Argo CD know when to update?**
3. **What happens if you delete a pod?**
4. **How do you rollback from v2 to v1?**
5. **Where is the source of truth for your deployment?**

---

## **🚀 You Did It!**

**You successfully:**
- Reverse engineered Part 3
- Built everything from scratch
- Tested every component
- Understand GitOps workflow
- Can update apps via Git push!

**Ready for evaluation!** 🎉

---

**Need to test anything else?** Reply with what you want to explore!