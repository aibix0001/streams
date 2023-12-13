

#/bin/bash

# array mit ids und command füllen
declare -A vms
for x in qm pct
do
    for i in $(sudo $x list | awk '!/(VMID|template)/ {print $1}')
    do
	vms[$i]=$x
    done
done

# brauchen snapshot type
if [[ $1 != "snapshot" && $2 == "" ]]
then
    echo "Error: need snapshot type"
    exit 99
fi

#snapshots auflisten
if [[ $1 == "list" ]]
then
    for i in "${!vms[@]}"
    do
	echo -n "${vms[$i]}$i "
	sudo ${vms[$i]} listsnapshot $i | grep $2 | awk '{print $2}' | sort | tail -n 1
    done
fi


if [[ $1 == "rollback" ]]
then
    # wenn schon im selben "ordner" dann keinen snapshot machen vor dem rollback
    DAY=$(sudo qm listsnapshot $(sudo qm list | awk '!/(VMID|template)/ {print $1}' | head -n 1) | grep -B 1 current | awk '{print $2}' | head -n 1 | cut -d "-" -f 1)
    if [[ $DAY != $2 ]]
    then
	${0} snapshot
    fi

    # rollback
    echo "rolling back"
    for i in "${!vms[@]}"
    do
	echo -n "${vms[$i]}$i "
	for s in $(sudo ${vms[$i]} listsnapshot $i | grep $2 | awk '{print $2}' | sort | tail -n 1)
	do
		sudo ${vms[$i]} rollback $i $s --start 1
		if [[ $? -eq 0 ]]
		then
		    echo "done"
		fi
	done
    done
fi

if [[ $1 == "snapshot" ]]
then
    echo "snaphotting"
    for i in "${!vms[@]}"
    do
	echo -n "${vms[$i]}$i "
	SNAP=$(sudo ${vms[$i]} listsnapshot $i | grep -B 1 current | awk '{print $2}' | head -n 1 | cut -d "-" -f 1)
	sudo ${vms[$i]} snapshot $i "$(echo $SNAP|cut -d "-" -f 1)-$(date +"%y%m%d--%H-%M-%S")"
	if [[ $? -eq 0 ]]
	then
	    echo "done"
	fi
    done
fi

if [[ $1 == "delete" ]]
then
    echo "deleting snapshots in folder $2"
    for i in "${!vms[@]}"
    do
	echo -n "${vms[$i]}$i "
	for s in $(sudo ${vms[$i]} listsnapshot $i | grep $2- | awk '{print $2}' | sort | tail -n 1)
	do
	    sudo ${vms[$i]} delsnapshot $i $s
	    if [[ $? -eq 0 ]]
	    then
		echo "done"
	    fi
	done
    done
fi

if [[ $1 == "deleteall" ]]
then
    echo "deleting snapshots in folder $2"
    for i in "${!vms[@]}"
    do
	echo -n "${vms[$i]}$i "
	for s in $(sudo ${vms[$i]} listsnapshot $i | awk '{print $2}' | sort | tail -n 1)
	do
	    sudo ${vms[$i]} delsnapshot $i $s
	    if [[ $? -eq 0 ]]
	    then
		echo "done"
	    else
		break
	    fi
	done
    done
fi
