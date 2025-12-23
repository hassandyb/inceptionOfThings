# 📚 **Part 2: Complete Theoretical Documentation**

**Understanding Kubernetes, K3s, and Your Project Architecture**

---

## **Table of Contents**

1. What is Kubernetes?
2. What is K3s?
3. What is Vagrant?
4. Kubernetes Components Deep Dive
5. Project Architecture Explained
6. Complete Request Flow
7. Why We Need Each Component
8. Visual Architecture Diagrams

---

## **1. What is Kubernetes?**

### **Definition**

**Kubernetes (K8s)** is an open-source **container orchestration platform** that automates:
- Deployment
- Scaling
- Management
- Networking

of containerized applications.

---

### **The Problem Kubernetes Solves**

**Without Kubernetes:**

```
You have 10 web applications
Each needs:
  - A server to run on
  - Monitoring (is it running?)
  - Restart if it crashes
  - Load balancing (distribute traffic)
  - Updates without downtime
  - Scaling (add more copies when traffic increases)

You do ALL of this MANUALLY! 😰
```

**With Kubernetes:**

```
You tell Kubernetes:
  "I want 3 copies of app1"
  "I want app2 accessible at app2.com"
  "If a copy crashes, restart it"

Kubernetes does EVERYTHING automatically! 🎉
```

---

### **Kubernetes Architecture (Standard)**

```
┌─────────────────────────────────────────────────────────┐
│              Kubernetes Cluster                         │
│                                                         │
│  ┌────────────────────────────────────────────────┐    │
│  │          Control Plane (Master Node)           │    │
│  │                                                │    │
│  │  ┌──────────────────────────────────────────┐ │    │
│  │  │  API Server (kubectl talks to this)     │ │    │
│  │  └──────────────────────────────────────────┘ │    │
│  │                                                │    │
│  │  ┌──────────────────────────────────────────┐ │    │
│  │  │  Scheduler (decides which node runs pod) │ │    │
│  │  └──────────────────────────────────────────┘ │    │
│  │                                                │    │
│  │  ┌──────────────────────────────────────────┐ │    │
│  │  │  Controller Manager (ensures desired     │ │    │
│  │  │  state = actual state)                   │ │    │
│  │  └──────────────────────────────────────────┘ │    │
│  │                                                │    │
│  │  ┌──────────────────────────────────────────┐ │    │
│  │  │  etcd (database - stores cluster state) │ │    │
│  │  └──────────────────────────────────────────┘ │    │
│  └────────────────────────────────────────────────┘    │
│                                                         │
│  ┌────────────────────────────────────────────────┐    │
│  │              Worker Nodes                      │    │
│  │                                                │    │
│  │  Node 1        Node 2        Node 3           │    │
│  │  ┌────┐        ┌────┐        ┌────┐          │    │
│  │  │Pod1│        │Pod2│        │Pod3│          │    │
│  │  │Pod4│        │Pod5│        │Pod6│          │    │
│  │  └────┘        └────┘        └────┘          │    │
│  └────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

**Components:**
- **Control Plane**: Brain of cluster (makes decisions)
- **Worker Nodes**: Run your applications (pods)
- **etcd**: Database storing cluster configuration

---

## **2. What is K3s?**

### **Definition**

**K3s** is a **lightweight Kubernetes distribution** designed for:
- IoT devices
- Edge computing
- Development environments
- Resource-constrained systems

---

### **Kubernetes vs K3s**

| Feature | Standard Kubernetes | K3s |
|---------|-------------------|-----|
| **Size** | ~1.5 GB binary | ~70 MB binary |
| **Memory** | ~2-4 GB minimum | ~512 MB minimum |
| **Components** | Many separate binaries | Single binary |
| **Setup** | Complex (kubeadm, etc.) | One command: `curl -sfL https://get.k3s.io \| sh` |
| **Default Ingress** | None (must install) | Traefik included |
| **Storage** | External (must configure) | Local-path included |
| **Use Case** | Production clusters | Dev, IoT, edge |

---

### **K3s Architecture**

```
┌─────────────────────────────────────────────────────┐
│              K3s Server (Your VM)                   │
│                                                     │
│  ┌────────────────────────────────────────────┐    │
│  │     K3s Binary (All-in-One)                │    │
│  │                                            │    │
│  │  ┌──────────────────────────────────────┐ │    │
│  │  │  API Server + Scheduler + Controller │ │    │
│  │  │  (All in single process!)            │ │    │
│  │  └──────────────────────────────────────┘ │    │
│  │                                            │    │
│  │  ┌──────────────────────────────────────┐ │    │
│  │  │  SQLite (replaces etcd)              │ │    │
│  │  │  (Lighter database)                  │ │    │
│  │  └──────────────────────────────────────┘ │    │
│  │                                            │    │
│  │  ┌──────────────────────────────────────┐ │    │
│  │  │  Traefik (Ingress - included!)       │ │    │
│  │  └──────────────────────────────────────┘ │    │
│  │                                            │    │
│  │  ┌──────────────────────────────────────┐ │    │
│  │  │  Local-path provisioner (storage)    │ │    │
│  │  └──────────────────────────────────────┘ │    │
│  │                                            │    │
│  │  ┌──────────────────────────────────────┐ │    │
│  │  │  Your Pods (app1, app2, app3)        │ │    │
│  │  └──────────────────────────────────────┘ │    │
│  └────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

**Key Differences:**
- **Single binary**: Everything in one file
- **SQLite**: Instead of etcd (lighter)
- **Traefik included**: No need to install ingress controller
- **Local storage included**: No external storage needed

---

### **Why K3s for This Project?**

1. **Lightweight**: Runs in 2GB RAM VM
2. **Fast setup**: One command install
3. **Batteries included**: Traefik, storage pre-installed
4. **Perfect for learning**: Less complexity, same concepts
5. **Single-node**: Works great on 1 VM

---

## **3. What is Vagrant?**

### **Definition**

**Vagrant** is a tool for **building and managing virtual machine environments**.

---

### **The Problem Vagrant Solves**

**Without Vagrant:**

```
To set up a development VM, you must:
1. Open VirtualBox GUI
2. Click "New"
3. Configure RAM, CPU, disk
4. Download Ubuntu ISO
5. Install OS manually (30 minutes)
6. Install K3s manually
7. Configure networking manually
8. Share folders manually
9. Document steps so teammates can reproduce

Takes 1-2 hours per developer! 😰
```

**With Vagrant:**

```
1. Write Vagrantfile (once)
2. Run: vagrant up

