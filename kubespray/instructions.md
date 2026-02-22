# 1 Node K8s Cluster
git clone kubespray
git checkout tags/v2.30.0

python3 -m venv kubespray-venv
source kubespray-venv/bin/activate
pip3 install -U -r requirements.txt

source kubespray-venv/bin/activate

In Kubespray directory
cp inventory/sample/inventory.ini inventory/hezner1/inventory.ini
modify it 

```ini
[kube_control_plane]
ubuntu1.s4v3.net ansible_host=ubuntu1.s4v3.net

[etcd]
ubuntu1.s4v3.net

[kube_node]
ubuntu1.s4v3.net

[k8s_cluster:children]
kube_control_plane
kube_node
```


ansible-playbook -i inventory/hezner1/inventory.ini \
-e @inventory/hezner1/cluster-variable.yaml \
--become --ask-become-pass \
-u moldo \
cluster.yml


# Copy the kube config
Then ssh@ubuntu1.s4v3.net
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# On your local machine
scp moldo@ubuntu1.s4v3.net:~/.kube/config ~/.kube/hetzner-cluster
vim ~/.kube/hetzner-cluster

change the server to the IP of the node (from 127.0.0.1 to the IP of the node: ubuntu1.s4v3.net)
export KUBECONFIG=~/.kube/hetzner-cluster

Enjoy!
