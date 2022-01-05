#!/bin/bash

######################################
## Snapshots from Contabo Instances ##
######################################

InstanceIds=$(./cntb get instances -o json | jq '. | .[].instanceId')

for InstanceId in $(echo "${InstanceIds}"); do  
echo "Instance Id: ${InstanceId}"
numberOfSnapshots=$(./cntb get snapshots $InstanceId -o json | jq '[.[]  | select(.instanceId == '${InstanceId}') ]| length')
echo "Instance snapshots: ${numberOfSnapshots}"

# get the name of oldest snapshot sorted from old to new
SnapshotId=$(./cntb get snapshots $InstanceId -o json | jq -r '. | sort_by(.createdDate) | .[0].snapshotId')
echo "Snapshot to delete: ${SnapshotId}"
ResultDelete=$(./cntb delete snapshot $InstanceId $SnapshotId)
echo "Delete Snapshot result: ${ResultDelete}"
sleep 2
if [ "$ResultDelete" == "Snapshot deleted" ]; then
     ResultCreate=$(./cntb create snapshot $InstanceId --name $(date +%Y%m%d%H%M))
     echo "New Snapshot Id: ${ResultCreate}"
else
     echo "Error creating new Snapshot of Vm Id ${InstanceId}"
fi
echo "----------------------------------------------------" 
done
