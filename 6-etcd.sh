ETCD_VERSION=v3.4.3
GOOGLE_URL=https://storage.googleapis.com/etcd
DOWNLOAD_URL=${GOOGLE_URL}
# no connection inside the machine
curl -L ${DOWNLOAD_URL}/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz -o etcd-${ETCD_VERSION}-linux-amd64.tar.gz

install_etcd()
{
    ETCD_VERSION=v3.4.3
    host=$1

    echo "Installing etcd ${ETCD_VERSION}" on ${host}

    # Install
    tar xzvf etcd-${ETCD_VERSION}-linux-amd64.tar.gz -C tmp --strip-components=1
    rm -f etcd-${ETCD_VERSION}-linux-amd64.tar.gz
    sudo mv tmp/etcd* /usr/local/bin/
    rm -r tmp

    # Configure
    sudo mkdir -p /etc/etcd /var/lib/etcd
    sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/

    INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
      http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)
    ETCD_NAME=$(hostname -s)

    # Create etcd.service (systemd file)
    cat > etcd.service <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
--name ${ETCD_NAME} \\
--cert-file=/etc/etcd/kubernetes.pem \\
--key-file=/etc/etcd/kubernetes-key.pem \\
--peer-cert-file=/etc/etcd/kubernetes.pem \\
--peer-key-file=/etc/etcd/kubernetes-key.pem \\
--trusted-ca-file=/etc/etcd/ca.pem \\
--peer-trusted-ca-file=/etc/etcd/ca.pem \\
--peer-client-cert-auth \\
--client-cert-auth \\
--initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
--listen-peer-urls https://${INTERNAL_IP}:2380 \\
--listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
--advertise-client-urls https://${INTERNAL_IP}:2379 \\
--initial-cluster-token etcd-cluster-0 \\
--initial-cluster controller-0=https://10.240.0.10:2380,controller-1=https://10.240.0.11:2380,controller-2=https://10.240.0.12:2380 \\
--initial-cluster-state new \\
--data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    sudo mv etcd.service /etc/systemd/system/

    # Start etcd
    sudo systemctl daemon-reload
    sudo systemctl enable etcd
    sudo systemctl start etcd
}

gcloud compute scp etcd-${ETCD_VERSION}-linux-amd64.tar.gz controller-0:~/
gcloud compute ssh controller-0 << EOF
    $(typeset -f install_etcd)
    install_etcd controller-0
EOF

# Check if they're running
gcloud compute ssh controller-0 sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem
