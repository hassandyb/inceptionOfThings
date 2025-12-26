You've identified a critical issue! When k3d creates a cluster, it **should** automatically merge the kubeconfig and switch context, but there are cases where this fails (like the permission issues you encountered).

Let's fix your script to **guarantee** the cluster is created AND the context is switched properly.

## **Solution: Add Kubeconfig Merge After Cluster Creation**


```bash
#!/bin/bash

set -e

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

# CRITICAL: Ensure kubeconfig is properly merged and context switched
echo ""
echo "Merging kubeconfig and switching context..."
k3d kubeconfig merge $CLUSTER_NAME -d --overwrite

# Verify we're on the correct context
CURRENT_CONTEXT=$(kubectl config current-context)
echo "Current kubectl context: $CURRENT_CONTEXT"

# If not on the right context, switch explicitly
if [[ "$CURRENT_CONTEXT" != "k3d-$CLUSTER_NAME" ]]; then
    echo "Switching to k3d-$CLUSTER_NAME context..."
    kubectl config use-context "k3d-$CLUSTER_NAME"
fi

echo ""
echo "[5/5] Verifying cluster..."

# Wait for cluster to be ready
echo "Waiting for nodes to be ready..."
sleep 5

# Check nodes (should now show k3d nodes, not host)
kubectl get nodes

# Verify we got the right nodes
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
if [[ $NODE_COUNT -eq 0 ]]; then
    echo "ERROR: No nodes found! Context switch failed."
    exit 1
fi

echo ""
echo "============================================"
echo "     K3d Setup Complete!"
echo "============================================"
echo ""
echo "Cluster: $CLUSTER_NAME"
echo "Context: k3d-$CLUSTER_NAME"
echo "Nodes: $NODE_COUNT"
echo ""
echo "Next step: Run argocd.sh to install Argo CD"
echo ""
```


---

## **What Changed?**

### **1. Kubeconfig Merge (Line 20-21)**

```bash
k3d kubeconfig merge $CLUSTER_NAME -d --overwrite
```


**Flags:**
- `-d` = merge into **default** kubeconfig (`~/.kube/config`)
- `--overwrite` = replace existing entries (important for reruns)

This **guarantees** the k3d cluster config is written to your main kubeconfig.

---

### **2. Context Verification (Line 23-30)**

```bash
CURRENT_CONTEXT=$(kubectl config current-context)
echo "Current kubectl context: $CURRENT_CONTEXT"

if [[ "$CURRENT_CONTEXT" != "k3d-$CLUSTER_NAME" ]]; then
    echo "Switching to k3d-$CLUSTER_NAME context..."
    kubectl config use-context "k3d-$CLUSTER_NAME"
fi
```


**Why?**
- k3d **usually** switches context automatically
- But if it fails (permissions, existing contexts, etc.), this catches it
- Explicitly switches to `k3d-hed-dybS` context

---

### **3. Node Count Validation (Line 42-46)**

```bash
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
if [[ $NODE_COUNT -eq 0 ]]; then
    echo "ERROR: No nodes found! Context switch failed."
    exit 1
fi
```


**Why?**
- If `kubectl get nodes` returns 0 nodes, something went wrong
- Script exits with error instead of continuing silently

---

## **Test Your Script**

### **Step 1: Clean Everything**


```bash
# Delete all k3d clusters
k3d cluster delete cluster-test
k3d cluster delete test-cluster

# Verify
k3d cluster list
```


**Expected:**

```
NAME   SERVERS   AGENTS   LOADBALANCER
```


---

### **Step 2: Run Your Fixed Script**


```bash
./scripts/k3d.sh
```


**Expected output:**

```
[4/5] Creating K3d cluster...
Creating cluster 'hed-dybS'...
INFO[0000] Prep: Network
INFO[0000] Created network 'k3d-hed-dybS'
...
INFO[0015] Cluster 'hed-dybS' created successfully!

Merging kubeconfig and switching context...
/home/hassan/.kube/config
Current kubectl context: k3d-hed-dybS

[5/5] Verifying cluster...
Waiting for nodes to be ready...
NAME                   STATUS   ROLES                  AGE   VERSION
k3d-hed-dybs-server-0  Ready    control-plane,master   10s   v1.31.5+k3s1

============================================
     K3d Setup Complete!
============================================

Cluster: hed-dybS
Context: k3d-hed-dybS
Nodes: 1
```


✅ **Now `kubectl get nodes` shows k3d nodes, not your host!**

---

### **Step 3: Manual Verification**


```bash
# Check context
kubectl config current-context
```


**Expected:**

```
k3d-hed-dybS
```


---

