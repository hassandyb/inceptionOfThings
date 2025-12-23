# 🎓 PART 2: K3s - TRUE LEARNING BY DOING (Build, Break, Test, Repeat!)

**New Approach:** We'll build EACH piece separately, test it, understand what happens, break it, fix it, then move to next piece.

---

## **🎯 Learning Philosophy**

```
❌ Old way: Type 200 lines → Deploy → Hope it works
✅ New way: Add 5 lines → Test → Understand → Add 5 more
```

**You'll learn by:**
1. Building incrementally
2. Testing every change
3. Breaking things on purpose
4. Understanding errors
5. Fixing problems yourself

---

## **Phase 0: Setup Minimal Environment**

### **Step 0.1: Create Clean Project**

```bash
cd ~/Desktop/inceptionOfThings/iot
rm -rf p2  # Start fresh
mkdir -p p2/{scripts,confs,apps/app1}
cd p2
```

**Test:**
```bash
tree
```

**Expected:**
```
p2/
├── apps/
│   └── app1/
├── confs/
└── scripts/
```

---

### **Step 0.2: Create Simplest Possible HTML**

```bash
nano apps/app1/index.html
```

**Type ONLY this (minimal HTML):**
```html
<h1>App 1 Works!</h1>
```

**Save it.**

**Test:**
```bash
cat apps/app1/index.html
```

**Should show:** `<h1>App 1 Works!</h1>`

---

## **Phase 1: Deploy ONE Pod Manually (Learn Pods)**

### **📚 Goal: Understand what a Pod is**

**We'll:**
1. Create 1 pod manually
2. See it running
3. Access it
4. Break it
5. Fix it

---

### **Step 1.1: Create Minimal Vagrantfile**

```bash
nano Vagrantfile
```

**Type this MINIMAL config:**
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  
  config.vm.define "test" do |server|
    server.vm.hostname = "test"
    server.vm.network "private_network", ip: "192.168.56.110"
    
    server.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
    end
    
    server.vm.synced_folder "./apps", "/vagrant/apps"
    server.vm.provision "shell", inline: <<-SHELL
      # Install K3s
      curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644
      
      # Wait for K3s
      sleep 20
      
      echo "K3s installed! Run: vagrant ssh test"
    SHELL
  end
end
```

**What this does:**
- Creates 1 VM called "test"
- Installs K3s
- Shares apps folder
- **No deployments yet!** (we'll do manually)

**Save it.**

---

### **Step 1.2: Start VM**

```bash
vagrant up
```

**Watch output. Look for:**
```
[INFO]  systemd: Starting k3s
```

**Takes ~2 minutes.**

---

### **Step 1.3: SSH into VM**

```bash
vagrant ssh test
```

**You're now INSIDE the VM.**

---

### **Step 1.4: Check K3s is Running**

```bash
kubectl get nodes
```

**Expected:**
```
NAME   STATUS   ROLES                  AGE
test   Ready    control-plane,master   1m
```

**✅ If you see this, K3s works!**

**❓ Question: What does this tell you?**
- K3s is running
- Node is "Ready" (healthy)
- It's a control-plane (master node)

---

### **Step 1.5: Check What's Running**

```bash
kubectl get pods --all-namespaces
```

**Expected:**
```
NAMESPACE     NAME                    READY   STATUS
kube-system   coredns-xxx             1/1     Running
kube-system   local-path-xxx          1/1     Running
kube-system   metrics-server-xxx      1/1     Running
kube-system   traefik-xxx             1/1     Running
```

**❓ What are these?**
- **coredns**: DNS for cluster
- **traefik**: Ingress controller (we'll use later!)
- **metrics-server**: Resource monitoring
- **local-path**: Storage provisioner

**These are K3s system pods. We didn't create them - K3s did automatically!**

---

### **Step 1.6: Create Your First Pod Manually**

**Don't use YAML yet! Use kubectl run command:**

```bash
kubectl run test-pod --image=nginx:alpine
```

**Output:**
```
pod/test-pod created
```

**❓ What just happened?**
- You told Kubernetes: "Run a pod called test-pod using nginx:alpine image"
- Kubernetes downloaded nginx:alpine from Docker Hub
- Started a container

---

### **Step 1.7: Watch Pod Start**

```bash
kubectl get pods --watch
```

**You'll see:**
```
NAME       READY   STATUS              RESTARTS   AGE
test-pod   0/1     ContainerCreating   0          5s
```

**Wait... then:**
```
NAME       READY   STATUS    RESTARTS   AGE
test-pod   1/1     Running   0          25s
```

**❓ What does this mean?**
- `0/1`: 0 out of 1 containers ready
- `ContainerCreating`: Downloading image, starting container
- `1/1 Running`: Container is up!

**Press Ctrl+C to stop watching.**

---

### **Step 1.8: Get Pod Details**

```bash
kubectl get pod test-pod -o wide
```

**Output:**
```
NAME       READY   STATUS    IP          NODE
test-pod   1/1     Running   10.42.0.8   test
```

**❓ Key info:**
- **IP**: 10.42.0.8 (pod's internal IP)
- **NODE**: test (running on your VM)

---

### **Step 1.9: Test the Pod**

```bash
curl http://10.42.0.8
```

**Expected:** Nginx default HTML page!

**❓ Why this IP?**
- Every pod gets an IP
- Only accessible inside cluster
- That's why we need Services (later)

---

### **Step 1.10: Exec into Pod**

```bash
kubectl exec -it test-pod -- /bin/sh
```

**You're now INSIDE the nginx container!**

```bash
# Check files
ls /usr/share/nginx/html