Vagrant does everything automatically!
Takes 3 minutes! 🎉
```

---

### **Vagrant Architecture**

```
┌─────────────────────────────────────────────────────┐
│           Your Laptop (Host Machine)                │
│                                                     │
│  ┌────────────────────────────────────────────┐    │
│  │  Vagrantfile (Configuration)               │    │
│  │                                            │    │
│  │  Vagrant.configure("2") do |config|        │    │
│  │    config.vm.box = "ubuntu/jammy64"        │    │
│  │    config.vm.network "private_network",    │    │
│  │      ip: "192.168.56.110"                  │    │
│  │    ...                                     │    │
│  │  end                                       │    │
│  └────────────────┬───────────────────────────┘    │
│                   │                                │
│                   ▼                                │
│  ┌────────────────────────────────────────────┐    │
│  │       Vagrant CLI (vagrant up)             │    │
│  └────────────────┬───────────────────────────┘    │
│                   │                                │
│                   ▼                                │
│  ┌────────────────────────────────────────────┐    │
│  │    VirtualBox (Provider)                   │    │
│  │                                            │    │
│  │  ┌──────────────────────────────────────┐ │    │
│  │  │   VM: hed-dybS                       │ │    │
│  │  │   IP: 192.168.56.110                 │ │    │
│  │  │   RAM: 2GB, CPU: 2                   │ │    │
│  │  │                                      │ │    │
│  │  │   Ubuntu 22.04 + K3s                 │ │    │
│  │  └──────────────────────────────────────┘ │    │
│  └────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

---

### **What Vagrant Does in Your Project**

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  # Downloads Ubuntu 22.04 base image
  
  config.vm.network "private_network", ip: "192.168.56.110"
  # Creates network so laptop can access VM
  
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end
  # Allocates resources
  
  server.vm.synced_folder "./apps", "/vagrant/apps"
  # Shares your HTML files with VM
  
  server.vm.provision "shell", path: "scripts/server.sh"
  # Runs your setup script automatically
end
```

**Result:** One command (`vagrant up`) creates fully configured K3s cluster!

---

### **Vagrant Workflow**

```
┌─────────────────────────────────────────────────┐
│  Developer writes: Vagrantfile                  │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│  vagrant up                                     │
│  ├─ Downloads base box (ubuntu/jammy64)         │
│  ├─ Creates VM in VirtualBox                    │
│  ├─ Configures network (192.168.56.110)         │
│  ├─ Shares folders (./apps → /vagrant/apps)     │
│  └─ Runs provisioning script (server.sh)        │
│     ├─ Installs K3s                             │
│     ├─ Deploys applications                     │
│     └─ Configures Ingress                       │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│  Fully configured VM ready to use!              │
│  Access at: 192.168.56.110                      │
└─────────────────────────────────────────────────┘
```

---

### **Why Vagrant for This Project?**

1. **Reproducibility**: Same setup for everyone
2. **Automation**: No manual VM configuration
3. **Speed**: 3 minutes vs 1-2 hours
4. **Isolation**: VM isolated from host
5. **Easy cleanup**: `vagrant destroy` removes everything
6. **Version control**: Vagrantfile in git

---

## **4. Kubernetes Components Deep Dive**

Now let's understand EACH Kubernetes component you used and WHY.

---

### **4.1 Pod**

#### **What is a Pod?**

**Pod** = Smallest deployable unit in Kubernetes
- **Contains**: 1 or more containers
- **Purpose**: Run your application
- **Lifecycle**: Created, runs, dies (ephemeral)

#### **Pod in Your Project**

```yaml
# This creates a Pod (through Deployment):
containers:
- name: nginx
  image: nginx:alpine
  ports:
  - containerPort: 80
```

**What happens:**
1. Kubernetes downloads `nginx:alpine` image
2. Creates container from image
3. Container listens on port 80
4. Serves HTML files

#### **Why Pods?**

**Without Pods:**
```
You run: docker run -p 8080:80 nginx
Container runs on your laptop
If it crashes, it's gone forever
No auto-restart
```

**With Pods:**
```
Pod runs in cluster
If crashes, Kubernetes recreates it (self-healing)
Can scale to multiple copies
Kubernetes manages everything
```

#### **Pod Architecture**

```
┌────────────────────────────────────────┐
│              Pod                       │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │  Container: nginx                │ │
│  │                                  │ │
│  │  ┌────────────────────────────┐ │ │
│  │  │  Process: nginx            │ │ │
│  │  │  Listens on: port 80       │ │ │
│  │  │  Serves: /usr/share/nginx/ │ │ │
│  │  │          html/index.html   │ │ │
│  │  └────────────────────────────┘ │ │
│  └──────────────────────────────────┘ │
│                                        │
│  IP: 10.42.0.8 (internal only)         │
│  Node: hed-dybS                        │
└────────────────────────────────────────┘
```

---

### **4.2 Deployment**

#### **What is a Deployment?**

**Deployment** = Manages Pods
- **Purpose**: Ensure desired number of Pods are always running
- **Features**: Self-healing, rolling updates, scaling

#### **Deployment in Your Project**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1-deployment
spec:
  replicas: 1  # How many copies
  selector:
    matchLabels:
      app: app1  # Find pods with this label
  template:
    # Pod template here
```

**What this does:**
- Creates 1 Pod with label `app: app1`
- Continuously monitors Pod
- If Pod dies, creates new one
- Can scale to 3 replicas with one command

#### **Why Deployments?**

**Without Deployment (just Pod):**
```
kubectl run app1 --image=nginx
→ Pod created
→ You delete Pod manually: kubectl delete pod app1
→ Pod is gone FOREVER
→ You must recreate manually
```

**With Deployment:**
```
kubectl apply -f deployment.yaml
→ Deployment created
→ Deployment creates Pod
→ You delete Pod: kubectl delete pod app1-xxx
→ Deployment notices: "I want 1, but I have 0!"
→ Deployment AUTOMATICALLY creates new Pod
```

#### **Deployment Self-Healing Diagram**

