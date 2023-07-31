
Script to delete all recovery points for a backup vault
______________________
1. List all recovery points by cmd
----------
aws backup list-recovery-points-by-backup-vault --backup-vault-name aws/efs/automatic-backup-vault --region ap-south-1 --by-resource-type EFS --query 'RecoveryPoints[].RecoveryPointArn' --by-created-after "2023-07-05" --by-created-before "2023-07-25" --output text > Recovery_Points1.txt
----------
2. USe below script to delete all Recovery points mentioned in the file
#######################
#!/bin/bash

INPUT_FILE=Recovery_Points.txt
VAULT_NAME=myvaultname

for ARN in $(cat $INPUT_FILE); do
    echo "deleting ${ARN} ..."
    aws backup delete-recovery-point --backup-vault-name "${VAULT_NAME}" --recovery-point-arn "${ARN}" --region ap-southeast-1
done

#######################