# See default HTML
cat /usr/share/nginx/html/index.html

# Exit
exit
```

**❓ What did you learn?**
- Pods are just containers
- You can enter them like SSH
- They have their own filesystem

---

### **Step 1.11: Check Pod Logs**

```bash
kubectl logs test-pod
```

**Shows nginx access/error logs.**

**Make a request to see logs appear:**
```bash
curl http://10.42.0.8
kubectl logs test-pod
```

**You'll see the HTTP GET request logged!**

---

### **Step 1.12: Describe Pod (Detailed Info)**

```bash
kubectl describe pod test-pod
```

**Look at:**
- **Events section** (what happened during creation)
- **IP address**
- **Node it's running on**
- **Image it's using**

**This is your DEBUG tool!** Always use `describe` when troubleshooting.

---

### **Step 1.13: Delete Pod**

```bash
kubectl delete pod test-pod
```

**Check:**
```bash
kubectl get pods
```

**Output:**
```
No resources found in default namespace.
```

**Pod is gone!**

---

### **🎓 CHECKPOINT: What You Learned**

- [x] Created a pod manually
- [x] Watched it start (ContainerCreating → Running)
- [x] Got pod IP address
- [x] Accessed pod via curl
- [x] Exec'd into container
- [x] Viewed logs
- [x] Described pod (detailed info)
- [x] Deleted pod

**❓ Question: Why not use pods directly in production?**
- **Answer:** Pods are ephemeral (temporary). If deleted, they're gone forever. We need something to recreate them → **Deployments!**

---

## **Phase 2: Deployments - Make Pods Persistent**

### **📚 Goal: Understand Deployments manage Pods**

---

### **Step 2.1: Create Pod via Deployment (YAML)**

**Exit VM first:**
```bash
exit
```

**Create deployment YAML:**
```bash
nano confs/test-deployment.yaml
```

**Type this MINIMAL deployment:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1
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
```

**Save it.**

**❓ Let's understand each line:**

```yaml
apiVersion: apps/v1  # API version for Deployments
kind: Deployment     # This is a Deployment
metadata:
  name: app1         # Deployment name
```

```yaml
spec:
  replicas: 1        # Run 1 copy
```

```yaml
  selector:
    matchLabels:
      app: app1      # Find pods with label app=app1
```

```yaml
  template:          # Pod template
    metadata:
      labels:
        app: app1    # Label pods with app=app1
```

```yaml
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
```

---

### **Step 2.2: Apply Deployment**

```bash
vagrant ssh test
```

**Apply YAML:**
```bash
kubectl apply -f /vagrant/confs/test-deployment.yaml
```

**Output:**
```
deployment.apps/app1 created
```

---

### **Step 2.3: Check Deployment**

```bash
kubectl get deployments
```

**Output:**
```
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
app1   1/1     1            1           10s
```

