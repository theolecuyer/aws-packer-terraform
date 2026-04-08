#!/bin/bash
until curl -sf http://checkip.amazonaws.com; do sleep 10; done
apt-get update -y
apt-get install -y python3-pip
pip3 install ansible

mkdir -p /root/.ssh
cat > /root/.ssh/tf-packer << 'KEYEOF'
${ssh_private_key}
KEYEOF
chmod 600 /root/.ssh/tf-packer

cat > /root/inventory.ini << 'INVEOF'
${inventory}
INVEOF

cat > /root/playbook.yml << 'PLAYBOOKEOF'
${playbook}
PLAYBOOKEOF

ansible-playbook -i /root/inventory.ini /root/playbook.yml