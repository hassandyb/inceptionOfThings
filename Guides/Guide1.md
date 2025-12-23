# 🚀 PART 1: K3s and Vagrant - Complete Implementation Guide

**Goal:** Build a 2-node K3s cluster that matches the subject requirements EXACTLY.

---

## **📋 Subject Requirements Checklist**

Before we start, let's understand what we MUST deliver:

```
✅ 2 VMs using Vagrant
✅ Latest stable OS (Ubuntu 22.04 recommended)
✅ Minimal resources: 1 CPU, 512MB RAM (we'll use 1024MB for stability)
✅ Machine names: <login>S and <login>SW
✅ IPs: 192.168.56.110 (Server) and 192.168.56.111 (Worker)
✅ SSH without password (Vagrant handles this)
✅ K3s on Server in controller mode
✅ K3s on Worker in agent mode
✅ kubectl working on Server
✅ Modern Vagrantfile practices
```

---

## **Phase 0: Compare Reference vs Your Implementation**

### **Step 0.1: Analyze Reference Project**

```bash
cd ~/Desktop/inceptionOfThings/ref/p1
```

**Look at the structure:**
```bash
tree
```

**Expected:**
```
p1/
├── Vagrantfile
└── scripts/
    ├── server.sh
    └── worker.sh
```

---

### **Step 0.2: Read Reference Vagrantfile**

```bash
cat Vagrantfile
```

**Key things to notice:**
1. What OS box is used?
2. How are resources allocated?
3. How are scripts called?
4. Any special configurations?

**Paste the content here and let's analyze it together!**

---

### **Step 0.3: Read Reference Scripts**

```bash
cat scripts/server.sh
```

**What does it do?**
- [ ] Install K3s?
- [ ] Configure anything?
- [ ] Export token?

```bash
cat scripts/worker.sh
```

**What does it do?**
- [ ] Wait for server?
- [ ] Read token?
- [ ] Join cluster?

**Paste both scripts here!**

---

## **Phase 1: Clean Your Environment**

### **Step 1.1: Navigate to Your Project**

```bash
cd ~/Desktop/inceptionOfThings/z_inceptionOfThings/p1
pwd
```

**Confirm you're in the right place.**

---

### **Step 1.2: Check Current State**

```bash
vagrant status
```

**What do you see?**

---

### **Step 1.3: Destroy Everything**

```bash
vagrant destroy -f
```

**Why?** Fresh start prevents conflicts.

---

### **Step 1.4: Clean Vagrant Metadata**

```bash
rm -rf .vagrant
ls -la
```

**Should only see:**
```
Vagrantfile
scripts/
```

---

## **Phase 2: Build Production Vagrantfile (Step by Step)**

### **Step 2.1: Create Minimal Vagrantfile Structure**

```bash
nano Vagrantfile
```

**Start with the ABSOLUTE MINIMUM:**

````ruby
Vagrant.configure("2") do |config|
  # We'll add everything here step by step
end
````

**Save it.** (Ctrl+O, Enter, Ctrl+X)

**Test it:**
```bash
vagrant validate
```

**Should say:** "Vagrantfile validated successfully."

---

### **Step 2.2: Add Base Box Configuration**

```bash
nano Vagrantfile
```

**Add this INSIDE the config block:**

````ruby
Vagrant.configure("2") do |config|
  # Base OS - Using Ubuntu 22.04 (latest stable)
  config.vm.box = "ubuntu/jammy64"
  
  # Disable automatic box updates (speeds up boot)
  config.vm.box_check_update = false
end
````

**What did we just do?**
- `ubuntu/jammy64` = Ubuntu 22.04 LTS (stable, modern)
- `box_check_update = false` = Don't waste time checking for updates

**Save and validate:**
```bash
vagrant validate
```

---

### **Step 2.3: Add Server VM Definition**

```bash
nano Vagrantfile
```

**Add Server VM BEFORE the final `end`:**

````ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.box_check_update = false

  # ============================================
  # SERVER (Controller) - hed-dybS
  # ============================================
  config.vm.define "hed-dybS" do |server|
    # Hostname
    server.vm.hostname = "hed-dybS"
    
    # Network - Static IP
    server.vm.network "private_network", ip: "192.168.56.110"
    
    # VirtualBox configuration
    server.vm.provider "virtualbox" do |vb|
      vb.name = "hed-dybS"
      vb.memory = "1024"  # Subject says 512, but 1024 is more stable
      vb.cpus = 1
    end
  end
end
````

**What did we configure?**
- `vm.define "hed-dybS"` = VM name in Vagrant
- `vm.hostname` = Hostname inside the VM
- `vm.network` = Private network with static IP
- `vb.name` = Name in VirtualBox GUI
- `vb.memory` = RAM allocation
- `vb.cpus` = CPU cores

**Save and validate:**
```bash
vagrant validate
```

---

### **Step 2.4: Test Server VM (No K3s Yet)**

```bash
vagrant up hed-dybS
```

**Watch the output!** This will:
1. Download Ubuntu 22.04 box (first time only)
2. Create VM
3. Configure network
4. Boot the VM

**This takes 2-3 minutes the first time.**

---

### **Step 2.5: Verify Server VM**

```bash
vagrant status
```

**Should show:**
```
hed-dybS                  running (virtualbox)
```

**SSH into it:**
```bash
vagrant ssh hed-dybS
```

**Inside the VM, run:**
```bash
# Check hostname
hostname

# Check IP address
ip a show eth1

# Check OS version
lsb_release -a
```

**Expected:**
- Hostname: `hed-dybS`
- IP: `192.168.56.110`
- OS: Ubuntu 22.04.x LTS

**Exit:**
```bash
exit
```

---

### **Step 2.6: Add Worker VM Definition**

```bash
nano Vagrantfile
```

**Add Worker VM BEFORE the final `end`:**

````ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.box_check_update = false

  # SERVER (already there)
  config.vm.define "hed-dybS" do |server|
    server.vm.hostname = "hed-dybS"
    server.vm.network "private_network", ip: "192.168.56.110"
    server.vm.provider "virtualbox" do |vb|
      vb.name = "hed-dybS"
      vb.memory = "1024"
      vb.cpus = 1
    end
  end

  # ============================================
  # WORKER (Agent) - hed-dybSW
  # ============================================
  config.vm.define "hed-dybSW" do |worker|
    # Hostname
    worker.vm.hostname = "hed-dybSW"
    
    # Network - Static IP
    worker.vm.network "private_network", ip: "192.168.56.111"
    
    # VirtualBox configuration
    worker.vm.provider "virtualbox" do |vb|
      vb.name = "hed-dybSW"
      vb.memory = "1024"
      vb.cpus = 1
    end
  end
end
````

**Save and validate:**
```bash
vagrant validate
```

---

### **Step 2.7: Test Both VMs (No K3s Yet)**

**Destroy the server:**
```bash
vagrant destroy -f
```

**Start both VMs:**
```bash
vagrant up
```

**Watch both VMs start!**

---

### **Step 2.8: Verify Both VMs**

```bash
vagrant status
```

**Should show:**
```
hed-dybS                  running (virtualbox)
hed-dybSW                 running (virtualbox)
```

**Test SSH to both:**
```bash
# Server
vagrant ssh hed-dybS -c "hostname && ip a show eth1 | grep inet"

# Worker
vagrant ssh hed-dybSW -c "hostname && ip a show eth1 | grep inet"
```

**Expected output:**
```
Server:
hed-dybS
    inet 192.168.56.110/24

Worker:
hed-dybSW
    inet 192.168.56.111/24
```

**Perfect! VMs are ready. Now let's add K3s.**

---

## **Phase 3: Build Server Provisioning Script**

### **Step 3.1: Create Scripts Directory**

```bash
mkdir -p scripts
ls
```

---

### **Step 3.2: Build Server Script - Minimal Version**

```bash
nano scripts/server.sh
```

**Start with the ABSOLUTE MINIMUM:**

````bash
#!/bin/bash

echo "=========================================="
echo "  Server Setup Started"
echo "=========================================="

echo "✅ Server script executed!"
````

**Save it.**

**Make it executable:**
```bash
chmod +x scripts/server.sh
```

---

### **Step 3.3: Link Script to Vagrantfile**

