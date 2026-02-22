# Set Up a Self-Signed Certificate for Traefik (Gateway API)

Follow these steps to generate a self-signed certificate and configure the Traefik Gateway to use it for HTTPS.

### 1. Re-install or Upgrade Traefik with Host Ports
Ensure Traefik is installed with the following settings to map host ports 80 and 443 directly to the Traefik pod.

```bash
helm upgrade traefik traefik/traefik \
  --namespace traefik \
  --set providers.kubernetesGateway.enabled=true \
  --set ports.web.hostPort=80 \
  --set ports.websecure.hostPort=443 \
  --set service.type=ClusterIP
```

### 2. Create the Gateway Namespace
If you haven't already, create the namespace where the `Gateway` resource will live.

```bash
kubectl create namespace gateway-namespace
```

### 3. Generate a Wildcard Self-Signed Certificate
You can use `openssl` to create a new certificate and key that covers both `s4v3.net` and all its subdomains (`*.s4v3.net`).

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key \
  -out tls.crt \
  -subj "/CN=s4v3.net" \
  -addext "subjectAltName = DNS:s4v3.net, DNS:*.s4v3.net"
```

### 4. Create the TLS Secret
Apply the Secret manifest to create it in the `gateway-namespace`.

```bash
kubectl create secret tls s4v3-net-tls \
  --key tls.key \
  --cert tls.crt \
  -n gateway-namespace
```
```bash
kubectl apply -f https/s4v3-net-tls.yaml
```

> **Note:** If you regenerate your certificates in Step 3, you should also update the `https/s4v3-net-tls.yaml` file with the new base64-encoded values of `tls.crt` and `tls.key`.

### 5. Create or Update the Gateway Resource
Create a file called `gateway.yaml` (or update your existing one in `k8s-gateway/gateway.yaml`):

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
      port: 8000 # Matches Traefik's internal 'web' port
      protocol: HTTP
      allowedRoutes:
        namespaces:
          from: All
    - name: https
      port: 8443 # Matches Traefik's internal 'websecure' port
      protocol: HTTPS
      tls:
        mode: Terminate
        certificateRefs:
          - name: s4v3-net-tls
      allowedRoutes:
        namespaces:
          from: All
```

Apply the gateway:
```bash
kubectl apply -f k8s-gateway/gateway.yaml
```

### 6. Verify Access
Now you should be able to reach your service via HTTPS on port 443 for both the base domain and any subdomain. Use `-k` to ignore the self-signed certificate warning.

```bash
# Test base domain
curl -k https://s4v3.net/

# Test subdomains
curl -k https://ubuntu1.s4v3.net/
curl -k https://anything.s4v3.net/
```