```bash
# Check nodes
kubectl get nodes

```

**Expected:**
```

NAME                   STATUS   ROLES                  AGE   VERSION
k3d-hed-dybs-server-0  Ready    control-plane,master   1m    v1.31.5+k3s1

```

---

```
bash
# Check cluster list
k3d cluster list

```

**Expected:**
```

NAME      SERVERS   AGENTS   LOADBALANCER
hed-dybS  1/1       0/0      true

```

✅ **Everything aligned!**

---

## **Alternative: Even Safer Approach**

If you want to be **extra paranoid**, add kubeconfig path explicitly:

```
bash
#!/bin/bash

set -e

echo ""
echo "[4/5] Creating K3d cluster..."

CLUSTER_NAME="hed-dybS"
KUBECONFIG_FILE="$HOME/.kube/config"

# Ensure .kube directory exists with correct permissions
mkdir -p "$HOME/.kube"
chmod 755 "$HOME/.kube"

# Check if cluster already exists
if k3d cluster list | grep -q "$CLUSTER_NAME"; then
    echo "Cluster '$CLUSTER_NAME' already exists"
    echo "Deleting old cluster..."
    k3d cluster delete $CLUSTER_NAME
fi

# Create cluster
echo "Creating cluster '$CLUSTER_NAME'..."
k3d cluster create $CLUSTER_NAME

# Force kubeconfig merge
echo ""
echo "Merging kubeconfig..."
k3d kubeconfig merge $CLUSTER_NAME --kubeconfig-switch-context --output "$KUBECONFIG_FILE" --overwrite

# Set KUBECONFIG environment variable
export KUBECONFIG="$KUBECONFIG_FILE"

# Verify context
CURRENT_CONTEXT=$(kubectl config current-context)
echo "Current context: $CURRENT_CONTEXT"

# Explicit switch if needed
if [[ "$CURRENT_CONTEXT" != "k3d-$CLUSTER_NAME" ]]; then
    kubectl config use-context "k3d-$CLUSTER_NAME"
    CURRENT_CONTEXT=$(kubectl config current-context)
    echo "Switched to: $CURRENT_CONTEXT"
fi

echo ""
echo "[5/5] Verifying cluster..."

# Wait for nodes
sleep 5

# Check nodes
kubectl get nodes

# Validate
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
if [[ $NODE_COUNT -eq 0 ]]; then
    echo ""
    echo "ERROR: No nodes detected!"
    echo "Current context: $(kubectl config current-context)"
    echo "Available contexts:"
    kubectl config get-contexts
    exit 1
fi

echo ""
echo "============================================"
echo "     K3d Setup Complete!"
echo "============================================"
echo ""
echo "Cluster: $CLUSTER_NAME"
echo "Context: $(kubectl config current-context)"
echo "Nodes: $NODE_COUNT"
echo "Kubeconfig: $KUBECONFIG_FILE"
echo ""
echo "Next step: Run argocd.sh to install Argo CD"
echo ""

```

---

## **Why Your Original Issue Happened**

Looking at your output:

```
bash
hassan@hassan-Latitude-5450:~/Desktop/inceptionOfThings/iot/p3$ kubectl get nodes
NAME                   STATUS   ROLES                  AGE     VERSION
hassan-latitude-5450   Ready    control-plane,master   5d20h   v1.33.6+k3s1

```

This is **NOT** a k3d node! This is your **host machine's k3s installation**.

**Reasons:**
1. You had k3s installed directly on your host
2. k3d failed to merge kubeconfig (permission issues)
3. kubectl still pointed to host's `/etc/rancher/k3s/k3s.yaml`
4. Creating k3d clusters but kubectl didn't know about them

**Solution:**
The kubeconfig merge command explicitly writes to `~/.kube/config` and switches context.

---

## **Quick Reference**

### **Reset Everything**
```
bash
# Delete all k3d clusters
k3d cluster delete --all

# Remove kubeconfig
rm ~/.kube/config

# Restart script
./scripts/k3d.sh

```

---

### **Switch Between Contexts**
```
bash
# List contexts
kubectl config get-contexts

# Switch to k3d cluster
kubectl config use-context k3d-hed-dybS

# Switch to host k3s (if you have it)
kubectl config use-context default

```

---

## **Summary**

✅ **Add this after cluster creation:**
```
bash
k3d kubeconfig merge $CLUSTER_NAME -d --overwrite
kubectl config use-context "k3d-$CLUSTER_NAME"

```

✅ **Validate nodes:**
```
bash
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
if [[ $NODE_COUNT -eq 0 ]]; then
    echo "ERROR: No nodes found!"
    exit 1
fi