```bash
nano Vagrantfile
```

**Add provisioning to Server block:**

````ruby
  config.vm.define "hed-dybS" do |server|
    server.vm.hostname = "hed-dybS"
    server.vm.network "private_network", ip: "192.168.56.110"
    server.vm.provider "virtualbox" do |vb|
      vb.name = "hed-dybS"
      vb.memory = "1024"
      vb.cpus = 1
    end
    
    # Provisioning script
    server.vm.provision "shell", path: "scripts/server.sh"
  end
````

**Save and validate:**
```bash
vagrant validate
```

---

### **Step 3.4: Test Script Execution**

```bash
vagrant destroy -f
vagrant up hed-dybS
```

**Watch for:**
```
==> hed-dybS: Running provisioner: shell...
    hed-dybS: ==========================================
    hed-dybS:   Server Setup Started
    hed-dybS: ==========================================
    hed-dybS: ✅ Server script executed!
```

**Did you see it? Good! Script execution works.**

---

### **Step 3.5: Add System Update to Server Script**

```bash
nano scripts/server.sh
```

````bash
#!/bin/bash

set -e  # Exit on any error

echo "=========================================="
echo "  Server Setup Started"
echo "=========================================="

# Step 1: Update system
echo "[1/4] Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq > /dev/null 2>&1

echo "✅ System updated!"
````

**What's new?**
- `set -e` = Stop script if any command fails
- `DEBIAN_FRONTEND=noninteractive` = No prompts
- `-qq` = Quiet mode
- `> /dev/null 2>&1` = Hide output (cleaner logs)

**Save it.**

---

### **Step 3.6: Test System Update**

```bash
vagrant destroy hed-dybS -f
vagrant up hed-dybS
```

**Watch for:**
```
[1/4] Updating system packages...
✅ System updated!
```

**Takes ~30 seconds.**

---

### **Step 3.7: Add K3s Installation to Server Script**

```bash
nano scripts/server.sh
```

````bash
#!/bin/bash

set -e

echo "=========================================="
echo "  Server Setup Started"
echo "=========================================="

# Step 1: Update system
echo "[1/4] Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq > /dev/null 2>&1

# Step 2: Install K3s in server mode
echo "[2/4] Installing K3s server..."
curl -sfL https://get.k3s.io | sh -s - \
  --write-kubeconfig-mode 644 \
  --node-name hed-dybS

echo "✅ K3s installed!"
````

**What does this do?**
- `curl -sfL https://get.k3s.io` = Download K3s installer
- `| sh -s -` = Pipe to shell and execute
- `--write-kubeconfig-mode 644` = Make kubeconfig readable (allows kubectl without sudo)
- `--node-name hed-dybS` = Set node name explicitly

**Save it.**

---

### **Step 3.8: Test K3s Installation**

```bash
vagrant destroy hed-dybS -f
vagrant up hed-dybS
```

**This takes 3-4 minutes.** Watch for:
```
[2/4] Installing K3s server...
✅ K3s installed!
```

---

### **Step 3.9: Verify K3s is Running**

```bash
vagrant ssh hed-dybS
```

**Inside the VM:**

```bash
# Check K3s service
sudo systemctl status k3s

# Check nodes
kubectl get nodes
```

**Expected:**
```
NAME       STATUS   ROLES                  AGE   VERSION
hed-dybs   Ready    control-plane,master   30s   v1.28.x+k3s1
```

**Exit:**
```bash
exit
```

---

### **Step 3.10: Add Token Export to Server Script**

```bash
nano scripts/server.sh
```

````bash
#!/bin/bash

set -e

echo "=========================================="
echo "  Server Setup Started"
echo "=========================================="

# Step 1: Update system
echo "[1/4] Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq > /dev/null 2>&1

# Step 2: Install K3s
echo "[2/4] Installing K3s server..."
curl -sfL https://get.k3s.io | sh -s - \
  --write-kubeconfig-mode 644 \
  --node-name hed-dybS

# Step 3: Wait for K3s to be fully ready
echo "[3/4] Waiting for K3s to be ready..."
sleep 10

