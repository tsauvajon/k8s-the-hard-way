# Generate the certificates for all the services

mkdir -p certificates
cd certificates

CERT_COUNTRY=Australia
CERT_STATE='New South Wales'
CERT_LOCATION=Sydney

################### CA  ###################
{
cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${CERT_COUNTRY}",
      "S": "${CERT_STATE}",
      "L": "${CERT_LOCATION}",
      "O": "Kubernetes",
      "OU": "CA"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca
}



################### Admin ###################
{
cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${CERT_COUNTRY}",
      "S": "${CERT_STATE}",
      "L": "${CERT_LOCATION}",
      "O": "system:masters",
      "OU": "Kubernetes"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin
}



################### Kubelets ###################
for instance in worker_0 worker_1 worker_2; do
cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${CERT_COUNTRY}",
      "S": "${CERT_STATE}",
      "L": "${CERT_LOCATION}",
      "O": "system:nodes",
      "OU": "Kubernetes"
    }
  ]
}
EOF

INTERNAL_IP=$(cd ../infra; terraform output ${instance}_internal_ip)
EXTERNAL_IP=$(cd ../infra; terraform output ${instance}_external_ip)

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
  -profile=kubernetes \
  ${instance}-csr.json | cfssljson -bare ${instance}
done



################### Controller Manager ###################
{
cat > kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${CERT_COUNTRY}",
      "S": "${CERT_STATE}",
      "L": "${CERT_LOCATION}",
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager
}



################### Kube Proxy ###################
{
cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${CERT_COUNTRY}",
      "S": "${CERT_STATE}",
      "L": "${CERT_LOCATION}",
      "O": "system:node-proxier",
      "OU": "Kubernetes"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy

}



################### Scheduler ###################
{
cat > kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${CERT_COUNTRY}",
      "S": "${CERT_STATE}",
      "L": "${CERT_LOCATION}",
      "O": "system:kube-scheduler",
      "OU": "Kubernetes"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler
}



################### Kubernetes API ###################
{
KUBERNETES_PUBLIC_ADDRESS=$(cd ../infra; terraform output k8s_public_ip)
KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local

cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${CERT_COUNTRY}",
      "S": "${CERT_STATE}",
      "L": "${CERT_LOCATION}",
      "O": "Kubernetes",
      "OU": "Kubernetes"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
}

################### Service Account ###################
{
cat > service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${CERT_COUNTRY}",
      "S": "${CERT_STATE}",
      "L": "${CERT_LOCATION}",
      "O": "Kubernetes",
      "OU": "Kubernetes"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account
}



################### Install certificates ###################
for instance in worker_0 worker_1 worker_2; do
  name=$(cd ../infra; terraform output ${instance}_name)
  gcloud compute scp ca.pem ${instance}-key.pem ${instance}.pem ${name}:~/
done

for instance in controller_0 controller_1 controller_2; do
  name=$(cd ../infra; terraform output ${instance}_name)
  gcloud compute scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem ${name}:~/
done
