#!/bin/bash

# Путь к папке с Terraform
TF_DIR=~/diplom-practicum-yc/infrastructure

# Переход в папку Terraform и получение output в формате JSON
cd "$TF_DIR" || exit 1
OUTPUT=$(terraform output -json)

# Извлечение IP-адреса с помощью jq
MASTER_IP=$(echo "$OUTPUT" | jq -r '.k8s_master_ip.value')
WORKER1_IP=$(echo "$OUTPUT" | jq -r '.k8s_workers_ips.value[0]')
WORKER2_IP=$(echo "$OUTPUT" | jq -r '.k8s_workers_ips.value[1]')
MASTER_PRIVATE=$(echo "$OUTPUT" | jq -r '.k8s_private_ips.value[0]')
WORKER1_PRIVATE=$(echo "$OUTPUT" | jq -r '.k8s_private_ips.value[1]')
WORKER2_PRIVATE=$(echo "$OUTPUT" | jq -r '.k8s_private_ips.value[2]')

# Проверка полученных переменных
if [[ -z "$MASTER_IP" || -z "$WORKER1_IP" || -z "$WORKER2_IP" ]]; then
    echo "Ошибка: не удалось получить IP-адреса из terraform output."
    exit 1
fi

# Генерируем inventory.ini
cat > ~/kubespray/inventory/mycluster/inventory.ini <<EOF
[kube_control_plane]
master ansible_host=$MASTER_IP ansible_user=ubuntu ip=$MASTER_PRIVATE

[etcd:children]
kube_control_plane

[kube_node]
master ansible_host=$MASTER_IP ansible_user=ubuntu ip=$MASTER_PRIVATE
worker1 ansible_host=$WORKER1_IP ansible_user=ubuntu ip=$WORKER1_PRIVATE
worker2 ansible_host=$WORKER2_IP ansible_user=ubuntu ip=$WORKER2_PRIVATE

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr
EOF

echo "Файл inventory.ini обновлён с новыми IP-адресами."
