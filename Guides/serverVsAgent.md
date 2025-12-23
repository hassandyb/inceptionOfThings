
The difference between **server** and **worker** here is **not Vagrant**. It is **your Kubernetes (K3s) architecture**. In Vagrant, they are just **names**.

### Vagrant side

* `server` and `worker` are **Ruby variable names only**
* Vagrant treats **both exactly the same**
* Vagrant only:

  * creates VMs
  * sets network, CPU, RAM
  * runs provision scripts

You could rename them to anything and Vagrant would not care.

### K3s / Kubernetes side (the real meaning)

* **Server (control plane)**

  * Runs Kubernetes API
  * Manages the cluster
  * Schedules pods
  * Stores cluster state
* **Worker (agent)**

  * Runs application containers (pods)
  * Joins the server using a token
  * Does **no cluster management**

### Why two scripts

* `server.sh` → installs **k3s server**
* `worker.sh` → installs **k3s agent** and connects to the server

### Summary

* **Vagrant**: just creates **2 VMs**
* **K3s**: gives them **different roles**
* The distinction is **architectural**, not a Vagrant feature

This setup is exactly what the *Inception of Things* subject expects.
