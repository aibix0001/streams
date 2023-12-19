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
echo "sleeping 45 sec"
sleep 45

#update and reboot
cd ${HOME}/streams/ansible
echo "system upgrade"
ansible-playbook -i inventories/inventory${provider}.yaml vyos_update.yml

#reboot (hart; wegen kaputtem cloud-init)
echo "rebooting"
for r in {1..9}
do
    sudo qm reset ${node}0${provider}00${r}
done

#sleeping
echo "sleeping 90 sec, wating for reboot"
sleep 90

#configuring
echo "configuring network"
ansible-playbook -i inventories/inventory${provider}.yaml setup.yml

#reboot (muss nicht sein, aber mal checken schadet ja nicht)
echo "rebooting"
ansible-playbook -i inventories/inventory${provider}.yaml vyos_reboot.yml

echo "all done, enjoy!"