# Step 4: Export token for worker
echo "[4/4] Exporting join token..."
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/token.txt
chmod 644 /vagrant/token.txt

echo "=========================================="
echo "✅ Server setup complete!"
echo "=========================================="

# Show cluster status
kubectl get nodes
````

**What's new?**
- `sleep 10` = Give K3s time to start fully
- `/var/lib/rancher/k3s/server/node-token` = K3s join token (more reliable than `token`)
- `> /vagrant/token.txt` = Save to shared folder
- `chmod 644` = Make file readable

**Save it.**

---

### **Step 3.11: Test Token Export**

```bash
vagrant destroy hed-dybS -f
vagrant up hed-dybS
```

**After it finishes:**

```bash
# On host machine
ls -la token.txt
cat token.txt
```

**You should see:**
```
K10abc123def456...::server:789xyz...
```

**That's the join token!**

---

## **Phase 4: Build Worker Provisioning Script**

### **Step 4.1: Build Worker Script - Minimal Version**

```bash
nano scripts/worker.sh
```

````bash
#!/bin/bash

echo "=========================================="
echo "  Worker Setup Started"
echo "=========================================="

echo "✅ Worker script executed!"
````

**Save and make executable:**
```bash
chmod +x scripts/worker.sh
```

---

### **Step 4.2: Link Worker Script to Vagrantfile**

```bash
nano Vagrantfile
```

**Add provisioning to Worker block:**

````ruby
  config.vm.define "hed-dybSW" do |worker|
    worker.vm.hostname = "hed-dybSW"
    worker.vm.network "private_network", ip: "192.168.56.111"
    worker.vm.provider "virtualbox" do |vb|
      vb.name = "hed-dybSW"
      vb.memory = "1024"
      vb.cpus = 1
    end
    
    # Provisioning script
    worker.vm.provision "shell", path: "scripts/worker.sh"
  end
````

**Save and validate:**
```bash
vagrant validate
```

---

### **Step 4.3: Test Worker Script Execution**

```bash
vagrant destroy hed-dybSW -f
vagrant up hed-dybSW
```

**Watch for:**
```
Worker Setup Started
✅ Worker script executed!
```

---

### **Step 4.4: Add Wait Logic to Worker Script**

```bash
nano scripts/worker.sh
```

````bash
#!/bin/bash

set -e

echo "=========================================="
echo "  Worker Setup Started"
echo "=========================================="

# Step 1: Wait for server
echo "[1/5] Waiting for server to be ready..."
sleep 30

echo "✅ Wait complete!"
````

**Why 30 seconds?**
- Server needs time to install K3s
- Export the token
- Be fully ready

**Save it.**

---

### **Step 4.5: Add Token Check to Worker Script**

```bash
nano scripts/worker.sh
```

````bash
#!/bin/bash

set -e

echo "=========================================="
echo "  Worker Setup Started"
echo "=========================================="

# Step 1: Wait for server
echo "[1/5] Waiting for server to be ready..."
sleep 30

# Step 2: Check for token
echo "[2/5] Checking for join token..."
if [ ! -f /vagrant/token.txt ]; then
  echo "❌ ERROR: Token file not found!"
  echo "   Server may not have finished setup."
  exit 1
fi

TOKEN=$(cat /vagrant/token.txt)
echo "✅ Token found: ${TOKEN:0:20}..."
````

**What's new?**
- `[ ! -f /vagrant/token.txt ]` = Check if file exists
- `exit 1` = Stop script with error
- `${TOKEN:0:20}` = Show first 20 characters (for security)

**Save it.**

---

### **Step 4.6: Test Token Detection**

```bash
vagrant destroy -f
vagrant up
```

**Watch Worker output:**
```
[1/5] Waiting for server to be ready...
[2/5] Checking for join token...
✅ Token found: K10abc123def456789...
```

**Good! Worker can read the token.**

---

### **Step 4.7: Add K3s Agent Installation to Worker Script**

```bash
nano scripts/worker.sh
```

````bash
#!/bin/bash

set -e

echo "=========================================="
echo "  Worker Setup Started"
echo "=========================================="

# Step 1: Wait for server
echo "[1/5] Waiting for server to be ready..."
sleep 30

