set -a; source .env; set +a


### Initial project Setup
gcloud init

gcloud projects create ${CLOUDSDK_CORE_PROJECT} --name=${CLOUDSDK_CORE_PROJECT}

gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable iamcredentials.googleapis.com

### Networking
gcloud compute networks create k8s-network --subnet-mode custom\

gcloud compute networks subnets create k8s-subnet \
  --network k8s-network \
  --range 10.240.0.0/24

gcloud compute firewall-rules create k8s-allow-internal \
  --allow tcp,udp,icmp \
  --network k8s-network \
  --source-ranges 10.240.0.0/24,10.200.0.0/16

gcloud compute firewall-rules create k8s-allow-external \
  --allow tcp:22,tcp:6443,icmp \
  --network k8s-network \
  --source-ranges 0.0.0.0/0

gcloud compute addresses create k8s-ip \
  --region $CLOUDSDK_COMPUTE_REGION

#### Instances

## Controllers
for i in 0 1 2; do
  gcloud compute instances create controller-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-1804-lts \
    --image-project ubuntu-os-cloud \
    --machine-type n1-standard-1 \
    --private-network-ip 10.240.0.1${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet k8s-subnet \
    --tags k8s,controller
done

## Workers
for i in 0 1 2; do
  gcloud compute instances create worker-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-1804-lts \
    --image-project ubuntu-os-cloud \
    --machine-type n1-standard-1 \
    --metadata pod-cidr=10.200.${i}.0/24 \
    --private-network-ip 10.240.0.2${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet k8s-subnet \
    --tags k8s,worker
done
