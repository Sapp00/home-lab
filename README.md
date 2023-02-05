# Prereq.


# Deployment

## Setup SOPS Age Key

Create the key

    age-keygen -o age.agekey

Create a secret based on the key

    cat age.agekey | kubectl create secret generic sops-age --namespace=openshift-gitops \
    --from-file=key.txt=/dev/stdin

Deploy the Talos Nodes on your PVE cluster.

    task terraform:init
    task terraform:apply
    task talos:generate-configs
    task talos:init
    task talos:bootstrap

Now the nodes should boot up, but have TLS errors which is expected behavior. After applying the first two modules, they should be gone.

    kubectl kustomize cluster/bootstrap/{id} --enable-helm --enable-alpha-plugins | kubectl apply -f -

Some apps are using SOPS encrypted secrets - to decrypt them you need to store your AGE key on the cluster. There is a handy task to do so.

    task sops:create-kube-secret