# Step 2: Check for token
echo "[2/5] Checking for join token..."
if [ ! -f /vagrant/token.txt ]; then
  echo "❌ ERROR: Token file not found!"
  exit 1
fi

TOKEN=$(cat /vagrant/token.txt)
echo "✅ Token found!"

# Step 3: Update system
echo "[3/5] Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq > /dev/null 2>&1

# Step 4: Install K3s in agent mode
echo "[4/5] Installing K3s agent..."
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 \
  K3S_TOKEN=$TOKEN \
  sh -s - \
  --node-name hed-dybSW

# Step 5: Wait for agent to start
echo "[5/5] Waiting for agent to connect..."
sleep 10

echo "=========================================="
echo "✅ Worker setup complete!"
echo "=========================================="
````

**What's new?**
- `K3S_URL=https://192.168.56.110:6443` = Tell worker where server is
- `K3S_TOKEN=$TOKEN` = Pass the join token
- `--node-name hed-dybSW` = Set worker node name

**Save it.**

---

### **Step 4.8: Test Full Cluster**

```bash
vagrant destroy -f
vagrant up
```

**This starts BOTH VMs and:**
1. Server installs K3s
2. Server exports token
3. Worker waits 30s
4. Worker reads token
5. Worker joins cluster

**Total time: 5-7 minutes.**

---

## **Phase 5: Verification & Testing**

### **Step 5.1: Check Vagrant Status**

```bash
vagrant status
```

**Expected:**
```
hed-dybS                  running (virtualbox)
hed-dybSW                 running (virtualbox)
```

---

### **Step 5.2: Verify Cluster from Server**

```bash
vagrant ssh hed-dybS
```

**Inside Server VM:**

```bash
# Check nodes
kubectl get nodes

# Expected output:
# NAME        STATUS   ROLES                  AGE   VERSION
# hed-dybs    Ready    control-plane,master   3m    v1.28.x+k3s1
# hed-dybsw   Ready    <none>                 1m    v1.28.x+k3s1
```

**Both nodes should show `Ready`!**

---

### **Step 5.3: Detailed Node Information**

```bash
kubectl get nodes -o wide
```

**Check these columns:**
- **INTERNAL-IP**: Should be 192.168.56.110 and .111
- **CONTAINER-RUNTIME**: Should be `containerd://...` (NOT docker!)
- **OS-IMAGE**: Should be Ubuntu 22.04

---

### **Step 5.4: Check K3s Version**

```bash
k3s --version
```

**Should show latest stable** (e.g., v1.28.x or v1.29.x)

---

### **Step 5.5: Check System Pods**

```bash
kubectl get pods -A
```

**You should see:**
- `kube-system/coredns` - DNS
- `kube-system/local-path-provisioner` - Storage
- `kube-system/metrics-server` - Monitoring
- `kube-system/traefik` - Ingress

**All should be `Running`.**

---

### **Step 5.6: Test kubectl Without Sudo**

```bash
# This should work WITHOUT sudo:
kubectl cluster-info

# Check kubeconfig permissions:
ls -la /etc/rancher/k3s/k3s.yaml
```

**Permissions should be `-rw-r--r--`** (world-readable)

---

### **Step 5.7: Test from Worker (Should Fail)**

```bash
exit  # Leave server
vagrant ssh hed-dybSW
```

**Try kubectl on worker:**
```bash
kubectl get nodes
```

**Expected error:**
```
The connection to the server localhost:8080 was refused
```

**This is CORRECT!** Workers don't run the API server.

---

### **Step 5.8: Check Worker Service**

```bash
sudo systemctl status k3s-agent
```

**Should show:**
- `active (running)`
- No errors

**Exit worker:**
```bash
exit
```

---

## **Phase 6: Application Deployment Tests**

### **Step 6.1: Deploy Test Application**

```bash
vagrant ssh hed-dybS
```

**Create deployment:**
```bash
kubectl create deployment nginx-test --image=nginx --replicas=3
```

---

### **Step 6.2: Watch Pods Deploy**

```bash
kubectl get pods -o wide --watch
```

**Watch STATUS change:**
- `ContainerCreating` → Downloading image
- `Running` → Ready!