```
Time: 0s
┌────────────────────────────────────┐
│  Deployment: app1-deployment       │
│  Desired: 1 replica                │
│  Current: 1 replica                │
│                                    │
│  ┌──────────────────────────────┐ │
│  │  Pod: app1-xxx               │ │
│  │  Status: Running             │ │
│  └──────────────────────────────┘ │
└────────────────────────────────────┘

Time: 10s (Pod crashes or deleted)
┌────────────────────────────────────┐
│  Deployment: app1-deployment       │
│  Desired: 1 replica                │
│  Current: 0 replicas ⚠️            │
│                                    │
│  ⚠️ MISMATCH DETECTED!             │
│  Creating new Pod...               │
└────────────────────────────────────┘

Time: 20s
┌────────────────────────────────────┐
│  Deployment: app1-deployment       │
│  Desired: 1 replica                │
│  Current: 1 replica ✅             │
│                                    │
│  ┌──────────────────────────────┐ │
│  │  Pod: app1-yyy (NEW!)        │ │
│  │  Status: Running             │ │
│  └──────────────────────────────┘ │
└────────────────────────────────────┘
```

#### **Scaling with Deployment**

```
kubectl scale deployment app1-deployment --replicas=3

Before:                     After:
┌─────────────────┐        ┌─────────────────┐
│  Deployment     │        │  Deployment     │
│  replicas: 1    │        │  replicas: 3    │
│                 │        │                 │
│  ┌───────────┐ │        │  ┌───────────┐ │
│  │ Pod 1     │ │        │  │ Pod 1     │ │
│  └───────────┘ │        │  └───────────┘ │
└─────────────────┘        │  ┌───────────┐ │
                           │  │ Pod 2     │ │ ← NEW
                           │  └───────────┘ │
                           │  ┌───────────┐ │
                           │  │ Pod 3     │ │ ← NEW
                           │  └───────────┘ │
                           └─────────────────┘
```

---

### **4.3 Service**

#### **What is a Service?**

**Service** = Stable network endpoint for Pods
- **Problem it solves**: Pod IPs change when pods restart
- **Solution**: Service has fixed IP that never changes

#### **Service in Your Project**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: app1-service
spec:
  selector:
    app: app1  # Find pods with this label
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP  # Internal IP only
```

**What this does:**
- Creates stable IP (e.g., 10.43.123.45)
- Finds all Pods with label `app: app1`
- Load balances traffic across those Pods
- If Pod restarts (new IP), Service automatically updates

#### **Why Services?**

**Without Service:**
```
Pod 1 IP: 10.42.0.8
→ Other services connect to 10.42.0.8
→ Pod restarts
→ New Pod IP: 10.42.0.12
→ Connections break! ❌
→ Must update all services manually
```

**With Service:**
```
Service IP: 10.43.123.45 (never changes)
→ Other services connect to 10.43.123.45
→ Pod restarts (new IP: 10.42.0.12)
→ Service automatically routes to new Pod
→ Connections keep working! ✅
```

#### **Service Architecture**

```
┌──────────────────────────────────────────────────┐
│              Service: app1-service               │
│              ClusterIP: 10.43.123.45             │
│              Selector: app=app1                  │
└────────────────────┬─────────────────────────────┘
                     │
      ┌──────────────┼──────────────┐
      │              │              │
      ▼              ▼              ▼
┌──────────┐   ┌──────────┐   ┌──────────┐
│ Pod 1    │   │ Pod 2    │   │ Pod 3    │
│ app=app1 │   │ app=app1 │   │ app=app1 │
│ 10.42.0.8│   │ 10.42.0.9│   │ 10.42.0.10│
└──────────┘   └──────────┘   └──────────┘
```

**How it works:**
1. Request comes to Service IP: `10.43.123.45`
2. Service looks at selector: `app=app1`
3. Service finds all Pods with label `app=app1`
4. Service picks one Pod (round-robin)
5. Service forwards request to Pod

#### **Service Types**

| Type | Accessibility | Use Case |
|------|---------------|----------|
| **ClusterIP** | Internal only | Your project (default) |
| **NodePort** | External (specific port) | Testing, simple setups |
| **LoadBalancer** | External (cloud LB) | Production (AWS, GCP) |

**Your project uses ClusterIP** because Ingress handles external access.

---

### **4.4 Ingress**

#### **What is Ingress?**

**Ingress** = HTTP(S) routing rules
- **Purpose**: Route external traffic to internal Services
- **Based on**: Hostname, path, headers

#### **Ingress in Your Project**

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
        backend:
          service:
            name: app1-service
            port:
              number: 80
  - host: app2.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: app2-service
  - http:  # No host = default
      paths:
      - path: /
        backend:
          service:
            name: app3-service
```

**What this does:**
- `app1.com` → `app1-service`
- `app2.com` → `app2-service`
- Any other host → `app3-service` (default)

#### **Why Ingress?**

**Without Ingress (using NodePort):**
```
app1: http://192.168.56.110:30001
app2: http://192.168.56.110:30002
app3: http://192.168.56.110:30003

❌ Different ports for each app
❌ Ugly URLs
❌ Can't use hostnames
❌ Not production-ready
```

**With Ingress:**
```
app1: http://app1.com (port 80)
app2: http://app2.com (port 80)
app3: http://192.168.56.110 (port 80)

✅ Same port for all apps
✅ Clean URLs
✅ Hostname-based routing
✅ Production-ready
```

#### **Ingress Architecture**

```
┌───────────────────────────────────────────────────┐
│           External World (Your Browser)           │
│           http://app1.com                         │
└────────────────────┬──────────────────────────────┘
                     │
                     ▼
┌────────────────────────────────────────────────────┐
│         /etc/hosts: app1.com → 192.168.56.110      │
└────────────────────┬───────────────────────────────┘
                     │
                     ▼
┌────────────────────────────────────────────────────┐
│              VM (192.168.56.110:80)                │
│                                                    │
│  ┌──────────────────────────────────────────────┐ │
│  │  Ingress Controller (Traefik)                │ │
│  │  Listens on port 80                          │ │
│  │                                              │ │
│  │  Receives: GET / HTTP/1.1                    │ │
│  │           Host: app1.com                     │ │
│  │                                              │ │
│  │  Reads Ingress rules:                        │ │
│  │    Host: app1.com → app1-service             │ │
│  │    Host: app2.com → app2-service             │ │
│  │    (default)      → app3-service             │ │
│  │                                              │ │
│  │  Matches: app1.com → app1-service            │ │
│  └────────────────────┬─────────────────────────┘ │
│                       │                           │
│                       ▼                           │
│  ┌──────────────────────────────────────────────┐ │
│  │  Service: app1-service (10.43.123.45)        │ │
│  └────────────────────┬─────────────────────────┘ │
│                       │                           │
│                       ▼                           │
│  ┌──────────────────────────────────────────────┐ │
│  │  Pod: app1-xxx (10.42.0.8)                   │ │
│  │  Returns: <h1>App 1</h1>                     │ │
│  └──────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────┘
```

---

