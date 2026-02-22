# Gateway API Installation on Hetzner Cluster (Traefik)

Since you have a 1-node cluster and `kubectl get all` works, follow these steps to install the Gateway API and Traefik.

### 1. Install Gateway API CRDs (Standard)
Install the Gateway API Custom Resource Definitions first:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
```

### 2. Install Traefik
If you previously installed NGINX Gateway Fabric, you should uninstall it first:
```bash
helm uninstall ngf -n nginx-gateway
kubectl delete namespace nginx-gateway
```

Now, install Traefik in the `traefik` namespace and enable Gateway API support.

```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm install traefik traefik/traefik \
  --namespace traefik \
  --create-namespace \
  --set providers.kubernetesGateway.enabled=true
```

### 3. Create the Gateway Resource
Create the namespace for the gateway (matching your `HTTPRoute`'s `parentRef`):
```bash
kubectl create namespace gateway-namespace
```

Create a file called `gateway.yaml`:
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: global-gateway
  namespace: gateway-namespace
spec:
  gatewayClassName: traefik
  listeners:
    - name: http
      port: 8000 # Matches Traefik's internal 'web' port (8000)
      protocol: HTTP
      allowedRoutes:
        namespaces:
          from: All
    - name: https
      port: 8443 # Matches Traefik's internal 'websecure' port (8443)
      protocol: HTTPS
      tls:
        mode: Terminate
        certificateRefs:
          - name: s4v3-net-tls # You'll need to create this Secret later
      allowedRoutes:
        namespaces:
          from: All
```
Apply it:
```bash
kubectl apply -f gateway.yaml
```

### 4. Apply your Application and Route
Now apply your local `k8s-gateway` configuration (Nginx deployment + HTTPRoute):

```bash
kubectl apply -k k8s-gateway
```

### 5. Access Traefik via NodePort
To reach your cluster from the outside, you need to expose the Traefik service via a NodePort.

Check the Traefik service:
```bash
kubectl get svc -n traefik
```

Patch the Traefik service to use NodePort 30081:
```bash
kubectl patch svc traefik -n traefik -p '{"spec": {"type": "NodePort", "ports": [{"port": 80, "targetPort": "web", "nodePort": 30081, "name": "web"}]}}'
```

Now you should be able to reach your service at:
`http://ubuntu1.s4v3.net:30081/`

### 6. Access via Port 80 (Instead of 30081)
If you want to reach your service directly via `http://ubuntu1.s4v3.net/` (port 80), you have three main options:

#### Option A: Port Forwarding (Quickest)
Run this on your ubuntu1 node:
```bash
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 30081
```

## Works on single node k8s cluster
#### Option B: Use Host Port mapping (Recommended for Single-Node)
Reconfigure Traefik to map the host's ports 80 and 443 directly to the Traefik pod.
```bash
helm upgrade traefik traefik/traefik \
  --namespace traefik \
  --set providers.kubernetesGateway.enabled=true \
  --set ports.web.hostPort=80 \
  --set ports.websecure.hostPort=443 \
  --set service.type=ClusterIP
```

#### Option C: Hetzner Cloud Load Balancer (Production)
```bash
kubectl patch svc traefik -n traefik -p '{"spec": {"type": "LoadBalancer"}}'
```

### 7. Verify Status
```bash
kubectl get gateway -n gateway-namespace
kubectl get httproute -A
kubectl get pods -n traefik
```
