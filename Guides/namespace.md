In short, a **namespace** in Kubernetes is like a **virtual folder** for your resources (pods, services, etc.).

It lets you **organize and isolate** resources within the same cluster. For example:

* `default` – the usual workspace.
* `kube-system` – system resources.
* `test-namespace` – your own isolated space for experiments.

Think of it as **separating projects inside the same cluster** so they don’t conflict with each other.


Perfect! Let’s go step by step so you can **create, edit, and delete a namespace** in Kubernetes using `kubectl`. I’ll provide the exact commands and explain what they do.

---

### **1️⃣ Create a namespace**

```bash
kubectl create namespace test-namespace
```

* This creates a new namespace called `test-namespace`.
* Check it:

```bash
kubectl get namespaces
```

Expected output will show something like:

```
NAME              STATUS   AGE
default           Active   5d
kube-system       Active   5d
test-namespace    Active   10s
```

---

### **2️⃣ Use a namespace**

If you want to **run commands in this namespace by default**:

```bash
kubectl config set-context --current --namespace=test-namespace
```

* Now, any `kubectl get pods` or `kubectl apply` will target `test-namespace` by default.

Check current namespace:

```bash
kubectl config view --minify | grep namespace:
```

---

### **3️⃣ Edit a namespace**

You can edit its metadata (like labels) interactively:

```bash
kubectl edit namespace test-namespace
```

* This opens the namespace definition in your default editor.
* For example, you can add a label under `metadata: labels:` like:

```yaml
labels:
  purpose: learning
```

* Save and exit, then check:

```bash
kubectl get namespace test-namespace --show-labels
```

---

### **4️⃣ Delete a namespace**

```bash
kubectl delete namespace test-namespace
```

* This removes the namespace and **all resources inside it**.
* Confirm deletion:

```bash
kubectl get namespaces
```

---

### ✅ Quick recap of commands

```bash
kubectl create namespace test-namespace
kubectl get namespaces
kubectl config set-context --current --namespace=test-namespace
kubectl edit namespace test-namespace
kubectl get namespace test-namespace --show-labels
kubectl delete namespace test-namespace
```

---

If you want, I can make a **tiny practice script** that will automatically create, label, and delete a test namespace so you can practice safely without breaking anything.

Do you want me to do that?
