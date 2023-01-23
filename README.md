# Prereq.


# Deployment

## Setup SOPS Age Key

Create the key

    age-keygen -o age.agekey

Create a secret based on the key

    cat age.agekey | kubectl create secret generic sops-age --namespace=openshift-gitops \
    --from-file=key.txt=/dev/stdin

    task terraform:init
    task terraform:apply
    task talos:generate-configs
    task talos:init
    task talos:bootstrap
    kubectl apply -f https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    kubectl kustomize --enable-helm cluster/base/apps/cilium/ | kubectl apply -f -