**Press Ctrl+C when all 3 are Running.**

---

### **Step 6.3: Check Pod Distribution**

```bash
kubectl get pods -o wide | grep nginx-test
```

**Look at the NODE column.** Example:
```
nginx-test-xxx   1/1   Running   hed-dybs    
nginx-test-yyy   1/1   Running   hed-dybsw   
nginx-test-zzz   1/1   Running   hed-dybsw   
```

**Pods should be on BOTH nodes!** This proves cluster load-balancing works.

---

### **Step 6.4: Test Scaling**

```bash
kubectl scale deployment nginx-test --replicas=5
kubectl get pods -o wide
```

**Do you now have 5 pods distributed across both nodes?**

---

### **Step 6.5: Create Service**

```bash
kubectl expose deployment nginx-test --port=80 --type=ClusterIP
```

**Check service:**
```bash
kubectl get svc nginx-test
```

**Should show a CLUSTER-IP.**

---

### **Step 6.6: Test Service Connectivity**

```bash
# Get service IP
CLUSTER_IP=$(kubectl get svc nginx-test -o jsonpath='{.spec.clusterIP}')

# Verify variable is set
echo "Testing: $CLUSTER_IP"

# Wait for endpoints
kubectl wait --for=condition=ready pod -l app=nginx-test --timeout=60s

# Test connection
curl -s $CLUSTER_IP | grep "<title>"
```

**Expected:**
```
<title>Welcome to nginx!</title>
```

**If it fails, check:**
```bash
kubectl get endpoints nginx-test
```

**Should show 5 IP addresses (one per pod).**

---

### **Step 6.7: Test Load Balancing**

```bash
# Make 10 requests and show which pod responded
for i in {1..10}; do
  curl -s $CLUSTER_IP | grep -o 'nginx-test-[^"]*' | head -1
done
```

**You should see different pod names** (proving load balancing)!

---

### **Step 6.8: Clean Up Test Resources**

```bash
kubectl delete deployment nginx-test
kubectl delete service nginx-test

# Verify cleanup
kubectl get all
```

**Should only see the `kubernetes` service.**

**Exit server:**
```bash
exit
```

---

## **Phase 7: Subject Compliance Final Check**

### **Step 7.1: Requirements Verification**

```bash
vagrant ssh hed-dybS
```

**Run ALL these checks:**

````bash
# ✅ Check hostnames
kubectl get nodes
# Expected: hed-dybs and hed-dybsw

# ✅ Check IPs
kubectl get nodes -o wide | awk '{print $1, $6}'
# Expected: 192.168.56.110 and 192.168.56.111

# ✅ Check K3s version (latest stable)
k3s --version

# ✅ Check container runtime (containerd, NOT docker)
kubectl get nodes -o wide | grep -i container

# ✅ Check server role
kubectl get nodes | grep control-plane

# ✅ Check worker role (no special role)
kubectl get nodes | grep "<none>"

# ✅ kubectl works without sudo
kubectl cluster-info

# ✅ Check resources
kubectl top nodes
````

**All checks pass? Perfect!**

**Exit:**
```bash
exit
```

---

### **Step 7.2: Test VM Resource Usage**

```bash
vboxmanage showvminfo hed-dybS | grep -E "Memory|Number of CPUs"
vboxmanage showvminfo hed-dybSW | grep -E "Memory|Number of CPUs"
```

**Expected:**
```
Memory size:                 1024MB
Number of CPUs:              1
```

---

### **Step 7.3: Test SSH Without Password**

```bash
# Should work immediately (Vagrant handles SSH keys):
vagrant ssh hed-dybS -c "echo SSH works!"
vagrant ssh hed-dybSW -c "echo SSH works!"
```

---

### **Step 7.4: Test Network Connectivity Between VMs**

```bash
vagrant ssh hed-dybS
```

**Inside server:**
```bash
# Ping worker
ping -c 3 192.168.56.111

# SSH to worker (using Vagrant's shared keys)
ssh 192.168.56.111 "hostname"
```

**Should show:** `hed-dybSW`

**Exit:**
```bash
exit
```

---

## **Phase 8: Stress Testing**

### **Step 8.1: Test Cluster Resilience - Restart Worker**

