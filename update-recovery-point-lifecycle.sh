script to update recover point lifecycle for a vault
----------------------------
#!/bin/bash

set -e

echo "Enter the name of the vault where all backups retention should be updated"
read VAULT_NAME

for ARN in $(aws backup list-recovery-points-by-backup-vault --backup-vault-name "${VAULT_NAME}" --query 'RecoveryPoints[].RecoveryPointArn' --output text); do
  echo "updateretention ${ARN} ..."
  aws backup update-recovery-point-lifecycle --backup-vault-name "${VAULT_NAME}" --recovery-point-arn "${ARN}" --lifecycle DeleteAfterDays=8
done


----------------------------
