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

### Why You Might Care
If you're a developer (especially if you're coming from the Java world) and you're looking for a "DevOps Rosetta Stone," this repository is for you. It’s a playground to test:
*   Cloud-native patterns without the corporate overhead.
*   Persistent Volume Claims (PVC) and local storage (e.g., Minio, PostgreSQL).
*   The operational reality of managing your own K8s cluster.

### Let's Chat!
I'm always looking for feedback or a bit of *convivial* collaboration. Whether you have ideas for optimizing the Ansible playbooks, refining the Gateway API configurations, or just want to talk shop about multi-region scaling and advanced GitOps, I’m all ears!

This project is an evolving artifact of engineering exploration, and I'd love to hear your thoughts.

Stay curious,
*Mr. Nobody*

---
*If you find a bug, it's a "feature" I'm testing. 
If you find a security hole, let's exploit it 2gether!*