### **4.5 Traefik (Ingress Controller)**

#### **What is Traefik?**

**Traefik** = Ingress Controller
- **Purpose**: Implements Ingress rules
- **Analogy**: Ingress = recipe, Traefik = chef

#### **Ingress vs Ingress Controller**

```
┌──────────────────────────────────────────────┐
│  Ingress Resource (YAML)                     │
│  "If Host=app1.com, go to app1-service"      │
│                                              │
│  This is just a DEFINITION (recipe)          │
│  Does nothing by itself!                     │
└──────────────┬───────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────────┐
│  Ingress Controller (Traefik)                │
│  Reads Ingress resources                     │
│  Configures routing rules                    │
│  Listens on port 80                          │
│  Routes traffic based on rules               │
│                                              │
│  This actually DOES the work! (chef)         │
└──────────────────────────────────────────────┘
```

#### **Why K3s Includes Traefik**

Standard Kubernetes:
```
1. Install Kubernetes
2. Manually install Ingress Controller (nginx, traefik, etc.)
3. Configure it
4. Create Ingress resources
```

K3s:
```
1. Install K3s
2. Traefik automatically included and configured!
3. Just create Ingress resources
```

**This is why K3s is easier for learning!**

---

### **4.6 Volumes (Volume Mounts)**

#### **What is a Volume?**

**Volume** = Shared storage between host and container
- **Problem**: Container has its own isolated filesystem
- **Solution**: Mount external folder into container

#### **Volume Mount in Your Project**

```yaml
containers:
- name: nginx
  volumeMounts:
  - name: html
    mountPath: /usr/share/nginx/html  # Inside container
volumes:
- name: html
  hostPath:
    path: /vagrant/apps/app1  # On VM (host)
```

**What this does:**
```
VM folder:        /vagrant/apps/app1/index.html
                         ↓
                    (mounted as)
                         ↓
Container folder: /usr/share/nginx/html/index.html
```

**Nginx serves files from `/usr/share/nginx/html/`**
**So it serves YOUR HTML instead of default nginx page!**

#### **Without Volume Mount**

```
┌────────────────────────────────────┐
│  Pod                               │
│                                    │
│  ┌──────────────────────────────┐ │
│  │  Container: nginx            │ │
│  │                              │ │
│  │  /usr/share/nginx/html/      │ │
│  │  └─ index.html (nginx        │ │
│  │     default page)            │ │
│  │                              │ │
│  │  Your HTML is on VM, but     │ │
│  │  container CAN'T see it!     │ │
│  └──────────────────────────────┘ │
└────────────────────────────────────┘

Result: Nginx serves default page ❌
```

#### **With Volume Mount**

```
VM Filesystem:
/vagrant/apps/app1/
  └─ index.html (your HTML)
         │
         │ (mounted into container)
         ▼
┌────────────────────────────────────┐
│  Pod                               │
│                                    │
│  ┌──────────────────────────────┐ │
│  │  Container: nginx            │ │
│  │                              │ │
│  │  /usr/share/nginx/html/      │ │
│  │  └─ index.html (YOUR HTML!)  │ │◄── Shared!
│  │                              │ │
│  └──────────────────────────────┘ │
└────────────────────────────────────┘

Result: Nginx serves YOUR HTML ✅
```

#### **Why This Works in Your Project**

```
1. Vagrant syncs: ./apps → /vagrant/apps (on VM)
2. Volume mounts: /vagrant/apps/app1 → /usr/share/nginx/html (in container)
3. You edit: ./apps/app1/index.html (on laptop)
4. Changes appear in: /vagrant/apps/app1/ (on VM)
5. Container sees changes: /usr/share/nginx/html/ (in container)
6. Nginx serves updated file immediately!
```

**This is why you can edit HTML on laptop and see changes without restarting pods!**

---

### **4.7 ClusterIP (Service Type)**

#### **What is ClusterIP?**

**ClusterIP** = Internal-only IP address
- **Default Service type**
- **Accessible**: Only from inside cluster
- **Use case**: Internal communication between services

#### **ClusterIP in Your Project**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: app1-service
spec:
  type: ClusterIP  # Internal only
  selector:
    app: app1
  ports:
  - port: 80
```

**Result:**
- Service gets IP like `10.43.123.45`
- Only accessible from inside cluster
- NOT accessible from your laptop
- Ingress (Traefik) is inside cluster, so it CAN access it

#### **Why ClusterIP + Ingress?**

```
Your Laptop (192.168.56.1)
    │
    │ ❌ Can't access ClusterIP (10.43.123.45)
    │
    ▼
┌─────────────────────────────────────────────┐
│  VM (192.168.56.110)                        │
│                                             │
│  Traefik (port 80)                          │
│      │                                      │
│      │ ✅ CAN access ClusterIP              │
│      ▼                                      │
│  Service: app1-service (10.43.123.45)       │
│      │                                      │
│      ▼                                      │
│  Pods                                       │
└─────────────────────────────────────────────┘
```

**Flow:**
1. Your laptop → VM:80 (Traefik)
2. Traefik → ClusterIP (Service)
3. Service → Pods

**ClusterIP is INTERNAL, Ingress is EXTERNAL gateway!**

---

### **4.8 Load Balancing**

#### **What is Load Balancing?**

**Load Balancing** = Distribute traffic across multiple Pods
- **Purpose**: No single Pod gets overloaded
- **Algorithm**: Round-robin (by default)

#### **Load Balancing in Your Project (App2)**

```yaml
spec:
  replicas: 3  # 3 Pods
```

**What happens:**

```
Service: app2-service
    │
    │ (Load balancer)
    │
    ├─────────┬─────────┐
    │         │         │
    ▼         ▼         ▼
  Pod1      Pod2      Pod3
```

**Request distribution:**
```
Request 1 → Pod 1
Request 2 → Pod 2
Request 3 → Pod 3
Request 4 → Pod 1 (back to first)
Request 5 → Pod 2
...
```

#### **Why Load Balancing?**

**Without Load Balancing (1 Pod):**
```
1000 requests/sec → Pod 1
                    │
                    ▼
                 💥 OVERLOADED!
                    CPU: 100%
                    Response: Slow
```

**With Load Balancing (3 Pods):**
```
1000 requests/sec → Service
                    │
        ┌───────────┼───────────┐
        │           │           │
        ▼           ▼           ▼
    333 req/s   333 req/s   333 req/s
      Pod 1       Pod 2       Pod 3
     CPU: 30%   CPU: 30%   CPU: 30%
   Response: Fast  Fast      Fast
