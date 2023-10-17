copy enencrypted backup tp encrypt them
-------------
#!/bin/bash

# Set your AWS region
export AWS_DEFAULT_REGION=<region>

# Set your backup vault name
VAULT_NAME=<vault-name>

# Get all recovery point ARNs
recovery_point_arns=$(aws backup list-recovery-points-by-backup-vault --backup-vault-name $VAULT_NAME --query 'RecoveryPoints[].RecoveryPointArn' --output text)

# Loop through each recovery point ARN
for recovery_point_arn in $recovery_point_arns; do
    # Describe the recovery point to check if it is encrypted
    recovery_point=$(aws backup describe-recovery-point --backup-vault-name $VAULT_NAME --recovery-point-arn $recovery_point_arn)

    # Use jq to extract the encryption status
    is_encrypted=$(echo $recovery_point | jq -r '.IsEncrypted')

    # Check if the recovery point is unencrypted
    if [[ $is_encrypted == "false" ]]; then
        # Get the backup plan ID associated with the recovery point
        backup_plan_id=$(echo $recovery_point | jq -r '.BackupPlanId')

        # Copy the recovery point to a new encrypted recovery point
        aws backup start-copy-job --source-backup-vault-name $VAULT_NAME --destination-backup-vault-arn arn:aws:backup:<region>:<account-id>:backup-vault:<vault-name> --recovery-point-arn $recovery_point_arn --iam-role-arn arn:aws:iam::<account-id>:role/<role-name> --idempotency-token <idempotency-token>

        # Wait for the copy job to complete
        aws backup wait copy-job-complete --backup-vault-name <vault-name> --copy-job-id <copy-job-id>

        # Delete the original recovery point
        aws backup delete-recovery-point --backup-vault-name $VAULT_NAME --recovery-point-arn $recovery_point_arn
    fi
done

-------------------
