#/bin/bash

# $1 qm oder pct
# $2 vm oder ct ID
# $3 am ende ausgewählter snapshot zum beginn

# aufruf mit
#
# for c in pct qm ; do for i in $(sudo ${c} list | awk '!/(VMID|template)/ {print $1}') ; do bash scripting/initial_snapshots.sh $c $i doodling ; done ; done
#
# oder halt endlich mal hier einbauen :)

sudo $1 snapshot $2 start
sudo $1 snapshot $2 doodling
sudo $1 rollback $2 start
sudo $1 snapshot $2 freitag
sudo $1 rollback $2 start
sudo $1 snapshot $2 samstag
sudo $1 rollback $2 $3