```

**Each Pod handles 1/3 of traffic!**

---

## **5. Project Architecture Explained**

Now let's see how ALL components work together in YOUR project.

---

### **5.1 Your Project Structure**

```
p2/
├── Vagrantfile          # VM configuration
├── apps/
│   ├── app1/index.html  # App1 HTML
│   ├── app2/index.html  # App2 HTML
│   └── app3/index.html  # App3 HTML
├── confs/
│   ├── deployment.yaml  # Deployments + Services
│   └── ingress.yaml     # Ingress rules
└── scripts/
    └── server.sh        # Setup automation
```

---

### **5.2 Component Relationships**

```
┌─────────────────────────────────────────────────────────┐
│                    Your Project                         │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │  Vagrant                                          │ │
│  │  - Creates VM                                     │ │
│  │  - Installs K3s                                   │ │
│  │  - Shares folders                                 │ │
│  └────────────────────┬──────────────────────────────┘ │
│                       │                                │
│                       ▼                                │
│  ┌───────────────────────────────────────────────────┐ │
│  │  K3s                                              │ │
│  │  - Manages Pods                                   │ │
│  │  - Provides networking                            │ │
│  │  - Includes Traefik                               │ │
│  └────────────────────┬──────────────────────────────┘ │
│                       │                                │
│           ┌───────────┼───────────┐                    │
│           │           │           │                    │
│           ▼           ▼           ▼                    │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐     │
│  │ Deployment  │ │  Service    │ │  Ingress    │     │
│  │ - Manages   │ │ - Stable IP │ │ - Routes    │     │
│  │   Pods      │ │ - Load      │ │   external  │     │
│  │ - Self-     │ │   balance   │ │   traffic   │     │
│  │   healing   │ └─────────────┘ └─────────────┘     │
│  └──────┬──────┘                                      │
│         │                                             │
│         ▼                                             │
│  ┌─────────────┐                                      │
│  │    Pods     │                                      │
│  │ - Run nginx │                                      │
│  │ - Serve     │                                      │
│  │   HTML      │                                      │
│  └──────┬──────┘                                      │
│         │                                             │
│         ▼                                             │
│  ┌─────────────┐                                      │
│  │  Volumes    │                                      │
│  │ - Share     │                                      │
│  │   HTML      │                                      │
│  │   files     │                                      │
│  └─────────────┘                                      │
└─────────────────────────────────────────────────────────┘
```

---

### **5.3 How Each Component Contributes**

| Component | Purpose in Your Project | Without It |
|-----------|------------------------|------------|
| **Vagrant** | Automates VM creation | Must configure VM manually (1 hour) |
| **K3s** | Provides Kubernetes | Must install full Kubernetes (complex) |
| **Deployment** | Manages Pods, ensures 3 app2 replicas | Pods die permanently when deleted |
| **Service** | Stable IP for Pods | Must track changing Pod IPs |
| **Ingress** | Routes by hostname | Can't use app1.com, app2.com |
| **Traefik** | Implements Ingress | Ingress rules do nothing |
| **Pod** | Runs nginx container | No way to run application |
| **Volume** | Shares HTML files | Nginx serves default page |
| **ClusterIP** | Internal networking | Services can't communicate |
| **Load Balancing** | Distributes traffic | Single app2 Pod overloaded |

---

## **6. Complete Request Flow**

Let's trace a request from your browser to the HTML file.

---

### **Scenario: You open `http://app1.com` in browser**

```
Step 1: DNS Resolution (Your Laptop)
┌────────────────────────────────────────────┐
│  Browser: "What is IP of app1.com?"        │
│  /etc/hosts: "app1.com = 192.168.56.110"   │
└────────────────────┬───────────────────────┘
                     │
                     ▼
Step 2: HTTP Request (Network)
┌────────────────────────────────────────────┐
│  Browser sends:                            │
│    GET / HTTP/1.1                          │
│    Host: app1.com                          │
│  To: 192.168.56.110:80                     │
└────────────────────┬───────────────────────┘
                     │
                     ▼
Step 3: Traefik Receives (VM - Port 80)
┌────────────────────────────────────────────┐
│  Traefik: "Request arrived!"               │
│  Reads header: Host: app1.com              │
│  Looks at Ingress rules                    │
└────────────────────┬───────────────────────┘
                     │
                     ▼
Step 4: Ingress Rules Matching
┌────────────────────────────────────────────┐
│  Ingress rules:                            │
│    - host: app1.com → app1-service ✅ MATCH│
│    - host: app2.com → app2-service         │
│    - (default)      → app3-service         │
└────────────────────┬───────────────────────┘
                     │
                     ▼
Step 5: Service Resolution
┌────────────────────────────────────────────┐
│  Traefik: "Route to app1-service"         │
│  Service ClusterIP: 10.43.123.45           │
│  Service selector: app=app1                │
└────────────────────┬───────────────────────┘
                     │
                     ▼
Step 6: Service Finds Pods
┌────────────────────────────────────────────┐
│  Service: "Find pods with label app=app1" │
│  Found: Pod app1-xxx (IP: 10.42.0.8)       │
└────────────────────┬───────────────────────┘
                     │
                     ▼
Step 7: Forward to Pod
┌────────────────────────────────────────────┐
│  Service forwards request to 10.42.0.8:80  │
└────────────────────┬───────────────────────┘
                     │
                     ▼
Step 8: Nginx Processes
┌────────────────────────────────────────────┐
│  Pod: app1-xxx                             │
│  Nginx receives: GET /                     │
│  Looks for: /usr/share/nginx/html/index... │
└────────────────────┬───────────────────────┘
                     │
                     ▼
Step 9: Read File (Via Volume Mount)
┌────────────────────────────────────────────┐
│  /usr/share/nginx/html/ (in container)     │
│         ↓ (mounted from)                   │
│  /vagrant/apps/app1/ (on VM)               │
│         ↓ (synced from)                    │
│  ./apps/app1/ (on your laptop)             │
│                                            │
│  Reads: index.html                         │
└────────────────────┬───────────────────────┘
                     │
                     ▼
Step 10: Response Flow (Reverse Path)
┌────────────────────────────────────────────┐
│  Nginx → Pod → Service → Traefik → Browser │
│                                            │
│  HTTP/1.1 200 OK                           │
│  Content-Type: text/html                   │
│                                            │
│  <!DOCTYPE html>                           │
│  <html>                                    │
│    <h1>App 1</h1>                          │
│  </html>                                   │
└────────────────────┬───────────────────────┘
                     │
                     ▼
Step 11: Browser Renders
┌────────────────────────────────────────────┐
│  Browser displays:                         │
│  - Blue background                         │
│  - "App 1" title                           │
└────────────────────────────────────────────┘
```

