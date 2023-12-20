#!/bin/bash

node=$1
provider=$2

# destroy and recreate vms
cd ${HOME}/streams/create-vms/create-vms-vyos/

#destroy
echo "destroying vms"
for r in {1..9}
do
    sudo qm stop ${node}0${provider}00${r}
    sudo bash create-vm-vyos.sh -c destroy -n ${node} -p ${provider} -r ${r}
done

#create
echo "creating vms"
for r in {1..9}
do
    sudo bash create-vm-vyos.sh -c create -n ${node} -p ${provider} -r ${r}
    sudo qm start ${node}0${provider}00${r}
done

#sleeping
echo "sleeping 60 sec"
sleep 60

#update and reboot
cd ${HOME}/streams/ansible
echo "system upgrade"
#ansible-playbook -i inventories/inventory${provider}.yaml vyos_update.yml
ansible-playbook -i inventories/inventory${provider}.yaml vyos_update.yml -e "vyos_version=$(ls -t ${HOME}/streams/ansible/vyos-files/ | head -n 1 | sed -e 's/^vyos-//' | sed -e 's/-amd.*$//')"

#sleeping
echo "sleeping 60 sec, wating for first reboot"
sleep 60

#reboot (hart; wegen kaputtem cloud-init)
echo "hard reboot due to broken cloud-init"
for r in {1..9}
do
    sudo qm reset ${node}0${provider}00${r}
    sleep 10
done

#sleeping
echo "sleeping 90 sec, wating for second reboot"
sleep 90

#configuring
echo "configuring network"
ansible-playbook -i inventories/inventory${provider}.yaml setup.yml

#remove cdrom
echo "removing cdrom"
for r in {1..9}
do
    sudo qm set ${node}0${provider}00${r} --ide2 media=cdrom,file=none
done

#reboot (muss nicht sein, aber mal checken schadet ja nicht)
echo "third reboot"
ansible-playbook -i inventories/inventory${provider}.yaml vyos_reboot.yml

echo "all done, enjoy!"
