# Set Up HTTPS with Let's Encrypt (Gateway API)

This guide explains how to use `cert-manager` with Traefik and the Kubernetes Gateway API to automatically obtain and renew Let's Encrypt TLS certificates.

### 1. Install cert-manager
`cert-manager` is the standard tool for managing TLS certificates in Kubernetes.

```bash
# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install cert-manager CRDs and the Helm chart
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true \
  --set config.enableGatewayAPI=true
```

Verify that cert-manager is running:
```bash
kubectl get pods -n cert-manager
```

### 2. Create a ClusterIssuer
A `ClusterIssuer` tells `cert-manager` how to communicate with Let's Encrypt. We will use the **HTTP-01** challenge, which is the simplest to set up.

Create a file named `letsencrypt-issuer.yaml`:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # The ACME server address for Let's Encrypt production
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: mr.vrabie@gmail.com
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-prod
    # Enable the HTTP-01 challenge provider
    solvers:
    - http01:
        gatewayHTTPRoute:
          parentRefs:
          - name: global-gateway
            namespace: gateway-namespace
            kind: Gateway
```

*Note: Replace `your-email@example.com` with your actual email to receive renewal notifications.*

Apply the issuer:
```bash
kubectl apply -f letsencrypt-issuer.yaml
```

### 3. Update the Gateway to use Let's Encrypt
To tell `cert-manager` to manage a certificate for your `Gateway`, you need to add an annotation and ensure the `certificateRefs` matches the secret name `cert-manager` will create.

Update your `k8s-gateway/gateway.yaml`:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: global-gateway
  namespace: gateway-namespace
  annotations:
    # This annotation tells cert-manager to use the specified Issuer
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  gatewayClassName: traefik
  listeners:
    - name: http
      port: 8000
      protocol: HTTP
      allowedRoutes:
        namespaces:
          from: All
    - name: https-yourdomain
      hostname: "yourdomain.com" # Hostname is REQUIRED for cert-manager to create a certificate
      port: 8443
      protocol: HTTPS
      tls:
        mode: Terminate
        certificateRefs:
          - name: s4v3-net-tls # cert-manager will create/update this Secret
      allowedRoutes:
        namespaces:
          from: All
```

Apply the updated Gateway:
```bash
kubectl apply -f k8s-gateway/gateway.yaml
```

### 4. Verify the Certificate
`cert-manager` will automatically detect the Gateway, create a `Certificate` resource, and start the Let's Encrypt challenge.

Check the status of the certificate:
```bash
kubectl get certificate -n gateway-namespace
```

You can also check the `Challenge` and `Order` resources if it's taking a while:
```bash
kubectl get challenges -n gateway-namespace
kubectl get orders -n gateway-namespace
```

Once the certificate is `Ready`, your site will be protected by a valid Let's Encrypt certificate.

### 5. Troubleshooting
- **DNS:** Ensure your domain (`s4v3.net`) points to your server's public IP. Let's Encrypt must be able to reach your cluster on port 80 to verify ownership.
- **Firewall:** Ensure port 80 is open and not blocked by Hetzner's firewall or `iptables`.
- **Logs:** If the certificate doesn't become ready, check the cert-manager logs:
  ```bash
  kubectl logs -l app.kubernetes.io/instance=cert-manager -n cert-manager
  ```