---

### **Summary of Request Flow**

```
Browser
  ↓ (DNS: app1.com → 192.168.56.110)
VM:80 (Traefik)
  ↓ (Ingress: app1.com → app1-service)
Service (10.43.123.45)
  ↓ (Selector: app=app1)
Pod (10.42.0.8)
  ↓ (Volume mount)
HTML File (/vagrant/apps/app1/index.html)
  ↓ (Response)
Browser
```

---

## **7. Why We Need Each Component**

Let me explain WHY each technology is necessary with real-world analogies.

---

### **7.1 Why K3s?**

**Real-world analogy:** Restaurant kitchen

```
Without K3s (Manual Cooking):
- You cook each dish yourself
- If you stop cooking, no food
- If you're sick, restaurant closed
- Can't handle 100 customers

With K3s (Professional Kitchen):
- Automatic cooking stations
- Self-cleaning
- If one chef sick, another takes over
- Can scale to 1000 customers
```

**In your project:**
- K3s ensures apps always run
- Restarts failed apps automatically
- Distributes load
- Scales easily

---

### **7.2 Why Vagrant?**

**Real-world analogy:** Cooking recipe

```
Without Vagrant:
- You tell each teammate:
  "Download Ubuntu, install VirtualBox,
   configure network, install K3s..."
- Takes 2 hours per person
- Everyone's setup slightly different

With Vagrant:
- You give Vagrantfile (recipe)
- Everyone runs: vagrant up
- Identical setup in 3 minutes
```

**In your project:**
- Reproducibility
- Same environment for everyone
- Easy cleanup
- Fast setup

---

### **7.3 Why Deployments?**

**Real-world analogy:** Manager

```
Without Deployment:
- You hire employee (Pod)
- Employee quits (Pod crashes)
- Position empty until you manually hire new one
- No backup plan

With Deployment (Manager):
- Manager ensures position always filled
- Employee quits → Manager hires replacement automatically
- Need 3 employees? Manager hires 3
- One quits? Manager maintains 3 total
```

**In your project:**
- Self-healing (app2 stays at 3 replicas)
- Easy scaling
- Rolling updates

---

### **7.4 Why Services?**

**Real-world analogy:** Phone number

```
Without Service:
- You call John's personal mobile (Pod IP)
- John changes phones (Pod restarts)
- New number (new IP)
- You can't reach him anymore

With Service:
- You call John's office number (Service IP)
- Office forwards to John's current mobile
- John changes phones → Office updates forwarding
- You always reach John
```

**In your project:**
- Stable networking
- Pod IPs change, Service IP doesn't
- Load balancing

---

### **7.5 Why Ingress?**

**Real-world analogy:** Hotel receptionist

```
Without Ingress:
- Each room has different phone number
  Room 101: 555-1001
  Room 102: 555-1002
  Room 103: 555-1003
- Guests must remember all numbers

With Ingress (Receptionist):
- Single number: 555-HOTEL
- Receptionist asks: "Which guest?"
- You say: "John Smith"
- Receptionist routes call to correct room
```

**In your project:**
- Single entry point (192.168.56.110:80)
- Hostname-based routing
- Clean URLs

---

### **7.6 Why Traefik?**

**Real-world analogy:** Actual receptionist

```
Ingress = Written instructions
"Route Mr. Smith calls to room 101"

Traefik = Receptionist who reads and executes instructions
Actually picks up phone
Actually routes calls
```

**In your project:**
- Implements Ingress rules
- Listens on port 80
- Routes traffic

---

### **7.7 Why Volumes?**

**Real-world analogy:** Shared drive

```
Without Volume:
- You write document on USB stick
- Give USB to colleague
- Colleague can't access it (different computer)

With Volume (Shared Drive):
- You write document on shared drive
- Colleague accesses same drive
- Both see same file
- Realtime updates
```

**In your project:**
- Share HTML between laptop and container
- Edit on laptop → Changes appear in container
- No need to rebuild container

---

### **7.8 Why ClusterIP?**

**Real-world analogy:** Internal office extension

```
ClusterIP:
- Like extension 101 in office
- Only works from inside office
- External callers can't reach it directly

NodePort:
- Like direct phone line 555-1234
- Anyone can call from outside
- Different number for each person

Ingress + ClusterIP:
- Receptionist (Ingress) has external number
- Receptionist routes to internal extensions (ClusterIP)
- Clean, organized
```

**In your project:**
- Services internal only (ClusterIP)
- Ingress provides external access
- Secure (services not exposed directly)

---

### **7.9 Why Load Balancing?**

**Real-world analogy:** Grocery store checkouts

```
Without Load Balancing:
- 100 customers
- 1 checkout open
- 100-person line
- 2 hour wait

With Load Balancing:
- 100 customers
- 3 checkouts open
- Lines of ~33 people each
- 30 minute wait
```

**In your project:**
- app2 has 3 Pods (3 checkouts)
- Traffic split across all 3
- Faster response
- Higher capacity

---

## **8. Visual Architecture Diagrams**

---

### **8.1 Full System Architecture**

