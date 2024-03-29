#!/bin/env bash

set -euo pipefail
while getopts c:n:p:r: flag
do
    case "${flag}" in
	c) command=${OPTARG};;
	n) node=${OPTARG};;
	p) provider=${OPTARG};;
	r) router=${OPTARG};;
    esac
done

echo "vmid:${node}0${provider}00${router} provider:${provider} router:${router}"

if [[ -n "${node+set}" && "${provider+set}" && "${router+set}" ]]
then
    vmid=${node}0${provider}0`printf '%02d' $router`
    mgmtmac=00:24:18:A${provider}:`printf '%02d' $router`:00

    case "${command}" in
	create)
	    vmid=${node}0${provider}0`printf '%02d' $router`
	    ## Create VM, import disk and define boot order
	    qm create $vmid --name "p${provider}r${router}v" --ostype l26 --memory 2048 --balloon 2048 --cpu cputype=x86-64-v2-AES --cores 4 --scsihw virtio-scsi-single --net0 virtio,bridge=ABXMGMTN,mtu=1400,macaddr="${mgmtmac}"
	    qm importdisk $vmid vyos-1.5.0-cloud-init-10G-qemu.qcow2 local-zfs
	    qm set $vmid --virtio0 local-zfs:vm-$vmid-disk-0,iothread=1
	    qm set $vmid --boot order=virtio0
	    qm set $vmid --serial0 socket
	    ## add interfaces to the router
	    for net in {1..4}
	    do
		if [[ ${router} == 1 && ${net} == 1 ]]
		then
		    qm set $vmid --net${net} virtio,bridge=vmbr0,mtu=1500,macaddr=00:${node}4:18:F${provider}:`printf '%02d' $router`:`printf '%02d' $net`
		else
		    vlanid=$(/home/aibix/streams/vlans3.sh 8 2 $router $net $provider)
		    qm set $vmid --net${net} virtio,bridge=ABXP${provider}VXN,mtu=1400,tag=${vlanid},macaddr=00:${node}4:18:F${provider}:`printf '%02d' $router`:`printf '%02d' $net`
		fi
	    done
	    ## Import seed.iso for cloud init, r1 and rn differ!
	    if [[ ${router} == 1 ]]
	    then
		qm set $vmid --ide2 media=cdrom,file=/var/lib/vz/template/iso/seed-1.iso
	    else
		qm set $vmid --ide2 media=cdrom,file=/var/lib/vz/template/iso/seed-n.iso
	    fi
	    
	    qm set $vmid --onboot 1
	    echo "                {
                    \"hw-address\": \"${mgmtmac}\",
                    \"ip-address\": \"10.20.30.${provider}${router}\",
                    \"client-classes\": [ \"KnownClients\" ]
                }," >> dhcp.config.txt

	    ;;

	destroy)
	    qm stop $vmid && qm destroy $vmid
	    ;;

	dhcp)
	    echo "                {
                    \"hw-address\": \"${mgmtmac}\",
                    \"ip-address\": \"10.20.30.${provider}${router}\",
                    \"client-classes\": [ \"KnownClients\" ]
                },"
	    ;;

	*)
	    echo "hi there, possible commands are create and destroy"
	    ;;
    esac

else
    echo "something went wrong"

fi



