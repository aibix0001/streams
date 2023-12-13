#!/bin/env bash
while getopts p:r: flag
do
    case "${flag}" in
	p) provider=${OPTARG};;
	r) router=${OPTARG};;
    esac
done

echo "vmid:${provider}00${router} provider:${provider} router:${router}"

if [[ -n "${provider+set}" && "${router+set}" ]]
then
    vmid=${provider}0`printf '%02d' $router`
    ## Create VM, import disk and define boot order
    ## leave provider out of name if provider is 1
    case $provider in
	1)
	    qm create $vmid --name "r${router}v" --ostype l26 --memory 2048 --balloon 2048 --cpu cputype=host --cores 4 --scsihw virtio-scsi-single --net0 virtio,bridge=vmbr1001,macaddr=00:04:18:A${provider}:`printf '%02d' $router`:00
	    ;;
	*)
	    qm create $vmid --name "r${provider}${router}v" --ostype l26 --memory 2048 --balloon 2048 --cpu cputype=host --cores 4 --scsihw virtio-scsi-single --net0 virtio,bridge=vmbr1001,,macaddr=00:04:18:A${provider}:`printf '%02d' $router`:00
	    ;;
    esac
    qm importdisk $vmid vyos-1.5.0-cloud-init-10G-qemu.qcow2 local-btrfs
    qm set $vmid --virtio0 local-btrfs:$vmid/vm-$vmid-disk-0.raw
    qm set $vmid --boot order=virtio0
    qm set $vmid --serial0 socket
    ## add interfaces to the router
    for net in {1..4}
    do
	qm set $vmid --net${net} virtio,bridge=vmbr${provider}000,tag=4090,macaddr=00:04:18:F${provider}:`printf '%02d' $router`:`printf '%02d' $net`
    done
    ## Import seed.iso for cloud init
    qm set $vmid --ide2 media=cdrom,file=local-btrfs:iso/new-seed.iso
    qm set $vmid --onboot 1
fi
