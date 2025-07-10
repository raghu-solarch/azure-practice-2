Once VMs are ready, wait for 5 min, log into all VMs. and run below steps:

To confirm all the commands are executed, after you log into the servers, run below command:

cat /var/log/init-script-status.log

You should get below output:
" init.sh completed on master at Wed Jul  9 20:37:22 UTC 2025 "

If you see this output, that means you are good to proceed with further below steps.


Run this only in master node:
============================

kubeadm init --apiserver-advertise-address $(hostname -i) --pod-network-cidr=192.168.0.0/16

Note : Save the output in notepad.
=================================

sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/calico.yaml

watch -n 1 kubectl get nodes    -- run and watch this in master node.

Run this only in worker nodes:
==============================

kubeadm join 172.31.33.189:6443 --token dl6nbv.g2kbrrem0tx6z6wh \
        --discovery-token-ca-cert-hash sha256:9e2ed7d8d162d12e39e32ba768348976df7687e8bb79f12455c7c16d3d0f082b
Note :

172.31.33.189:6443 --> this ipaddress will be changed according to your environment

Once we run this command, we will see (output of watch -n 1 kubectl get nodes), that the worker nodes status changes from notready to ready. 

from this: 

Every 1.0s: kubectl get nodes                                                                                                                                                 master: Wed Jul  9 21:06:38 2025

NAME     STATUS     ROLES           AGE     VERSION
master   Ready      control-plane   2m25s   v1.30.14
node1    NotReady   <none>          8s      v1.30.14
node2    NotReady   <none>          6s      v1.30.14

To this:

Every 1.0s: kubectl get nodes                                                                                                                                                 master: Wed Jul  9 21:07:40 2025

NAME     STATUS   ROLES           AGE     VERSION
master   Ready    control-plane   3m27s   v1.30.14
node1    Ready    <none>          70s     v1.30.14
node2    Ready    <none>          68s     v1.30.14

If we see the status for all 3 as Ready, it means kubernetes cluster is ready for use.