```bash
vagrant halt hed-dybSW
vagrant up hed-dybSW
```

**After worker restarts:**
```bash
vagrant ssh hed-dybS
kubectl get nodes
```

**Worker should automatically rejoin and show `Ready`!**

---

### **Step 8.2: Test Failover - Deploy While Worker is Down**

**Halt worker:**
```bash
exit  # Leave server
vagrant halt hed-dybSW
```

**Deploy while worker is down:**
```bash
vagrant ssh hed-dybS
kubectl create deployment resilience-test --image=nginx --replicas=3
kubectl get pods -o wide
```

**All pods should be on server only.**

**Bring worker back:**
```bash
exit
vagrant up hed-dybSW
```

**Scale deployment:**
```bash
vagrant ssh hed-dybS
kubectl scale deployment resilience-test --replicas=6
kubectl get pods -o wide
```

**New pods should go to worker!**

**Clean up:**
```bash
kubectl delete deployment resilience-test
exit
```

---

### **Step 8.3: Full Cluster Rebuild Test**

```bash
vagrant destroy -f
time vagrant up
```

**Measure the time.** Should be < 8 minutes.

**Verify immediately after:**
```bash
vagrant ssh hed-dybS -c "kubectl get nodes"
```

**Both nodes Ready? Perfect!**

---

## **Phase 9: Documentation**

### **Step 9.1: Create README.md**

```bash
nano README.md
```

````markdown
# Part 1: K3s Cluster with Vagrant

## 📋 Architecture

- **Server (hed-dybS)**: 192.168.56.110
  - Role: Control Plane / Master
  - K3s in server mode
  
- **Worker (hed-dybSW)**: 192.168.56.111
  - Role: Agent
  - K3s in agent mode

## ✅ Requirements Met

- [x] 2 VMs using Vagrant
- [x] Ubuntu 22.04 LTS (latest stable)
- [x] 1 CPU, 1024MB RAM per VM
- [x] Static IPs: .110 (server) and .111 (worker)
- [x] SSH without password (Vagrant handles this)
- [x] K3s in controller mode (server)
- [x] K3s in agent mode (worker)
- [x] kubectl working on server
- [x] Containerd runtime (no Docker)

## 🚀 Usage

### Start Cluster
```bash
vagrant up
```

### Check Status
```bash
vagrant status
```

### SSH to Server
```bash
vagrant ssh hed-dybS
```

### Check Cluster
```bash
vagrant ssh hed-dybS -c "kubectl get nodes"
```

### Stop Cluster
```bash
vagrant halt
```

### Destroy Cluster
```bash
vagrant destroy -f
```

## 🧪 Verification

```bash
# Check nodes
vagrant ssh hed-dybS -c "kubectl get nodes -o wide"

# Check pods
vagrant ssh hed-dybS -c "kubectl get pods -A"

# Deploy test
vagrant ssh hed-dybS -c "kubectl create deployment nginx --image=nginx --replicas=3"
vagrant ssh hed-dybS -c "kubectl get pods -o wide"
```

## 🔧 Troubleshooting

### Worker not joining
```bash
# Check token exists
cat token.txt

# Check server is ready
vagrant ssh hed-dybS -c "sudo systemctl status k3s"

# Increase wait time in scripts/worker.sh (line: sleep 30)
```

### Kubectl not working
```bash
# Check kubeconfig permissions
vagrant ssh hed-dybS -c "ls -la /etc/rancher/k3s/k3s.yaml"
# Should be: -rw-r--r--
```

### Pods not distributing
```bash
# Check worker is Ready
vagrant ssh hed-dybS -c "kubectl get nodes"

# Check node labels
vagrant ssh hed-dybS -c "kubectl get nodes --show-labels"
```

## 📊 Performance

- **Cluster startup time**: 5-7 minutes
- **Pod creation time**: ~10 seconds
- **VM resource usage**: 1 CPU, 1GB RAM each

## 🎓 Learning Points

- Vagrant for VM orchestration
- K3s lightweight Kubernetes
- Server/Agent cluster architecture
- Shared folder for inter-VM communication
- Token-based node joining
- Kubectl cluster management
````

