#!/bin/bash
until curl -sf http://checkip.amazonaws.com; do sleep 10; done
sudo apt-get update -y
sudo apt-get install -y python3-pip
sudo pip3 install ansible

mkdir -p /home/ubuntu/.ssh
cat > /home/ubuntu/.ssh/tf-packer << 'KEYEOF'
${ssh_private_key}
KEYEOF
chmod 600 /home/ubuntu/.ssh/tf-packer

cat > /home/ubuntu/inventory.ini << 'INVEOF'
${inventory}
INVEOF

cat > /home/ubuntu/playbook.yml << 'PLAYBOOKEOF'
${playbook}
PLAYBOOKEOF

ansible-playbook -i /home/ubuntu/inventory.ini /home/ubuntu/playbook.yml
