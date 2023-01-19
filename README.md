# Prereq.


# Deployment
    task terraform:init
    task terraform:apply
    task talos:generate-configs
    task talos:init
    task talos:bootstrap
    kubectl apply -f https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    kubectl kustomize --enable-helm cluster/base/apps/cilium/ | kubectl apply -f -