**❓ What does this mean?**
- **READY**: 1/1 = 1 pod ready out of 1 desired
- **UP-TO-DATE**: 1 pod has latest config
- **AVAILABLE**: 1 pod is ready to serve traffic

---

### **Step 2.4: Check Pods Created by Deployment**

```bash
kubectl get pods
```

**Output:**
```
NAME                    READY   STATUS    RESTARTS   AGE
app1-xxxxxxxxxx-yyyyy   1/1     Running   0          30s
```

**❓ Notice the name:**
- `app1`: Deployment name
- `xxxxxxxxxx`: ReplicaSet ID (we'll ignore this)
- `yyyyy`: Random pod ID

**Deployment created this pod automatically!**

---

### **Step 2.5: Test Self-Healing**

**Delete the pod:**
```bash
kubectl delete pod app1-xxxxxxxxxx-yyyyy
```

**Immediately check pods:**
```bash
kubectl get pods --watch
```

**You'll see:**
```
NAME                    READY   STATUS        RESTARTS   AGE
app1-xxx-yyy            1/1     Terminating   0          2m
app1-xxx-NEW            0/1     Pending       0          1s
app1-xxx-NEW            1/1     Running       0          10s
```

**❓ What happened?**
- You deleted the pod
- Deployment noticed: "I want 1 replica, but I have 0!"
- Deployment created a new pod automatically!

**This is SELF-HEALING!** 🎉

**Press Ctrl+C.**

---

### **Step 2.6: Scale to 3 Replicas**

```bash
kubectl scale deployment app1 --replicas=3
```

**Check:**
```bash
kubectl get pods
```

**Output:**
```
NAME                    READY   STATUS    RESTARTS   AGE
app1-xxx-yyy            1/1     Running   0          1m
app1-xxx-zzz            1/1     Running   0          5s
app1-xxx-aaa            1/1     Running   0          5s
```

**Now you have 3 pods!** 🎉

**Check deployment:**
```bash
kubectl get deployment app1
```

**Output:**
```
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
app1   3/3     3            3           5m
```

---

### **Step 2.7: Scale Back to 1**

```bash
kubectl scale deployment app1 --replicas=1
```

**Watch pods disappear:**
```bash
kubectl get pods --watch
```

**2 pods will terminate, 1 remains.**

**Press Ctrl+C.**

---

### **Step 2.8: Update Deployment YAML to 3 Replicas**

**Exit VM:**
```bash
exit
```

**Edit YAML:**
```bash
nano confs/test-deployment.yaml
```

**Change:**
```yaml
spec:
  replicas: 3  # Changed from 1 to 3
```

**Save.**

**Apply change:**
```bash
vagrant ssh test -c "kubectl apply -f /vagrant/confs/test-deployment.yaml"
```

**Check:**
```bash
vagrant ssh test -c "kubectl get pods"
```

**3 pods again!**

---

### **🎓 CHECKPOINT: What You Learned**

- [x] Created Deployment via YAML
- [x] Deployment manages pods
- [x] Self-healing (deleted pod recreates)
- [x] Scaling (1 → 3 → 1 → 3)
- [x] Declarative config (YAML = desired state)

**❓ Question: What's missing?**
- **Answer:** Our app serves NGINX default page, not our HTML! We need **volumes**.

---

## **Phase 3: Volumes - Mount Your HTML**

### **📚 Goal: Serve YOUR HTML, not nginx default**

---

### **Step 3.1: Update Deployment with Volume**

```bash
nano confs/test-deployment.yaml
```

**Add volume sections:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1
spec:
  replicas: 3
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
        volumeMounts:           # ← ADD THIS
        - name: html            # ← ADD THIS
          mountPath: /usr/share/nginx/html  # ← ADD THIS
      volumes:                  # ← ADD THIS
      - name: html              # ← ADD THIS
        hostPath:               # ← ADD THIS
          path: /vagrant/apps/app1  # ← ADD THIS
          type: Directory       # ← ADD THIS
```

**Save.**

---

### **Step 3.2: Apply Updated Deployment**

```bash
vagrant ssh test
```

```bash
kubectl apply -f /vagrant/confs/test-deployment.yaml
```

**Output:**
```
deployment.apps/app1 configured
```

---

### **Step 3.3: Check Pods (They'll Recreate)**

```bash
kubectl get pods --watch
```

**You'll see old pods terminate, new pods create.**

**Why?** Deployment changed → Kubernetes recreates pods with new config.

**Press Ctrl+C when all 3 Running.**

---

### **Step 3.4: Test One Pod**

```bash
# Get pod IP
kubectl get pod -o wide
```

**Pick one pod IP (e.g., 10.42.0.9):**

```bash
curl http://10.42.0.9
```

**Expected:** `<h1>App 1 Works!</h1>`

**✅ YOUR HTML is being served!**

---

### **Step 3.5: Verify Volume Mount**

```bash
# Get pod name
kubectl get pods

# Exec into pod
kubectl exec -it app1-xxx-yyy -- /bin/sh
```

**Inside container:**
```bash
ls /usr/share/nginx/html
cat /usr/share/nginx/html/index.html
exit
```

**You'll see your HTML file!**

---

### **Step 3.6: Test Live Updates**

**Exit VM:**
```bash
exit
```

**Update HTML:**
```bash
nano apps/app1/index.html
```

**Change to:**
```html
<h1>App 1 Updated!</h1>
```

**Save.**

**Test immediately (no need to redeploy!):**
```bash
vagrant ssh test -c "curl http://10.42.0.9"
```

**Shows:** `<h1>App 1 Updated!</h1>`

**✅ Volume mount is live! Changes appear instantly.**

---

### **🎓 CHECKPOINT: What You Learned**

- [x] Mounted hostPath volume
- [x] Served custom HTML instead of nginx default
- [x] Volume is live (changes appear instantly)
- [x] Volume is shared (all 3 pods see same files)

**❓ Question: How do we access pods from OUTSIDE the cluster?**
- **Answer:** We need **Services!**

---

## **Phase 4: Services - Stable Networking**

### **📚 Goal: Access pods via stable endpoint**

---

### **Step 4.1: Create Service YAML**

```bash
nano confs/test-service.yaml
```

**Type:**
```yaml
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
  type: ClusterIP
```

**Save.**

---

### **Step 4.2: Apply Service**

```bash
vagrant ssh test
```

```bash
kubectl apply -f /vagrant/confs/test-service.yaml
```

**Output:**
```
service/app1-service created
```

---

### **Step 4.3: Check Service**

```bash
kubectl get services
```

**Output:**
```
NAME           TYPE        CLUSTER-IP     PORT(S)
app1-service   ClusterIP   10.43.123.45   80/TCP
```

**❓ What's this IP?**
- **ClusterIP**: Stable internal IP
- Never changes (unlike pod IPs)
- Load balances across all app1 pods

---

### **Step 4.4: Test Service**

```bash
curl http://10.43.123.45
```

**Shows:** `<h1>App 1 Updated!</h1>`

---

### **Step 4.5: Test Load Balancing**

**Make 10 requests:**
```bash
for i in {1..10}; do
  curl -s http://10.43.123.45 && echo " - Request $i"
done
```

**All show same HTML (but traffic goes to different pods).**

---

### **Step 4.6: See Which Pod Handles Request**

**Get pod IPs:**
```bash
kubectl get pods -o wide
```

**Note IPs (e.g., 10.42.0.7, 10.42.0.8, 10.42.0.9).**

**Check service endpoints:**
```bash
kubectl get endpoints app1-service
```

**Output:**
```
NAME           ENDPOINTS
app1-service   10.42.0.7:80,10.42.0.8:80,10.42.0.9:80
```

**❓ What does this mean?**
- Service has 3 backend pods
- Traffic distributes randomly across them

---

### **Step 4.7: Test Service Survives Pod Deletion**

**Delete one pod:**
```bash
kubectl delete pod app1-xxx-yyy
```

**Immediately test service:**
```bash
curl http://10.43.123.45
```

**Still works!** Service automatically removes dead pod, adds new one.

---

### **🎓 CHECKPOINT: What You Learned**

- [x] Created Service
- [x] Service has stable IP (ClusterIP)
- [x] Service load balances across pods
- [x] Service survives pod failures

**❓ Question: How do we access from OUTSIDE (our browser)?**
- **Answer:** **Ingress!**

---

## **Phase 5: Ingress - External Access**

### **📚 Goal: Access via hostname (app1.com)**

---

### **Step 5.1: Check Traefik is Running**

```bash
kubectl get pods -n kube-system | grep traefik
```

**Output:**
```
traefik-xxx   1/1   Running
```

**✅ Traefik is running (K3s includes it by default).**

---

### **Step 5.2: Create Ingress YAML**

**Exit VM:**
```bash
exit
```

```bash
nano confs/test-ingress.yaml
```

**Type:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app1-ingress
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

### **Step 5.3: Apply Ingress**

```bash
vagrant ssh test
```

```bash
kubectl apply -f /vagrant/confs/test-ingress.yaml
```

**Output:**
```
ingress.networking.k8s.io/app1-ingress created
```

---

### **Step 5.4: Check Ingress**

```bash
kubectl get ingress
```

**Output:**
```
NAME           CLASS     HOSTS      ADDRESS         PORTS
app1-ingress   traefik   app1.com   192.168.56.110  80
```

**❓ Key info:**
- **HOSTS**: app1.com
- **ADDRESS**: 192.168.56.110 (your VM IP)

---

### **Step 5.5: Test from Inside VM**

```bash
curl -H "Host: app1.com" http://localhost
```

**Output:** `<h1>App 1 Updated!</h1>`

**❓ Why `-H "Host: app1.com"`?**
- Ingress routes based on Host header
- We're faking the hostname

---

### **Step 5.6: Test from Host Machine**

**Exit VM:**
```bash
exit
```

**Add to /etc/hosts:**
```bash
sudo nano /etc/hosts
```

**Add:**
```
192.168.56.110  app1.com
```

**Save.**

**Test:**
```bash
curl http://app1.com
```

**Output:** `<h1>App 1 Updated!</h1>`

**✅ Works from outside!**

---

### **Step 5.7: Test in Browser**

**Open browser:** `http://app1.com`

**Shows:** "App 1 Updated!"

**🎉 SUCCESS!**

---

### **🎓 CHECKPOINT: What You Learned**

- [x] Created Ingress
- [x] Ingress routes based on hostname
- [x] Accessed from outside cluster
- [x] Traefik (ingress controller) handles routing

---

## **Phase 6: Build Complete Project**

### **📚 Goal: Add App2 (3 replicas) and App3 (default)**

**Now you understand all pieces! Let's build the real project:**

---

### **Step 6.1: Create App2 and App3 HTML**

```bash
mkdir -p apps/app2 apps/app3
```

```bash
nano apps/app2/index.html
```

```html
<h1>App 2 - 3 Replicas</h1>
```

```bash
nano apps/app3/index.html
```

```html
<h1>App 3 - Default</h1>
```

---

### **Step 6.2: Create Full Deployment YAML**

```bash
nano confs/deployment.yaml
```

**Copy from Guide3.md** (you now understand every line!)

---

### **Step 6.3: Update Vagrantfile**

```bash
nano Vagrantfile
```

**Replace inline provisioning with script:**
```ruby
server.vm.provision "shell", path: "scripts/server.sh"
```

---

### **Step 6.4: Create server.sh**

```bash
nano scripts/server.sh
```

**Copy from Guide3.md.**

---

### **Step 6.5: Deploy**

```bash
vagrant destroy -f
vagrant up
```

---

### **Step 6.6: Test Everything**

```bash
# Check pods
vagrant ssh test -c "kubectl get pods"

# Should see:
# app1-xxx   1/1   Running
# app2-xxx   1/1   Running  ← 3 of these
# app2-yyy   1/1   Running
# app2-zzz   1/1   Running
# app3-xxx   1/1   Running
```

---

## **✅ What You REALLY Learned**

By building step-by-step, you now understand:

- [x] **Pods** = Basic unit, contains containers
- [x] **Deployments** = Manage pods, self-healing, scaling
- [x] **Services** = Stable networking, load balancing
- [x] **Ingress** = External routing, hostname-based
- [x] **Volumes** = Share files between host and container
- [x] **kubectl** = CLI tool to control Kubernetes
- [x] **Debugging** = describe, logs, exec

**You didn't just copy code - you built it piece by piece!** 🎉