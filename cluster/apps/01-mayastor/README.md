Label the worker nodes so that they will be used for storage
    k label nodes k8s-worker01 openebs.io/engine=mayastor
    k label nodes k8s-worker02 openebs.io/engine=mayastor
    k label nodes k8s-worker03 openebs.io/engine=mayastor

In case you didn't do in your talconfig.

You need to add your nodes to pool.yaml.

Wait for deployment of dependencies before deploying mayastor pools and operators. Sometimes the pools need to be regenerated because the disk was not detected (they show an error status) - in that case just delete it and re-apply the kustomization.
