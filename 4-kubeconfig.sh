KUBERNETES_PUBLIC_ADDRESS=$(cd infra; terraform output k8s_public_ip)
CLUSTER_NAME=k8s-hard-way

## Workers
for instance in worker-0 worker-1 worker-2; do
  kubectl config set-cluster ${CLUSTER_NAME} \
    --certificate-authority=certificates/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kubeconfig/${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=certificates/${instance}.pem \
    --client-key=certificates/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=kubeconfig/${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=${CLUSTER_NAME} \
    --user=system:node:${instance} \
    --kubeconfig=kubeconfig/${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=kubeconfig/${instance}.kubeconfig
done

## Kube Proxy
kubectl config set-cluster ${CLUSTER_NAME} \
  --certificate-authority=certificates/ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
  --kubeconfig=kubeconfig/kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
  --client-certificate=certificates/kube-proxy.pem \
  --client-key=certificates/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kubeconfig/kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=${CLUSTER_NAME} \
  --user=system:kube-proxy \
  --kubeconfig=kubeconfig/kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kubeconfig/kube-proxy.kubeconfig

## Controller manager
kubectl config set-cluster ${CLUSTER_NAME} \
  --certificate-authority=certificates/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=kubeconfig/kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=certificates/kube-controller-manager.pem \
  --client-key=certificates/kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=kubeconfig/kube-controller-manager.kubeconfig

kubectl config set-context default \
  --cluster=${CLUSTER_NAME} \
  --user=system:kube-controller-manager \
  --kubeconfig=kubeconfig/kube-controller-manager.kubeconfig

kubectl config use-context default --kubeconfig=kubeconfig/kube-controller-manager.kubeconfig

## Scheduler
kubectl config set-cluster ${CLUSTER_NAME} \
  --certificate-authority=certificates/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=kubeconfig/kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=certificates/kube-scheduler.pem \
  --client-key=certificates/kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=kubeconfig/kube-scheduler.kubeconfig

kubectl config set-context default \
  --cluster=${CLUSTER_NAME} \
  --user=system:kube-scheduler \
  --kubeconfig=kubeconfig/kube-scheduler.kubeconfig

kubectl config use-context default --kubeconfig=kubeconfig/kube-scheduler.kubeconfig

## Admin
kubectl config set-cluster ${CLUSTER_NAME} \
  --certificate-authority=certificates/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=kubeconfig/admin.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=certificates/admin.pem \
  --client-key=certificates/admin-key.pem \
  --embed-certs=true \
  --kubeconfig=kubeconfig/admin.kubeconfig

kubectl config set-context default \
  --cluster=${CLUSTER_NAME} \
  --user=admin \
  --kubeconfig=kubeconfig/admin.kubeconfig

kubectl config use-context default --kubeconfig=kubeconfig/admin.kubeconfig

# Send the configuration files
for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp kubeconfig/${instance}.kubeconfig kubeconfig/kube-proxy.kubeconfig ${instance}:~/
done

for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp kubeconfig/admin.kubeconfig kubeconfig/kube-controller-manager.kubeconfig kubeconfig/kube-scheduler.kubeconfig ${instance}:~/
done

