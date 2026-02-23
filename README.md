# My Kubernetes Journey on Hetzner: A Playground in Prod! 

Hey there! If you've ever found the *labyrinthine* world of DevOps to be a bit... 
daunting (and occasionally filled with more YAML-induced tears than actual code), you're in good company. 


### The Spark: Why a VPS?
I started this with a single VPS on **Hetzner Cloud**. Why? Because sometimes you just need a deterministic environment where you can break things, fix them, and maybe even learn how a Kubernetes control plane actually functions under the hood. 

### The Tech Stack (or: My Love Letter to Automation)
To orchestrate this beautiful madness, I chose **Kubespray (v2.30.0)**. 
It's a *venerable*, Ansible-based tool that makes cluster setup feel almost... *civilized*. 

Now, I'll be honest: my current setup is a single-node "cluster." I know, calling one node a cluster is a bit of a *euphemism*, but the beauty is in its *malleability* when I get an extra 20$ to spare on another vps. 

On the networking side, I’ve adopted the modern **Kubernetes Gateway API** with **Traefik** as the primary ingress controller. I
t provides a *perspicacious* control over traffic routing that is more developer-friendly than the default Ingress controller. And I am a Java developer! 
And of course, **cert-manager** is there to *obviate* the pain of manual TLS management. 

Let's Encrypt does all the heavy lifting, giving us automated, valid certificates for our services.

### The Fruit of the Labor: [s4v3.net](https://s4v3.net)
The real-world case study for all this infrastructure is [s4v3.net](https://s4v3.net). It's a platform I built to allow users to save and share files—docs, music, movies, you name it. It even has ephemeral links for those "this message will self-destruct" sharing moments. It's been a *salubrious* experience seeing it all come together.

### Let's Chat!
I'm always looking for feedback or a bit of *convivial* collaboration. 


# The Path to Enlightenment (Getting Started)

Should you feel a *proclivity* for high-stakes YAML and want to replicate this setup on your own Hetzner VPS, here is the blueprint. 

**Assumptions:**
*   You have a VPS with a public IPv4 address.
*   Reverse DNS (rDNS) is configured to your domain (e.g., `s4v3.net`).
*   A DNS A record is pointing your domain to the VPS IP.

#### 1. The Genesis: Server Preparation
First, we must move away from the `root` user to a more *civilized* existence. Connect to your VPS and run:

```bash
# Set your hostname to match your domain
hostnamectl set-hostname ubuntu1.s4v3.net

# Create your user (let's call him 'moldo') and grant sudo powers
adduser moldo
usermod -aG sudo moldo
```

For the full list of initialization steps, including mounting points for our Persistent Volumes and SSH key distribution, refer to my [Initialization Guide](ubuntu/start_init.md).

#### 2. Orchestrating the Chaos: Kubespray
Now, we deploy the cluster. We use the *venerable* Kubespray to handle the heavy lifting.

```bash
# Clone the repository and checkout the stable version
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
git checkout tags/v2.30.0

# Prepare the environment
python3 -m venv kubespray-venv
source kubespray-venv/bin/activate
pip3 install -U -r requirements.txt

# Run the playbook (pointing to the inventory provided in this repo)
ansible-playbook -i inventory/hezner1/inventory.ini \
  -e @inventory/hezner1/cluster-variable.yaml \
  --become --ask-become-pass \
  -u moldo \
  cluster.yml
```

Detailed inventory configurations and post-install `kubeconfig` dance steps are documented in the [Kubespray Instructions](kubespray/instructions.md).

#### 3. The Gateway to the World: Traefik & HTTPS
With the cluster breathing, we need to handle traffic. We use the **Gateway API** for a more *perspicacious* routing experience.

1.  **Install Traefik** as your Gateway controller.
2.  **Install cert-manager** to *obviate* the need for manual certificate renewals.

```bash
# Install cert-manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true \
  --set config.enableGatewayAPI=true
```

3.  **Apply the ClusterIssuer and Gateway**: Use the configurations found in `https/letsencrypt.md` to establish your `ClusterIssuer` and update your `Gateway` to use Let's Encrypt. 

You can find the step-by-step HTTPS configuration [right here](https/letsencrypt.md).