**Save it.**

---

### **Step 9.2: Create .gitignore**

```bash
nano .gitignore
```

````
# Vagrant
.vagrant/
*.log

# K3s
token.txt

# OS
.DS_Store
Thumbs.db
````

**Save it.**

---

## **Phase 10: Final Validation**

### **Step 10.1: Clean Build Test**

```bash
vagrant destroy -f
vagrant up
```

**Should complete with no errors.**

---

### **Step 10.2: Screenshot Requirements**

**Take these screenshots for submission:**

1. **Vagrant status showing both VMs running:**
```bash
vagrant status
```

2. **Both nodes Ready:**
```bash
vagrant ssh hed-dybS -c "kubectl get nodes"
```

3. **Network configuration (eth1):**
```bash
vagrant ssh hed-dybS -c "ip a show eth1"
```

4. **Pods distributed across nodes:**
```bash
vagrant ssh hed-dybS -c "kubectl create deployment demo --image=nginx --replicas=4"
sleep 20
vagrant ssh hed-dybS -c "kubectl get pods -o wide"
```

---

### **Step 10.3: Create Verification Script**

```bash
nano verify.sh
```

````bash
#!/bin/bash

echo "=========================================="
echo "  Part 1 Verification Script"
echo "=========================================="

echo ""
echo "1. Checking Vagrant status..."
vagrant status

echo ""
echo "2. Checking both nodes..."
vagrant ssh hed-dybS -c "kubectl get nodes -o wide"

echo ""
echo "3. Checking system pods..."
vagrant ssh hed-dybS -c "kubectl get pods -A"

echo ""
echo "4. Testing deployment..."
vagrant ssh hed-dybS -c "kubectl create deployment verify --image=nginx --replicas=3"
sleep 15
vagrant ssh hed-dybS -c "kubectl get pods -o wide"
vagrant ssh hed-dybS -c "kubectl delete deployment verify"

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

## **🎓 Knowledge Verification Quiz**

**Answer these to prove you understand:**

### **Q1: Vagrant**
What's the difference between `vagrant halt`, `vagrant suspend`, and `vagrant destroy`?

### **Q2: K3s Architecture**
Why can't you run `kubectl` commands on the worker node?

### **Q3: Networking**
Explain what `/vagrant` is and how files appear in it from both host and VMs.

### **Q4: Token**
What is the token used for and where is it stored?

### **Q5: Container Runtime**
How do you verify K3s is using containerd and not Docker?

### **Q6: Node Roles**
What's the difference between a "control-plane" node and an "agent" node?

### **Q7: Scheduling**
When you create a deployment with 3 replicas, how does Kubernetes decide which node to put each pod on?

---

## **✅ Final Checklist**

**Before submitting, verify:**

- [ ] `vagrant up` works without errors
- [ ] `vagrant status` shows both VMs running
- [ ] Both nodes show `Ready` status
- [ ] Nodes have correct hostnames (hed-dybS, hed-dybSW)
- [ ] Nodes have correct IPs (.110, .111)
- [ ] kubectl works without sudo on server
- [ ] kubectl fails on worker (correct behavior)
- [ ] Container runtime is containerd (not docker)
- [ ] Can deploy pods and they distribute
- [ ] Token file is auto-created
- [ ] Can destroy and rebuild successfully
- [ ] README is complete
- [ ] Screenshots are taken
- [ ] Understand all quiz answers

---

## **🎯 Success Criteria**

**Your cluster passes when:**

```bash
# This returns 2:
vagrant ssh hed-dybS -c "kubectl get nodes --no-headers | grep -c Ready"

# This works:
vagrant ssh hed-dybS -c "kubectl create deployment test --image=nginx && kubectl wait --for=condition=ready pod -l app=test --timeout=60s && kubectl delete deployment test"

# This is fast:
time (vagrant destroy -f && vagrant up)
# Should be < 10 minutes
```

---

**🎉 CONGRATULATIONS! Part 1 is complete!**

Now show me your:
1. Output of `vagrant status`
2. Output of `kubectl get nodes -o wide`
3. Output of a test deployment
4. Any questions you have!

**Ready for Part 2?** 🚀