```
┌──────────────────────────────────────────────────────────────────┐
│                        Your Laptop                               │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Browser                                                   │ │
│  │  http://app1.com                                           │ │
│  └─────────────────────────┬──────────────────────────────────┘ │
│                            │                                    │
│  ┌─────────────────────────▼──────────────────────────────────┐ │
│  │  /etc/hosts                                                │ │
│  │  app1.com → 192.168.56.110                                 │ │
│  └─────────────────────────┬──────────────────────────────────┘ │
│                            │                                    │
│  ┌─────────────────────────▼──────────────────────────────────┐ │
│  │  Project Folder                                            │ │
│  │  apps/app1/index.html ─────┐                               │ │
│  │  confs/deployment.yaml     │                               │ │
│  │  Vagrantfile               │                               │ │
│  └────────────────────────────┼────────────────────────────────┘ │
└─────────────────────────────┬─┼──────────────────────────────────┘
                              │ │
                              │ │ Synced folder
                              │ │
┌─────────────────────────────▼─▼──────────────────────────────────┐
│                    VirtualBox VM (192.168.56.110)                │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Vagrant                                                   │ │
│  │  - Created VM                                              │ │
│  │  - Installed K3s                                           │ │
│  │  - Configured network                                      │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  K3s Cluster                                               │ │
│  │                                                            │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │  System Pods (kube-system namespace)                 │ │ │
│  │  │                                                      │ │ │
│  │  │  ┌─────────────────────────────────────────────┐    │ │ │
│  │  │  │  Traefik (Ingress Controller)               │    │ │ │
│  │  │  │  Listens: port 80                           │    │ │ │
│  │  │  │  Reads: Ingress rules                       │    │ │ │
│  │  │  └────────────────┬────────────────────────────┘    │ │ │
│  │  │                   │                                 │ │ │
│  │  │  ┌────────────────┴────────────────────────────┐    │ │ │
│  │  │  │  CoreDNS (DNS)                              │    │ │ │
│  │  │  └─────────────────────────────────────────────┘    │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  │                                                            │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │  Your Applications (default namespace)               │ │ │
│  │  │                                                      │ │ │
│  │  │  ┌─────────────────────────────────────────────┐    │ │ │
│  │  │  │  Ingress: apps-ingress                      │    │ │ │
│  │  │  │  Rules:                                     │    │ │ │
│  │  │  │    app1.com → app1-service                  │    │ │ │
│  │  │  │    app2.com → app2-service                  │    │ │ │
│  │  │  │    *        → app3-service                  │    │ │ │
│  │  │  └────────────────┬────────────────────────────┘    │ │ │
│  │  │                   │                                 │ │ │
│  │  │  ┌────────────────┼────────────────────────────┐    │ │ │
│  │  │  │  Services      │                            │    │ │ │
│  │  │  │                │                            │    │ │ │
│  │  │  │  ┌─────────────▼──────────┐                 │    │ │ │
│  │  │  │  │ app1-service           │                 │    │ │ │
│  │  │  │  │ ClusterIP: 10.43.x.x   │                 │    │ │ │
│  │  │  │  │ Selector: app=app1     │                 │    │ │ │
│  │  │  │  └─────────────┬──────────┘                 │    │ │ │
│  │  │  │                │                            │    │ │ │
│  │  │  │  ┌─────────────▼──────────┐                 │    │ │ │
│  │  │  │  │ app2-service           │                 │    │ │ │
│  │  │  │  │ ClusterIP: 10.43.x.x   │                 │    │ │ │
│  │  │  │  │ Selector: app=app2     │                 │    │ │ │
│  │  │  │  └─────────────┬──────────┘                 │    │ │ │
│  │  │  │                │                            │    │ │ │
│  │  │  │  ┌─────────────▼──────────┐                 │    │ │ │
│  │  │  │  │ app3-service           │                 │    │ │ │
│  │  │  │  │ ClusterIP: 10.43.x.x   │                 │    │ │ │
│  │  │  │  │ Selector: app=app3     │                 │    │ │ │
│  │  │  │  └─────────────┬──────────┘                 │    │ │ │
│  │  │  └────────────────┼────────────────────────────┘    │ │ │
│  │  │                   │                                 │ │ │
│  │  │  ┌────────────────┼────────────────────────────┐    │ │ │
│  │  │  │  Deployments   │                            │    │ │ │
│  │  │  │                │                            │    │ │ │
│  │  │  │  ┌─────────────▼──────────┐                 │    │ │ │
│  │  │  │  │ app1-deployment        │                 │    │ │ │
│  │  │  │  │ Replicas: 1            │                 │    │ │ │
│  │  │  │  └─────────────┬──────────┘                 │    │ │ │
│  │  │  │                │                            │    │ │ │
│  │  │  │  ┌─────────────▼──────────┐                 │    │ │ │
│  │  │  │  │ app2-deployment        │                 │    │ │ │
│  │  │  │  │ Replicas: 3            │                 │    │ │ │
│  │  │  │  └─────────────┬──────────┘                 │    │ │ │
│  │  │  │                │                            │    │ │ │
│  │  │  │  ┌─────────────▼──────────┐                 │    │ │ │
│  │  │  │  │ app3-deployment        │                 │    │ │ │
│  │  │  │  │ Replicas: 1            │                 │    │ │ │
│  │  │  │  └─────────────┬──────────┘                 │    │ │ │
│  │  │  └────────────────┼────────────────────────────┘    │ │ │
│  │  │                   │                                 │ │ │
│  │  │  ┌────────────────▼────────────────────────────┐    │ │ │
│  │  │  │  Pods                                       │    │ │ │
│  │  │  │                                             │    │ │ │
│  │  │  │  Pod: app1-xxx                              │    │ │ │
│  │  │  │  ┌────────────────────────────────────┐     │    │ │ │
│  │  │  │  │  Container: nginx                  │     │    │ │ │
│  │  │  │  │  Volume: /vagrant/apps/app1        │     │    │ │ │
│  │  │  │  │  Serves: index.html                │     │    │ │ │
│  │  │  │  └────────────────────────────────────┘     │    │ │ │
│  │  │  │                                             │    │ │ │
│  │  │  │  Pod: app2-xxx (×3)                         │    │ │ │
│  │  │  │  ┌────────────────────────────────────┐     │    │ │ │
│  │  │  │  │  Container: nginx                  │     │    │ │ │
│  │  │  │  │  Volume: /vagrant/apps/app2        │     │    │ │ │
│  │  │  │  │  Serves: index.html                │     │    │ │ │
│  │  │  │  └────────────────────────────────────┘     │    │ │ │
│  │  │  │                                             │    │ │ │
│  │  │  │  Pod: app3-xxx                              │    │ │ │
│  │  │  │  ┌────────────────────────────────────┐     │    │ │ │
│  │  │  │  │  Container: nginx                  │     │    │ │ │
│  │  │  │  │  Volume: /vagrant/apps/app3        │     │    │ │ │
│  │  │  │  │  Serves: index.html                │     │    │ │ │
│  │  │  │  └────────────────────────────────────┘     │    │ │ │
│  │  │  └─────────────────────────────────────────────┘    │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────┌──────────────────────────────────────────────────────────────────┐
│                        Your Laptop                               │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Browser                                                   │ │
│  │  http://app1.com                                           │ │
│  └─────────────────────────┬──────────────────────────────────┘ │
│                            │                                    │
│  ┌─────────────────────────▼──────────────────────────────────┐ │
│  │  /etc/hosts                                                │ │
│  │  app1.com → 192.168.56.110                                 │ │
│  └─────────────────────────┬──────────────────────────────────┘ │
│                            │                                    │
│  ┌─────────────────────────▼──────────────────────────────────┐ │
│  │  Project Folder                                            │ │
│  │  apps/app1/index.html ─────┐                               │ │
│  │  confs/deployment.yaml     │                               │ │
│  │  Vagrantfile               │                               │ │
│  └────────────────────────────┼────────────────────────────────┘ │
└─────────────────────────────┬─┼──────────────────────────────────┘
                              │ │
                              │ │ Synced folder
                              │ │
┌─────────────────────────────▼─▼──────────────────────────────────┐
│                    VirtualBox VM (192.168.56.110)                │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Vagrant                                                   │ │
│  │  - Created VM                                              │ │
│  │  - Installed K3s                                           │ │
│  │  - Configured network                                      │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  K3s Cluster                                               │ │
│  │                                                            │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │  System Pods (kube-system namespace)                 │ │ │
│  │  │                                                      │ │ │
│  │  │  ┌─────────────────────────────────────────────┐    │ │ │
│  │  │  │  Traefik (Ingress Controller)               │    │ │ │
│  │  │  │  Listens: port 80                           │    │ │ │
│  │  │  │  Reads: Ingress rules                       │    │ │ │
│  │  │  └────────────────┬────────────────────────────┘    │ │ │
│  │  │                   │                                 │ │ │
│  │  │  ┌────────────────┴────────────────────────────┐    │ │ │
│  │  │  │  CoreDNS (DNS)                              │    │ │ │
│  │  │  └─────────────────────────────────────────────┘    │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  │                                                            │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │  Your Applications (default namespace)               │ │ │
│  │  │                                                      │ │ │
│  │  │  ┌─────────────────────────────────────────────┐    │ │ │
│  │  │  │  Ingress: apps-ingress                      │    │ │ │
│  │  │  │  Rules:                                     │    │ │ │
│  │  │  │    app1.com → app1-service                  │    │ │ │
│  │  │  │    app2.com → app2-service                  │    │ │ │
│  │  │  │    *        → app3-service                  │    │ │ │
│  │  │  └────────────────┬────────────────────────────┘    │ │ │
│  │  │                   │                                 │ │ │
│  │  │  ┌────────────────┼────────────────────────────┐    │ │ │
│  │  │  │  Services      │                            │    │ │ │
│  │  │  │                │                            │    │ │ │
│  │  │  │  ┌─────────────▼──────────┐                 │    │ │ │
│  │  │  │  │ app1-service           │                 │    │ │ │
│  │  │  │  │ ClusterIP: 10.43.x.x   │                 │    │ │ │
│  │  │  │  │ Selector: app=app1     │                 │    │ │ │
│  │  │  │  └─────────────┬──────────┘                 │    │ │ │
│  │  │  │                │                            │    │ │ │
│  │  │  │  ┌─────────────▼──────────┐                 │    │ │ │
│  │  │  │  │ app2-service           │                 │    │ │ │
│  │  │  │  │ ClusterIP: 10.43.x.x   │                 │    │ │ │
│  │  │  │  │ Selector: app=app2     │                 │    │ │ │
│  │  │  │  └─────────────┬──────────┘                 │    │ │ │
│  │  │  │                │                            │    │ │ │
│  │  │  │  ┌─────────────▼──────────┐                 │    │ │ │
│  │  │  │  │ app3-service           │                 │    │ │ │
│  │  │  │  │ ClusterIP: 10.43.x.x   │                 │    │ │ │
│  │  │  │  │ Selector: app=app3     │                 │    │ │ │
│  │  │  │  └─────────────┬──────────┘                 │    │ │ │
│  │  │  └────────────────┼────────────────────────────┘    │ │ │
│  │  │                   │                                 │ │ │
│  │  │  ┌────────────────┼────────────────────────────┐    │ │ │
│  │  │  │  Deployments   │                            │    │ │ │
│  │  │  │                │                            │    │ │ │
│  │  │  │  ┌─────────────▼──────────┐                 │    │ │ │
│  │  │  │  │ app1-deployment        │                 │    │ │ │
│  │  │  │  │ Replicas: 1            │                 │    │ │ │
│  │  │  │  └─────────────┬──────────┘                 │    │ │ │
│  │  │  │                │                            │    │ │ │
│  │  │  │  ┌─────────────▼──────────┐                 │    │ │ │
│  │  │  │  │ app2-deployment        │                 │    │ │ │
│  │  │  │  │ Replicas: 3            │                 │    │ │ │
│  │  │  │  └─────────────┬──────────┘                 │    │ │ │
│  │  │  │                │                            │    │ │ │
│  │  │  │  ┌─────────────▼──────────┐                 │    │ │ │
│  │  │  │  │ app3-deployment        │                 │    │ │ │
│  │  │  │  │ Replicas: 1            │                 │    │ │ │
│  │  │  │  └─────────────┬──────────┘                 │    │ │ │
│  │  │  └────────────────┼────────────────────────────┘    │ │ │
│  │  │                   │                                 │ │ │
│  │  │  ┌────────────────▼────────────────────────────┐    │ │ │
│  │  │  │  Pods                                       │    │ │ │
│  │  │  │                                             │    │ │ │
│  │  │  │  Pod: app1-xxx                              │    │ │ │
│  │  │  │  ┌────────────────────────────────────┐     │    │ │ │
│  │  │  │  │  Container: nginx                  │     │    │ │ │
│  │  │  │  │  Volume: /vagrant/apps/app1        │     │    │ │ │
│  │  │  │  │  Serves: index.html                │     │    │ │ │
│  │  │  │  └────────────────────────────────────┘     │    │ │ │
│  │  │  │                                             │    │ │ │
│  │  │  │  Pod: app2-xxx (×3)                         │    │ │ │
│  │  │  │  ┌────────────────────────────────────┐     │    │ │ │
│  │  │  │  │  Container: nginx                  │     │    │ │ │
│  │  │  │  │  Volume: /vagrant/apps/app2        │     │    │ │ │
│  │  │  │  │  Serves: index.html                │     │    │ │ │
│  │  │  │  └────────────────────────────────────┘     │    │ │ │
│  │  │  │                                             │    │ │ │
│  │  │  │  Pod: app3-xxx                              │    │ │ │
│  │  │  │  ┌────────────────────────────────────┐     │    │ │ │
│  │  │  │  │  Container: nginx                  │     │    │ │ │
│  │  │  │  │  Volume: /vagrant/apps/app3        │     │    │ │ │
│  │  │  │  │  Serves: index.html                │     │    │ │ │
│  │  │  │  └────────────────────────────────────┘     │    │ │ │
│  │  │  └─────────────────────────────────────────────┘    │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────