# Preparation

Create the key

    age-keygen -o age.agekey

Create a secret based on the key

    cat age.agekey | kubectl create secret generic sops-age --namespace=openshift-gitops \
    --from-file=key.txt=/dev/stdin

# Deployment

Deploy the Talos Nodes on your PVE cluster.

    task terraform:init
    task terraform:apply
    task talos:generate-configs
    task talos:init
    task talos:bootstrap
    task talos:get-kubeconfig

Now the nodes should boot up, but have TLS errors which is expected behavior. After applying the first two modules, they should be gone and the nodes should transition into the ready state.

    kubectl kustomize cluster/bootstrap/00-requirements --enable-helm --enable-alpha-plugins | kubectl apply -f -
    kubectl kustomize cluster/bootstrap/01-cilium --enable-helm --enable-alpha-plugins | kubectl apply -f -

After some time, it should look like that:

    Sapp% kubectl get pods --namespace=kube-system
    NAME                                    READY   STATUS    RESTARTS        AGE
    cilium-4pjkz                            1/1     Running   0               5m10s
    cilium-89rvf                            1/1     Running   0               5m10s
    cilium-c2krd                            1/1     Running   0               5m10s
    cilium-jnmkn                            1/1     Running   0               5m10s
    cilium-mscph                            1/1     Running   0               5m10s
    cilium-operator-7b944c477d-672kb        1/1     Running   0               5m10s
    cilium-operator-7b944c477d-6jt9w        1/1     Running   0               5m10s
    cilium-s5b9n                            1/1     Running   0               5m10s
    coredns-5597575654-kbmln                1/1     Running   0               6m46s
    coredns-5597575654-rpntd                1/1     Running   0               6m46s
    hubble-relay-76b9fc6c78-87pbw           1/1     Running   0               5m10s
    hubble-ui-55b967c7d6-526nj              2/2     Running   0               5m10s
    kube-apiserver-k8s-control01            1/1     Running   0               6m9s
    kube-apiserver-k8s-control02            1/1     Running   0               6m36s
    kube-apiserver-k8s-control03            1/1     Running   0               4m37s
    kube-controller-manager-k8s-control01   1/1     Running   2 (7m24s ago)   5m54s
    kube-controller-manager-k8s-control02   1/1     Running   0               6m36s
    kube-controller-manager-k8s-control03   1/1     Running   2 (6m6s ago)    5m57s
    kube-scheduler-k8s-control01            1/1     Running   2 (7m29s ago)   6m2s
    kube-scheduler-k8s-control02            1/1     Running   0               6m36s
    kube-scheduler-k8s-control03            1/1     Running   2 (6m5s ago)    5m57s
    metrics-server-68bfd5c84d-8hsw6         1/1     Running   0               5m33s

    Sapp% kubectl get nodes
    NAME            STATUS   ROLES           AGE     VERSION
    k8s-control01   Ready    control-plane   7m39s   v1.26.0
    k8s-control02   Ready    control-plane   7m39s   v1.26.0
    k8s-control03   Ready    control-plane   7m26s   v1.26.0
    k8s-worker01    Ready    <none>          7m32s   v1.26.0
    k8s-worker02    Ready    <none>          7m30s   v1.26.0
    k8s-worker03    Ready    <none>          7m33s   v1.26.0

Afterwards, you can go on and deploy the other basic services.

    kubectl kustomize cluster/bootstrap/{id} --enable-helm --enable-alpha-plugins | kubectl apply -f -

Some apps are using SOPS encrypted secrets - to decrypt them you need to store your AGE key on the cluster. There is a handy task to do so.

    task sops:create-kube-secret

If you check your namespaces, it should look like that now:

    Sapp% kubens
    argocd
    cert-manager
    default
    kube-node-lease
    kube-public
    kube-system
    kubelet-serving-cert-approver
    traefik

We can now move on and deploy our storage provider, [Mayastor](mayastor.gitbook.io/). At first we need to setup some requirements - as always ;)

    k kustomize cluster/apps/01-mayastor/01-dependencies --enable-helm --enable-alpha-plugins | k apply -f -

Wait until all pods are running, especially etcd takes some time.

    Sapp% k get pods
    NAME              READY   STATUS    RESTARTS   AGE
    mayastor-etcd-0   1/1     Running   0          109s
    mayastor-etcd-1   1/1     Running   0          108s
    mayastor-etcd-2   1/1     Running   0          108s
    nats-0            2/2     Running   0          108s
    nats-1            2/2     Running   0          88s
    nats-2            2/2     Running   0          68s

Now we deploy the actual agents and the storage pools (one on each worker node) - you can adjust them in the configs.

    k kustomize cluster/apps/01-mayastor/02-mayastor-app --enable-helm --enable-alpha-plugins | k apply -f -

If everything went well, it should look like that. Again it takes a while until all pods are up and running.

    % k get pods
    NAME                              READY   STATUS    RESTARTS   AGE
    core-agents-664b988c46-s694x      1/1     Running   0          2m40s
    csi-controller-695bd68b46-ss6c7   3/3     Running   0          2m40s
    mayastor-4jhrd                    1/1     Running   0          2m39s
    mayastor-5gwkh                    1/1     Running   0          2m39s
    mayastor-7nssr                    1/1     Running   0          2m39s
    mayastor-csi-2sz42                2/2     Running   0          2m39s
    mayastor-csi-plfmj                2/2     Running   0          2m39s
    mayastor-csi-r24wm                2/2     Running   0          2m39s
    mayastor-etcd-0                   1/1     Running   0          5m30s
    mayastor-etcd-1                   1/1     Running   0          5m29s
    mayastor-etcd-2                   1/1     Running   0          5m29s
    msp-operator-c99c44c48-ch6gk      1/1     Running   0          2m39s
    nats-0                            2/2     Running   0          5m29s
    nats-1                            2/2     Running   0          5m9s
    nats-2                            2/2     Running   0          4m49s
    rest-cb78c78bf-zs6tn              1/1     Running   0          2m39s

Since I want to store some data on a NFS Share, I also deployed Democratic CSI. You can follow [this guide](https://www.lisenet.com/2021/moving-to-truenas-and-democratic-csi-for-kubernetes-persistent-storage/) on how to adjust your NFS server, but generate the keys using ssh-ed25519 since rsa is deprected in TrueNAS: `ssh-keygen -t ssh-ed25519 -C kube@nas.local -f truenas_ssh`.
A more recent guide is here: https://www.truenas.com/docs/solutions/integrations/containers/.
For further information, check out the official [GitHub documentation](https://github.com/democratic-csi/democratic-csi).
*Important:* API Authentication is only supported with TrueNAS Scale.